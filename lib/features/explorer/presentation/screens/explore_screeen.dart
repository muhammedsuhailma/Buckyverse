import 'package:bucky_verse/features/explorer/presentation/screens/explorer_details.dart';
import 'package:bucky_verse/providers/api_provider.dart';
import 'package:bucky_verse/services/discovery_service.dart';
import 'package:bucky_verse/utils/hero_tag.dart';
import 'package:bucky_verse/widgets/category_capsule.dart';
import 'package:bucky_verse/widgets/discovery/discovery_tip.dart';
import 'package:bucky_verse/widgets/shimmer/explore_shimmer.dart';
import 'package:bucky_verse/utils/page_transitions.dart';
import 'package:bucky_verse/widgets/trendingcards.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ExploreScreen extends StatefulWidget {
  final String? initialCategory;
  final String initialSort;

  /// Optional callbacks so parent (MainScreen) can track active filters
  /// for the shake-to-refresh dispatcher.
  final void Function(String category)? onCategoryChanged;
  final void Function(String language)? onLanguageChanged;

  const ExploreScreen({
    super.key,
    this.initialCategory,
    this.initialSort = "Trending",
    this.onCategoryChanged,
    this.onLanguageChanged,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static bool _hasLoadedOnce = false;
  late bool _isLoading;

  late String selectedCategory;
  late String selectedSort;
  String searchText = "";
  String selectedLanguage = "🌐 All";

  static const List<String> _languages = [
    "🌐 All",
    "🇮🇳 Hindi",
    "🌴 Malayalam",
    "🎞 Tamil",
    "🎭 Telugu",
    "🇰🇷 Korean",
    "🇯🇵 Japanese",
    "🇬🇧 English",
  ];

  static const Map<String, String> _languageCodeMap = {
    "Hindi": "hi",
    "Malayalam": "ml",
    "Tamil": "ta",
    "Telugu": "te",
    "Korean": "ko",
    "Japanese": "ja",
    "English": "en",
  };

  @override
  void initState() {
    super.initState();

    selectedCategory = widget.initialCategory ?? "All Universes";
    selectedSort = widget.initialSort;
    selectedLanguage = "🌐 All";
    searchText = "";

    _isLoading = !_hasLoadedOnce;

    if (_isLoading) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _hasLoadedOnce = true;
        });

        // Show language explore tip once
        Future.delayed(const Duration(milliseconds: 600), () async {
          if (!mounted) return;
          final should =
              await DiscoveryService.instance.shouldShowExploreLangTip();
          if (!mounted || !should) return;
          await DiscoveryService.instance.markExploreLangSeen();
          if (!mounted) return;
          DiscoveryTip.show(
            context,
            emoji: '🌐',
            title: 'Browse by Language',
            body:
                'Discover Hindi, Malayalam, Tamil, Korean, Japanese and more using the Language filter.',
          );
        });
      });
    }
  }

  @override
  void didUpdateWidget(ExploreScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory ||
        widget.initialSort != oldWidget.initialSort) {
      setState(() {
        selectedCategory = widget.initialCategory ?? "All Universes";
        selectedSort = widget.initialSort;
        selectedLanguage = "🌐 All";
        searchText = "";
      });
    }
  }

  /// Strips the emoji prefix from a language chip label, e.g.
  /// "🇮🇳 Hindi" → "Hindi", "🌐 All" → "All".
  String _cleanLanguage(String label) {
    final parts = label.split(" ");
    if (parts.length > 1) return parts.sublist(1).join(" ");
    return label;
  }

  String _getLanguageCode(String label) {
    final clean = _cleanLanguage(label);
    return _languageCodeMap[clean] ?? "";
  }

  void _onLanguageSelected(String lang) {
    if (selectedLanguage == lang) return;

    setState(() {
      selectedLanguage = lang;
    });

    // Notify parent of language change (for shake-to-refresh)
    widget.onLanguageChanged?.call(lang);

    if (lang != "🌐 All") {
      final code = _getLanguageCode(lang);
      if (code.isNotEmpty) {
        context.read<ApiProvider>().fetchLanguageCategoryDataset(
          category: selectedCategory,
          languageCode: code,
        );
      }
    }
  }

  void _onCategorySelected(String category) {
    if (selectedCategory == category) return;

    setState(() {
      selectedCategory = category;
    });

    // Notify parent of category change (for shake-to-refresh)
    widget.onCategoryChanged?.call(category);

    if (selectedLanguage != "🌐 All") {
      final code = _getLanguageCode(selectedLanguage);
      if (code.isNotEmpty) {
        context.read<ApiProvider>().fetchLanguageCategoryDataset(
          category: category,
          languageCode: code,
        );
      }
    }
  }

  String getSubtitle() {
    switch (selectedCategory) {
      case "Anime":
        return "From classics to new adventures.";
      case "Movies":
        return "Blockbusters and timeless stories.";
      case "Series":
        return "Binge-worthy stories await.";
      case "K-Drama":
        return "Heartfelt stories from Korea.";
      default:
        return "Every world, one place.";
    }
  }

  Color getTitleColor() {
    switch (selectedCategory) {
      case "Anime":
        return const Color.fromARGB(255, 129, 57, 254);
      case "Movies":
        return const Color(0xff2563EB);
      case "Series":
        return const Color(0xff0891B2);
      case "K-Drama":
        return const Color(0xffDB2777);
      default:
        return const Color(0xffA855F7);
    }
  }

  Color getSubtitleColor() {
    switch (selectedCategory) {
      case "Anime":
        return const Color.fromARGB(255, 123, 88, 179);
      case "Movies":
        return const Color.fromARGB(255, 48, 83, 178);
      case "Series":
        return const Color.fromARGB(255, 34, 114, 143);
      case "K-Drama":
        return const Color.fromARGB(255, 157, 30, 81);
      default:
        return const Color(0xff6D28D9);
    }
  }

  List<Map<String, dynamic>> _getFilteredItems(ApiProvider api) {
    List<Map<String, dynamic>> items;

    // 1. Dedicated Language Dataset vs Default Category Dataset
    if (selectedLanguage != "🌐 All") {
      final code = _getLanguageCode(selectedLanguage);
      final cached = api.getCachedDataset(selectedCategory, code);
      items = cached != null ? List<Map<String, dynamic>>.from(cached) : [];
    } else {
      switch (selectedCategory) {
        case "Anime":
          items = List<Map<String, dynamic>>.from(api.anime);
          break;
        case "Movies":
          items = List<Map<String, dynamic>>.from(api.movies);
          break;
        case "Series":
          items = List<Map<String, dynamic>>.from(api.series);
          break;
        case "K-Drama":
          items = List<Map<String, dynamic>>.from(api.kdramas);
          break;
        default:
          items = List<Map<String, dynamic>>.from(api.exploreItems);
          break;
      }
    }

    // 2. Local search within Explore
    if (searchText.trim().isNotEmpty) {
      final query = searchText.trim().toLowerCase();
      items = items.where((item) {
        final title = (item["title"] ?? "").toString().toLowerCase();
        final genres = (item["genres"] ?? "").toString().toLowerCase();
        return title.contains(query) || genres.contains(query);
      }).toList();
    }

    // 3. Sort
    switch (selectedSort) {
      case "Newest":
        items.sort(
          (a, b) => (int.tryParse(b["year"]?.toString() ?? "") ?? 0).compareTo(
            int.tryParse(a["year"]?.toString() ?? "") ?? 0,
          ),
        );
        break;

      case "Rating":
        items.sort(
          (a, b) => (double.tryParse(b["rating"]?.toString() ?? "") ?? 0.0)
              .compareTo(double.tryParse(a["rating"]?.toString() ?? "") ?? 0.0),
        );
        break;
    }

    return items;
  }

  Widget _sortChip(String title) {
    final selected = selectedSort == title;

    return ScaleOnPress(
      onTap: () {
        setState(() {
          selectedSort = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xff7C3AED) : const Color(0xff1A1127),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xff7C3AED)),
        ),
        child: Text(
          title,
          style: GoogleFonts.rajdhani(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _languageChip(String title) {
    final selected = selectedLanguage == title;

    return ScaleOnPress(
      onTap: () => _onLanguageSelected(title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffDB2777) : const Color(0xff1A1127),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xffDB2777)),
        ),
        child: Text(
          title,
          style: GoogleFonts.rajdhani(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final api = context.watch<ApiProvider>();
    final items = _getFilteredItems(api);

    final isCategoryLoading =
        (selectedCategory == "Anime" &&
            api.isAnimeLoading &&
            api.anime.isEmpty) ||
        (selectedCategory == "Movies" &&
            api.isMoviesLoading &&
            api.movies.isEmpty) ||
        (selectedCategory == "Series" &&
            api.isSeriesLoading &&
            api.series.isEmpty) ||
        (selectedCategory == "K-Drama" &&
            api.isKdramasLoading &&
            api.kdramas.isEmpty);

    final showShimmer =
        _isLoading ||
        api.isLanguageLoading ||
        (isCategoryLoading && selectedLanguage == "🌐 All");

    return Scaffold(
      backgroundColor: Colors.black54,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: size.height * .025,
                    left: size.width * .05,
                  ),
                  child: Row(
                    children: [
                      Text(
                        "EXPLORE",
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 25,
                          wordSpacing: 0.5,
                          fontWeight: const FontWeight(750),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "UNIVERSE",
                        style: GoogleFonts.rajdhani(
                          color: const Color.fromARGB(255, 153, 77, 220),
                          fontSize: 25,
                          wordSpacing: 0.5,
                          fontWeight: const FontWeight(750),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: size.width * .05),
                child: Text(
                  "Discover your next obsession",
                  style: GoogleFonts.rajdhani(
                    color: const Color.fromARGB(255, 94, 61, 123),
                    fontSize: 15,
                    wordSpacing: 0.5,
                    fontWeight: const FontWeight(750),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              /// Search Bar (Local Explore filter)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * .05),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 21, 13, 30),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color.fromARGB(255, 65, 39, 113),
                    ),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          "assets/images/lens.png",
                          fit: BoxFit.cover,
                          width: 22,
                          height: 22,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() => searchText = value);
                          },
                          style: GoogleFonts.rajdhani(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            hintText: "Search in $selectedCategory...",
                            hintStyle: GoogleFonts.rajdhani(
                              color: Colors.white38,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                      if (searchText.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            setState(() => searchText = "");
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.white60,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: size.width * .05),
                child: Row(
                  children: [
                    CategoryCapsule(
                      title: "All Universes",
                      emoji: "✨",
                      selected: selectedCategory == "All Universes",
                      onTap: () => _onCategorySelected("All Universes"),
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 161, 84, 234),
                          Color.fromARGB(255, 0, 0, 0),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    CategoryCapsule(
                      title: "Anime",
                      emoji: "⚡",
                      selected: selectedCategory == "Anime",
                      onTap: () => _onCategorySelected("Anime"),
                      gradient: const LinearGradient(
                        colors: [Color(0xff7C3AED), Color(0xff3B0764)],
                      ),
                    ),
                    const SizedBox(width: 10),
                    CategoryCapsule(
                      title: "Movies",
                      emoji: "🎬",
                      selected: selectedCategory == "Movies",
                      onTap: () => _onCategorySelected("Movies"),
                      gradient: const LinearGradient(
                        colors: [Color(0xff2563EB), Color(0xff1E3A8A)],
                      ),
                    ),
                    const SizedBox(width: 10),

                    CategoryCapsule(
                      title: "Series",
                      emoji: "📺",
                      selected: selectedCategory == "Series",
                      onTap: () => _onCategorySelected("Series"),
                      gradient: const LinearGradient(
                        colors: [Color(0xff0891B2), Color(0xff164E63)],
                      ),
                    ),
                    const SizedBox(width: 10),
                    CategoryCapsule(
                      title: "K-Drama",
                      emoji: "🌸",
                      selected: selectedCategory == "K-Drama",
                      onTap: () => _onCategorySelected("K-Drama"),
                      gradient: const LinearGradient(
                        colors: [Color(0xffDB2777), Color(0xff831843)],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * .05),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _sortChip("Trending"),
                      const SizedBox(width: 10),
                      _sortChip("Newest"),
                      const SizedBox(width: 10),
                      _sortChip("Rating"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * .05),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _languages.map((lang) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _languageChip(lang),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * .05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedLanguage != "🌐 All"
                          ? "$selectedCategory • ${_cleanLanguage(selectedLanguage)}"
                          : selectedCategory,
                      style: GoogleFonts.rajdhani(
                        color: getTitleColor(),
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      getSubtitle(),
                      style: GoogleFonts.rajdhani(
                        color: getSubtitleColor().withValues(alpha: .85),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * .05),
                child: showShimmer
                    ? const ExploreShimmer()
                    : items.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.movie_filter_outlined,
                              size: 60,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No titles found",
                              style: GoogleFonts.rajdhani(
                                color: Colors.white70,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Try selecting a different language or category",
                              style: GoogleFonts.rajdhani(
                                color: Colors.white38,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: size.width * .035,
                          mainAxisSpacing: size.height * .02,
                          childAspectRatio: 0.75,
                        ),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final cardHeroTag = heroTag(
                            category: (item["category"] ?? "").toString(),
                            id: index,
                            prefix: "explore_grid",
                          );
                          return FadeInSlide(
                            index: index,
                            child: TrendingCard(
                              image: (item["image"] ?? "").toString(),
                              title: (item["title"] ?? "").toString(),
                              category: (item["category"] ?? "").toString(),
                              rating: (item["rating"] ?? "").toString(),
                              year: (item["year"] ?? "").toString(),
                              id: index,
                              tagPrefix: "explore_grid",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  SlideFadePageRoute(
                                    child: ExplorerDetailsScreen(
                                      item: item,
                                      heroTag: cardHeroTag,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
