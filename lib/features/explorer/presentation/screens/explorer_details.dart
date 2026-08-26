import 'package:bucky_verse/data/media_data.dart';
import 'package:bucky_verse/features/explorer/presentation/screens/explore_screeen.dart';
import 'package:bucky_verse/providers/api_provider.dart';
import 'package:bucky_verse/utils/page_transitions.dart';
import 'package:bucky_verse/widgets/bucket/animated_bucket_button.dart';
import 'package:bucky_verse/widgets/media_image.dart';
import 'package:flutter/material.dart';
import 'package:bucky_verse/widgets/status_selector.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bucky_verse/providers/bucket_provider.dart';
import 'package:bucky_verse/models/bucket_item.dart';

class ExplorerDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final String? heroTag;

  const ExplorerDetailsScreen({super.key, required this.item, this.heroTag});

  @override
  State<ExplorerDetailsScreen> createState() => _ExplorerDetailsScreenState();
}

bool _showFullSynopsis = false;

class _ExplorerDetailsScreenState extends State<ExplorerDetailsScreen> {
  String getStatus() {
    switch (status) {
      case WatchStatus.planning:
        return "Planning";

      case WatchStatus.watching:
        return "Watching";

      case WatchStatus.completed:
        return "Completed";
    }
  }

  WatchStatus status = WatchStatus.planning;

  bool _loaded = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;

      setState(() {
        _loaded = true;
      });
    });
  }

  List<Map<String, dynamic>> get similarItems {
    final List<dynamic> similarIds = widget.item["similar"] ?? [];
    final api = context.read<ApiProvider>();
    final allItems = [...mediaItems, ...api.exploreItems];

    if (similarIds.isNotEmpty) {
      final matches = allItems.where((media) {
        return similarIds
            .map((e) => e.toString())
            .contains(media["id"].toString());
      }).toList();
      if (matches.isNotEmpty) return matches;
    }

    final category = widget.item["category"]?.toString() ?? "";
    final currentId = widget.item["id"]?.toString() ?? "";
    final currentTitle = widget.item["title"]?.toString() ?? "";

    final categoryMatches = api.exploreItems.where((media) {
      final sameCategory = media["category"] == category;
      final isDifferent =
          media["id"].toString() != currentId &&
          media["title"].toString() != currentTitle;
      return sameCategory && isDifferent;
    }).toList();

    if (categoryMatches.isNotEmpty) {
      return categoryMatches.take(10).toList();
    }

    return mediaItems
        .where((media) {
          return media["id"].toString() != currentId &&
              media["title"].toString() != currentTitle;
        })
        .take(6)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    final bucketProvider = context.watch<BucketProvider>();

    final title = (widget.item["title"] ?? "").toString();
    final alreadyAdded = bucketProvider.isAdded(title);

    final bucketItem = bucketProvider.getItem(title);

    final favorite = bucketItem?.isFavorite ?? false;
    final size = MediaQuery.of(context).size;
    final genresData = widget.item["genres"];

    final List<String> genres;

    if (genresData is String) {
      genres = genresData.isEmpty ? [] : genresData.split(",");
    } else if (genresData is List) {
      genres = genresData.map((e) => e.toString()).toList();
    } else {
      genres = [];
    }
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 0, 0, 0),
              Color(0xFF09090B),
              Color(0xFF09090B),
            ],
          ),
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _loaded ? 1 : 0,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: size.height * .38,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                            child:
                                widget.heroTag != null &&
                                    widget.heroTag!.isNotEmpty
                                ? Hero(
                                    tag: widget.heroTag!,
                                    child: MediaImage(
                                      image: (widget.item["image"] ?? "")
                                          .toString(),
                                      width: double.infinity,
                                      height: size.height * .38,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : MediaImage(
                                    image: (widget.item["image"] ?? "")
                                        .toString(),
                                    width: double.infinity,
                                    height: size.height * .38,
                                    fit: BoxFit.cover,
                                  ),
                          ),

                          Container(
                            height: size.height * .38,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color(0x66000000),
                                  Color(0xCC09090B),
                                  Color(0xFF09090B),
                                ],
                              ),
                            ),
                          ),

                          Positioned(
                            top: MediaQuery.of(context).padding.top + 8,
                            left: size.width * .05,
                            child: ScaleOnPress(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: .35),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: .15),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            top: 20,
                            right: 20,
                            child: ScaleOnPress(
                              onTap: () {
                                if (alreadyAdded) {
                                  bucketProvider.toggleFavorite(
                                    widget.item["title"]!,
                                  );
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: .35),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: .15),
                                  ),
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  transitionBuilder: (child, animation) =>
                                      ScaleTransition(
                                        scale: animation,
                                        child: child,
                                      ),
                                  child: Icon(
                                    favorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    key: ValueKey(favorite),
                                    color: favorite
                                        ? const Color(0xFFFF4D6D)
                                        : Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        widget.item["title"]!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * .075,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        "${widget.item["type"]!} • ${widget.item["year"]!}",
                        style: const TextStyle(
                          color: Color(0xFF8B5CF6),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [
                          ...List.generate(
                            5,
                            (_) => const Padding(
                              padding: EdgeInsets.only(right: 2),
                              child: Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFBBF24),
                                size: 18,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Text(
                            widget.item["rating"]!,
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(width: 8),

                          const Text(
                            "•",
                            style: TextStyle(color: Colors.white38),
                          ),

                          const SizedBox(width: 8),

                          Text(
                            widget.item["duration"]!,
                            style: const TextStyle(
                              color: Color(0xFFA78BFA),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ======================
                    // GENRE CHIPS
                    // ======================
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * .045,
                      ),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: genres.map((genre) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1D1521),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: const Color(0xFF4C2A63),
                              ),
                            ),
                            child: Text(
                              genre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ======================
                    // SYNOPSIS
                    // ======================
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "✦ SYNOPSIS",
                        style: TextStyle(
                          color: Color(0xFF8B5CF6),
                          fontSize: 12,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (widget.item["description"] ?? "").toString(),
                            maxLines: _showFullSynopsis ? null : 4,
                            overflow: _showFullSynopsis
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFD4D4D8),
                              fontSize: 14,
                              height: 1.7,
                            ),
                          ),

                          const SizedBox(height: 8),

                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showFullSynopsis = !_showFullSynopsis;
                              });
                            },
                            child: Text(
                              _showFullSynopsis ? "Read Less" : "Read More",
                              style: const TextStyle(
                                color: Color(0xFFA855F7),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ======================
                    // PREMIUM ADD BUTTON
                    // ======================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AnimatedBucketButton(
                        height: size.height * .09,
                        isAdded: alreadyAdded,
                        onTap: () async {
                          if (!alreadyAdded) {
                            await bucketProvider.addItem(
                              BucketItem(
                                id: title,
                                data: widget.item,
                                status: getStatus(),
                                isFavorite: favorite,
                              ),
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ======================
                    // STATUS
                    // ======================
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "✦ STATUS",
                        style: TextStyle(
                          color: Color(0xFF8B5CF6),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: StatusSelector(
                        selectedStatus: bucketItem == null
                            ? status
                            : (() {
                                switch (bucketItem.status) {
                                  case "Watching":
                                    return WatchStatus.watching;
                                  case "Completed":
                                    return WatchStatus.completed;
                                  default:
                                    return WatchStatus.planning;
                                }
                              })(),
                        onChanged: (value) {
                          setState(() {
                            status = value;
                          });

                          bucketProvider.updateItem(
                            widget.item["title"]!,
                            status: getStatus(),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ======================
                    // SIMILAR UNIVERSE
                    // ======================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text(
                            "✦",
                            style: TextStyle(
                              color: Color(0xFF8B5CF6),
                              fontSize: 14,
                            ),
                          ),

                          const Text(
                            " Similar Universe",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),

                          const Spacer(),

                          ScaleOnPress(
                            onTap: () {
                              Navigator.push(
                                context,
                                SlideFadePageRoute(
                                  child: ExploreScreen(
                                    initialCategory: widget.item["category"],
                                    initialSort: "Trending",
                                  ),
                                ),
                              );
                            },
                            child: const Row(
                              children: [
                                Text(
                                  "View All",
                                  style: TextStyle(
                                    color: Color(0xFF8B5CF6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Color(0xFF8B5CF6),
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      height: size.height * .28,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: similarItems.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          return FadeInSlide(
                            index: index,
                            child: ScaleOnPress(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  SlideFadePageRoute(
                                    child: ExplorerDetailsScreen(
                                      item: similarItems[index],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: size.width * .36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF18181B),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(18),
                                            ),
                                        child: MediaImage(
                                          image:
                                              (similarItems[index]["image"] ??
                                                      "")
                                                  .toString(),
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            similarItems[index]["title"],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          const SizedBox(height: 6),

                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                similarItems[index]["rating"],
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
