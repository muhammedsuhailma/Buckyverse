import 'package:bucky_verse/features/explorer/presentation/screens/explorer_details.dart';
import 'package:bucky_verse/providers/api_provider.dart';
import 'package:bucky_verse/utils/page_transitions.dart';
import 'package:bucky_verse/widgets/media_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  String selectedFilter = "All";
  final Map<String, IconData> filterIcons = {
    "All": Icons.grid_view_rounded,
    "Trending": Icons.local_fire_department_rounded,
    "Anime": Icons.catching_pokemon,
    "Movies": Icons.movie_creation_outlined,
    "Series": Icons.tv_rounded,
    "K-Drama": Icons.favorite_rounded,
    "Action": Icons.flash_on_rounded,
    "Adventure": Icons.explore_rounded,
    "Comedy": Icons.sentiment_very_satisfied_rounded,
    "Drama": Icons.theater_comedy_rounded,
    "Fantasy": Icons.auto_awesome,
    "Romance": Icons.favorite_border,
    "Sci-Fi": Icons.rocket_launch_rounded,
    "Thriller": Icons.warning_amber_rounded,
    "Horror": Icons.nightlight_round,
    "Mystery": Icons.search_rounded,
    "Crime": Icons.gavel_rounded,
    "Family": Icons.family_restroom_rounded,
    "Top Rated": Icons.star_rounded,
    "New": Icons.fiber_new_rounded,
  };
  final List<String> filters = [
    "All",
    "Trending",
    "Anime",
    "Movies",
    "Series",
    "K-Drama",
    "Action",
    "Adventure",
    "Comedy",
    "Drama",
    "Fantasy",
    "Romance",
    "Sci-Fi",
    "Thriller",
    "Horror",
    "Mystery",
    "Crime",
    "Family",
    "Top Rated",
    "New",
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final api = context.watch<ApiProvider>();
    List<Map<String, dynamic>> items = api.searchItems;

    switch (selectedFilter) {
      case "All":
        items = api.searchItems;
        break;

      case "Anime":
        items = api.searchAnime;
        break;

      case "Movies":
        items = api.searchMovies;
        break;

      case "Series":
        items = api.searchSeries;
        break;

      case "K-Drama":
        items = api.searchKdramas;
        break;

      case "Trending":
        items = api.searchItems;
        break;

      case "Top Rated":
        items = [...api.searchItems];
        items.sort(
          (a, b) => (double.tryParse(b["rating"]?.toString() ?? "") ?? 0.0)
              .compareTo(double.tryParse(a["rating"]?.toString() ?? "") ?? 0.0),
        );
        break;

      case "New":
        items = [...api.searchItems];
        items.sort(
          (a, b) => (int.tryParse(b["year"]?.toString() ?? "") ?? 0).compareTo(
            int.tryParse(a["year"]?.toString() ?? "") ?? 0,
          ),
        );
        break;

      default:
        items = api.searchItems.where((item) {
          final genres = item["genres"].toString().toLowerCase();

          return genres.contains(selectedFilter.toLowerCase());
        }).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF09080F),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: ScaleOnPress(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          "Search",
          style: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF17111F),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: .06)),
              ),
              child: TextField(
                controller: searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),

                onChanged: (value) {
                  context.read<ApiProvider>().searchAll(value);
                },
                decoration: InputDecoration(
                  border: InputBorder.none,

                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF8B5CF6),
                  ),

                  hintText: "Search anime, movies, series...",
                  hintStyle: GoogleFonts.rajdhani(
                    color: Colors.white38,
                    fontSize: 17,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final selected = filter == selectedFilter;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF8B5CF6)
                            : const Color(0xFF17111F),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: selected
                              ? Colors.transparent
                              : Colors.white.withValues(alpha: .08),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            filterIcons[filter],
                            size: 16,
                            color: selected ? Colors.white : Colors.white70,
                          ),

                          const SizedBox(width: 6),

                          Text(
                            filter,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 15),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${items.length} Results",
                style: GoogleFonts.rajdhani(
                  color: Colors.white54,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),
            Expanded(
              child: api.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xff8B5CF6),
                      ),
                    )
                  : items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 70,
                            color: Colors.white.withValues(alpha: .15),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Search Your Universe",
                            style: GoogleFonts.orbitron(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Anime • Movies • Series • K-Drama",
                            style: GoogleFonts.rajdhani(
                              color: Colors.white38,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = items[index];

                        return FadeInSlide(
                          index: index,
                          child: ScaleOnPress(
                            onTap: () {
                              final itemTitle = (item["title"] ?? "")
                                  .toString();
                              final heroTag = "search_$itemTitle";
                              Navigator.push(
                                context,
                                SlideFadePageRoute(
                                  child: ExplorerDetailsScreen(
                                    item: item,
                                    heroTag: heroTag,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF17111F),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: .05),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Hero(
                                    tag:
                                        "search_${(item["title"] ?? "").toString()}",
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: MediaImage(
                                        image: (item["image"] ?? "").toString(),
                                        width: 55,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item["title"],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.rajdhani(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(height: 6),

                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xff8B5CF6),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                item["category"],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: 8),

                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.amber.withValues(alpha: 
                                                  .15,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    item["rating"].toString(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 6),

                                        Text(
                                          item["genres"] ?? "",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.rajdhani(
                                            color: Colors.white38,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.white38,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
