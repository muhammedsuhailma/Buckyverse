import 'dart:async';
import 'package:bucky_verse/features/explorer/presentation/screens/explore_screeen.dart';
import 'package:bucky_verse/features/explorer/presentation/screens/explorer_details.dart';
import 'package:bucky_verse/providers/api_provider.dart';
import 'package:bucky_verse/providers/notification_provider.dart';
import 'package:bucky_verse/screens/notificatons/notification_screen.dart';
import 'package:bucky_verse/services/discovery_service.dart';
import 'package:bucky_verse/utils/hero_tag.dart';
import 'package:bucky_verse/widgets/category_capsule.dart';
import 'package:bucky_verse/widgets/continuejourneycard.dart';
import 'package:bucky_verse/widgets/discovery/discovery_tip.dart';
import 'package:bucky_verse/widgets/shimmer/explore_shimmer.dart';
import 'package:bucky_verse/widgets/shimmer/shimmer_box.dart';
import 'package:bucky_verse/widgets/trendingcards.dart';
import 'package:bucky_verse/utils/page_transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final void Function(String category, String sort) onOpenExplore;

  const HomeScreen({super.key, required this.onOpenExplore});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _lastBackPressTime;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchText = "";
  String _selectedCategory = "All";
  String _selectedLanguage = "All";

  static const List<Map<String, dynamic>> _categories = [
    {
      "title": "All",
      "emoji": "🌍",
      "gradient": LinearGradient(
        colors: [Color(0xFF7C3AED), Color(0xFF3B0764)],
      ),
    },
    {
      "title": "Anime",
      "emoji": "⚡",
      "gradient": LinearGradient(
        colors: [Color(0xff7C3AED), Color(0xff3B0764)],
      ),
    },
    {
      "title": "Movies",
      "emoji": "🎬",
      "gradient": LinearGradient(
        colors: [Color(0xff2563EB), Color(0xff1E3A8A)],
      ),
    },
    {
      "title": "Series",
      "emoji": "📺",
      "gradient": LinearGradient(
        colors: [Color(0xff0891B2), Color(0xff164E63)],
      ),
    },
    {
      "title": "K-Drama",
      "emoji": "🌸",
      "gradient": LinearGradient(
        colors: [Color(0xffDB2777), Color(0xff831843)],
      ),
    },
  ];

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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final api = context.read<ApiProvider>();

      if (api.anime.isEmpty &&
          api.movies.isEmpty &&
          api.series.isEmpty &&
          api.kdramas.isEmpty) {
        api.loadAll();
      }

      // Show search discovery tip after a short delay (once only)
      Future.delayed(const Duration(seconds: 2), () async {
        if (!mounted) return;
        final should = await DiscoveryService.instance.shouldShowSearchTip();
        if (!mounted || !should) return;
        await DiscoveryService.instance.markSearchSeen();
        if (!mounted) return;
        DiscoveryTip.show(
          context,
          emoji: '🔍',
          title: 'Universal Search',
          body: 'Search Anime, Movies, Series and K-Dramas all at once — just tap the search bar.',
          onDismiss: () => Navigator.pop(context),
        );
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  String _cleanLanguage(String label) {
    final parts = label.split(" ");
    if (parts.length > 1) return parts.sublist(1).join(" ");
    return label;
  }

  List<Map<String, dynamic>> get _filteredSearchItems {
    final api = context.read<ApiProvider>();
    List<Map<String, dynamic>> items = api.searchItems;

    // 1. Category Filter
    if (_selectedCategory != "All") {
      items = items
          .where(
            (item) => (item["category"] ?? "").toString() == _selectedCategory,
          )
          .toList();
    }

    // 2. Language Filter
    final cleanLang = _cleanLanguage(_selectedLanguage);
    if (cleanLang != "All") {
      items = items.where((item) {
        final itemLang = (item["language"] ?? "").toString();
        return itemLang.toLowerCase() == cleanLang.toLowerCase();
      }).toList();
    }

    return items;
  }

  Widget _languageChip(String title) {
    final selected = _selectedLanguage == title;

    return ScaleOnPress(
      onTap: () {
        setState(() {
          _selectedLanguage = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffDB2777) : const Color(0xff1A1127),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? const Color(0xffDB2777) : const Color(0xff302447),
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.rajdhani(
            color: selected ? Colors.white : const Color(0xff9E9AAE),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Future<bool> _handleBackPress() async {
    if (_searchText.isNotEmpty) {
      _searchController.clear();
      _debounce?.cancel();
      setState(() {
        _searchText = "";
        _selectedCategory = "All";
        _selectedLanguage = "All";
      });
      context.read<ApiProvider>().clearSearch();
      return false;
    }

    final now = DateTime.now();

    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Press back again to exit BuckyVerse"),
          duration: Duration(seconds: 2),
        ),
      );

      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final apiProvider = context.watch<ApiProvider>();
    final trending = apiProvider.exploreItems;

    final size = MediaQuery.of(context).size;
    final isSearchingActive = _searchText.trim().isNotEmpty;

    String getCategoryCount(String category) {
      int count = 0;
      bool isLoading = false;

      switch (category) {
        case "Anime":
          count = apiProvider.anime.length;
          isLoading = apiProvider.isAnimeLoading;
          break;

        case "Movies":
          count = apiProvider.movies.length;
          isLoading = apiProvider.isMoviesLoading;
          break;

        case "Series":
          count = apiProvider.series.length;
          isLoading = apiProvider.isSeriesLoading;
          break;

        case "K-Drama":
          count = apiProvider.kdramas.length;
          isLoading = apiProvider.isKdramasLoading;
          break;
      }

      if (isLoading && count == 0) {
        return "Loading...";
      }

      return "$count ${count == 1 ? "title" : "titles"}";
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldExit = await _handleBackPress();

        if (shouldExit) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),

        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: RepaintBoundary(
                  child: Container(
                    decoration: const BoxDecoration(color: Color(0xFF000000)),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(1.1, -1.0),
                          radius: 1.3,
                          colors: [Color(0xFF4A236D), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Texture
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    size.width * .05,
                    size.height * .025,
                    size.width * .05,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Header
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "GOOD EVENING",
                                  style: GoogleFonts.rajdhani(
                                    color: const Color(0xFF6B5B9E),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2.5,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  "Cosmos Watcher 🌌",
                                  style: GoogleFonts.rajdhani(
                                    color: Colors.white,
                                    fontSize: size.width * .065,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Consumer<NotificationProvider>(
                            builder: (context, notifProvider, _) {
                              final hasUnread = notifProvider.hasUnread;
                              return ScaleOnPress(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    SlideFadePageRoute(
                                      child: const NotificationScreen(),
                                    ),
                                  );
                                },
                                child: Image.asset(
                                  hasUnread
                                      ? "assets/images/bell2.png"
                                      : "assets/images/belln.png",
                                  width: size.width * .11,
                                  height: size.width * .11,
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: size.height * .025),

                      /// Search Field
                      Container(
                        height: 55,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF20132F),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSearchingActive
                                ? const Color(0xFF8B5CF6).withValues(alpha: 0.5)
                                : const Color(0xFF653971).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/images/lens.png",
                              fit: BoxFit.fill,
                              width: 26,
                              height: 26,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: GoogleFonts.rajdhani(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _searchText = value;
                                  });

                                  if (value.trim().isEmpty) {
                                    _debounce?.cancel();
                                    context.read<ApiProvider>().clearSearch();
                                    return;
                                  }

                                  _debounce?.cancel();
                                  _debounce = Timer(
                                    const Duration(milliseconds: 350),
                                    () {
                                      if (mounted) {
                                        context.read<ApiProvider>().searchAll(
                                          value.trim(),
                                        );
                                      }
                                    },
                                  );
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintText: "Search anime, movies, dramas...",
                                  hintStyle: GoogleFonts.rajdhani(
                                    color: Colors.white54,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            if (_searchText.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  _debounce?.cancel();
                                  setState(() {
                                    _searchText = "";
                                    _selectedCategory = "All";
                                    _selectedLanguage = "All";
                                  });
                                  context.read<ApiProvider>().clearSearch();
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
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

                      if (isSearchingActive) ...[
                        const SizedBox(height: 20),

                        /// Category Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: _categories.map((cat) {
                              final title = cat["title"] as String;
                              final emoji = cat["emoji"] as String;
                              final gradient = cat["gradient"] as Gradient;
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: CategoryCapsule(
                                  title: title,
                                  emoji: emoji,
                                  selected: _selectedCategory == title,
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = title;
                                    });
                                  },
                                  gradient: gradient,
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 14),

                        /// Language Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: _languages.map((lang) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: _languageChip(lang),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// Search Results
                        Consumer<ApiProvider>(
                          builder: (context, api, _) {
                            if (api.isSearching) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: ExploreShimmer(),
                              );
                            }

                            final results = _filteredSearchItems;

                            if (results.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 60,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      size: 60,
                                      color: Colors.white.withValues(alpha: 0.2),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "No results found",
                                      style: GoogleFonts.rajdhani(
                                        color: Colors.white70,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Try adjusting your filters or search term",
                                      style: GoogleFonts.rajdhani(
                                        color: Colors.white38,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${results.length} ${results.length == 1 ? "Result" : "Results"}",
                                  style: GoogleFonts.rajdhani(
                                    color: Colors.white54,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: results.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: size.width * .035,
                                        mainAxisSpacing: size.height * .02,
                                        childAspectRatio: 0.75,
                                      ),
                                  itemBuilder: (context, index) {
                                    final item = results[index];
                                    final cardHeroTag = heroTag(
                                      category: (item["category"] ?? "")
                                          .toString(),
                                      id: index,
                                      prefix: "home_search_grid",
                                    );
                                    return FadeInSlide(
                                      index: index,
                                      child: TrendingCard(
                                        image: (item["image"] ?? "").toString(),
                                        title: (item["title"] ?? "").toString(),
                                        category: (item["category"] ?? "")
                                            .toString(),
                                        rating: (item["rating"] ?? "")
                                            .toString(),
                                        year: (item["year"] ?? "").toString(),
                                        id: index,
                                        tagPrefix: "home_search_grid",
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
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 130),
                      ] else ...[
                        SizedBox(height: size.height * .025),
                        Text(
                          "UNIVERSES",
                          style: GoogleFonts.rajdhani(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),

                        SizedBox(height: size.height * .025),
                        Row(
                          children: [
                            Expanded(
                              child: _universeCard(
                                colors: [Color(0xff7C3AED), Color(0xff3B0764)],
                                glowColor: const Color(0xFF7C3AED),
                                icon: "⚡",
                                fadedIcon: "⚡",
                                title: "Anime",
                                subtitle: getCategoryCount("Anime"),
                                onTap: () {
                                  widget.onOpenExplore("Anime", "Newest");
                                },
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _universeCard(
                                colors: [Color(0xff2563EB), Color(0xff1E3A8A)],

                                glowColor: const Color(0xFF2563EB),
                                icon: "🎬",
                                fadedIcon: "🎬",
                                title: "Movies",

                                subtitle: getCategoryCount("Movies"),
                                onTap: () {
                                  widget.onOpenExplore("Movies", "Newest");
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: _universeCard(
                                colors: [Color(0xffDB2777), Color(0xff831843)],

                                glowColor: const Color(0xFFEC4899),
                                icon: "🌸",
                                fadedIcon: "🌸",

                                title: "K-Drama",
                                subtitle: getCategoryCount("K-Drama"),
                                onTap: () {
                                  widget.onOpenExplore("K-Drama", "Newest");
                                },
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _universeCard(
                                colors: [Color(0xff0891B2), Color(0xff164E63)],

                                glowColor: const Color(0xFF0891B2),
                                icon: "📺",
                                fadedIcon: "📺",

                                title: "Series",
                                subtitle: getCategoryCount("Series"),
                                onTap: () {
                                  widget.onOpenExplore("Series", "Newest");
                                },
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: size.height * .025),
                        Row(
                          children: [
                            Image.asset("assets/images/hik.png", scale: 0.7),

                            SizedBox(width: 5),
                            Text(
                              'TRENDING WORLDS',
                              style: GoogleFonts.rajdhani(
                                fontSize: 15,
                                fontWeight: FontWeight(700),
                                color: Colors.white,
                              ),
                            ),
                            Spacer(),
                            Row(
                              children: [
                                ScaleOnPress(
                                  onTap: () {
                                    widget.onOpenExplore(
                                      "All Universes",
                                      "Newest",
                                    );
                                  },
                                  child: Text(
                                    "See all",
                                    style: GoogleFonts.rajdhani(
                                      color: const Color(0xFFA855F7),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Color(0xFFA855F7),
                                  size: 12,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          height: size.height * .30,
                          child: trending.isEmpty
                              ? ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    right: 8,
                                  ),
                                  clipBehavior: Clip.none,
                                  itemCount: 4,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(width: 14),
                                  itemBuilder: (_, _) {
                                    return const ShimmerBox(
                                      width: 180,
                                      height: double.infinity,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(22),
                                      ),
                                    );
                                  },
                                )
                              : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    right: 8,
                                  ),
                                  clipBehavior: Clip.none,
                                  itemCount: trending.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(width: 14),
                                  itemBuilder: (context, index) {
                                    final item = trending[index];
                                    final cardHeroTag = heroTag(
                                      category: (item["category"] ?? "")
                                          .toString(),
                                      id: index,
                                      prefix: "home_trending",
                                    );
                                    return FadeInSlide(
                                      index: index,
                                      child: TrendingCard(
                                        image: (item["image"] ?? "").toString(),
                                        title: (item["title"] ?? "").toString(),
                                        category: (item["category"] ?? "")
                                            .toString(),
                                        rating: (item["rating"] ?? "")
                                            .toString(),
                                        year: (item["year"] ?? "").toString(),
                                        id: index,
                                        tagPrefix: "home_trending",
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
                        SizedBox(height: size.height * .025),
                        Row(
                          children: [
                            Image.asset("assets/images/play.png", scale: 0.7),
                            SizedBox(width: 5),
                            Text(
                              "NEWLY ADDED",
                              style: GoogleFonts.rajdhani(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight(700),
                                wordSpacing: 2,
                              ),
                            ),
                            Spacer(),
                            Row(
                              children: [
                                ScaleOnPress(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      SlideFadePageRoute(
                                        child: const ExploreScreen(
                                          initialCategory: "All Universes",
                                          initialSort: "Newest",
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "See all",
                                    style: GoogleFonts.rajdhani(
                                      color: const Color(0xFFA855F7),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Color(0xFFA855F7),
                                  size: 12,
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * .025),
                        apiProvider.newReleases.isEmpty
                            ? Container(
                                height: 140,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF15121C),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: .08),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.auto_awesome_rounded,
                                      color: Color(0xFFA855F7),
                                      size: 40,
                                    ),

                                    SizedBox(height: size.height * .025),
                                    Text(
                                      "Nothing Added Yet",
                                      style: GoogleFonts.rajdhani(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      "Explore and add your first title.",
                                      style: GoogleFonts.rajdhani(
                                        color: Colors.white54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                children: apiProvider.newReleases
                                    .take(3)
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                      final index = entry.key;
                                      final item = entry.value;
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 14,
                                        ),
                                        child: FadeInSlide(
                                          index: index,
                                          child: ContinueJourneyCard(
                                            image: (item["image"] ?? "")
                                                .toString(),
                                            title: (item["title"] ?? "")
                                                .toString(),
                                            category: (item["category"] ?? "")
                                                .toString(),
                                            lastOpened: "New Release",
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                SlideFadePageRoute(
                                                  child: ExplorerDetailsScreen(
                                                    item: item,
                                                    heroTag:
                                                        "new_${(item["title"] ?? "").toString()}",
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    })
                                    .toList(),
                              ),
                        const SizedBox(height: 130),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(34),
            topRight: Radius.circular(34),
          ),
        ),
      ),
    );
  }
}

Widget _universeCard({
  required List<Color> colors,
  required Color glowColor,
  required String fadedIcon,
  required String icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return ScaleOnPress(
    onTap: onTap,
    child: SizedBox(
      height: 104,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: colors,
          ),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: .38),
              offset: const Offset(0, 6),
              blurRadius: 24,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Opacity(
                opacity: .08,
                child: Text(fadedIcon, style: const TextStyle(fontSize: 52)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(icon, style: const TextStyle(fontSize: 26)),

                  const Spacer(),

                  Text(
                    title,
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: GoogleFonts.rajdhani(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
