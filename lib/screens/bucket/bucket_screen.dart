import 'package:bucky_verse/features/explorer/presentation/screens/explore_screeen.dart';
import 'package:bucky_verse/features/explorer/presentation/screens/explorer_details.dart';
import 'package:bucky_verse/providers/bucket_provider.dart';
import 'package:bucky_verse/utils/page_transitions.dart';
import 'package:bucky_verse/widgets/bucket/bucket_category_filter.dart';
import 'package:bucky_verse/widgets/bucket/bucket_filter.dart';
import 'package:bucky_verse/widgets/bucket/bucketsearch.dart';
import 'package:bucky_verse/widgets/bucket/bucketstats.dart';
import 'package:bucky_verse/widgets/bucket/media_bucket_card.dart';
import 'package:bucky_verse/widgets/shimmer/bucket_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:bucky_verse/widgets/bucket/bucket_header.dart';
import 'package:provider/provider.dart';

class BucketScreen extends StatefulWidget {
  const BucketScreen({super.key});

  @override
  State<BucketScreen> createState() => _BucketScreenState();
}

class _BucketScreenState extends State<BucketScreen> {
  static bool _hasLoadedOnce = false;
  late bool _isLoading = !_hasLoadedOnce;

  @override
  void initState() {
    super.initState();

    if (_isLoading) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _hasLoadedOnce = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isLoading
            ? const BucketShimmer()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BucketHeader(),

                  if (!keyboardOpen) ...[
                    SizedBox(height: size.height * .03),
                    BucketStats(),
                  ],

                  SizedBox(height: keyboardOpen ? 12 : size.height * .025),

                  BucketSearch(),

                  SizedBox(height: keyboardOpen ? 12 : size.height * .025),

                  BucketFilter(),

                  SizedBox(height: keyboardOpen ? 8 : size.height * .015),

                  BucketCategoryFilter(),

                  SizedBox(height: keyboardOpen ? 12 : size.height * .025),
                  Expanded(
                    child: Consumer<BucketProvider>(
                      builder: (context, provider, child) {
                        if (provider.filteredItems.isEmpty) {
                          if (provider.isSearching) {
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: constraints.maxHeight,
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.search_off_rounded,
                                            color: const Color(0xFFA855F7),
                                            size: keyboardOpen
                                                ? size.width * .11
                                                : size.width * .18,
                                          ),

                                          SizedBox(
                                            height: keyboardOpen ? 12 : 18,
                                          ),

                                          Text(
                                            "No Results Found",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: keyboardOpen ? 18 : 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          if (!keyboardOpen) ...[
                                            const SizedBox(height: 10),

                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 40,
                                              ),
                                              child: Text(
                                                "Try another title or clear your search.",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 14,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }

                          if (keyboardOpen) {
                            return const SizedBox.shrink();
                          }

                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  size: size.width * .18,
                                  color: Colors.deepPurple.withValues(
                                    alpha: .7,
                                  ),
                                ),

                                const SizedBox(height: 18),

                                const Text(
                                  "Your Bucket is Empty",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 40),
                                  child: Text(
                                    "Start exploring Anime, Movies, Series and K-Dramas.\nAdd your favorites to build your universe.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white54,
                                      height: 1.5,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 30),

                                ScaleOnPress(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      SlideFadePageRoute(
                                        child: const ExploreScreen(),
                                      ),
                                    );
                                  },
                                  child: IgnorePointer(
                                    child: ElevatedButton.icon(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFA855F7,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(Icons.explore_rounded),
                                      label: const Text("Explore Now"),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: EdgeInsets.only(bottom: size.height * .025),
                          itemCount: provider.filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = provider.filteredItems[index];

                            return Dismissible(
                              key: ValueKey(item.id),
                              direction: DismissDirection.endToStart,

                              background: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: size.width * .05,
                                  vertical: size.height * .012,
                                ),
                                padding: const EdgeInsets.only(right: 28),
                                alignment: Alignment.centerRight,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 193, 0, 42),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.delete_rounded,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Delete",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              confirmDismiss: (_) async {
                                return await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        backgroundColor: const Color(
                                          0xFF17141F,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        title: const Text(
                                          "Remove Item?",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        content: const Text(
                                          "Do you want to remove this item from your bucket?",
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text("Cancel"),
                                          ),
                                          FilledButton(
                                            style: FilledButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      ),
                                    ) ??
                                    false;
                              },

                              onDismissed: (_) {
                                final deletedItem = item;

                                provider.removeItem(deletedItem.id);

                                ScaffoldMessenger.of(context).clearSnackBars();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: const Color(0xFF1A1524),
                                    duration: const Duration(seconds: 4),

                                    content: Text(
                                      "${deletedItem.data["title"]} removed",
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    action: SnackBarAction(
                                      label: "UNDO",
                                      textColor: const Color(0xFFA855F7),
                                      onPressed: () {
                                        provider.addItem(deletedItem);
                                      },
                                    ),
                                  ),
                                );
                              },

                              child: MediaBucketCard(
                                title: (item.data["title"] ?? "").toString(),
                                image: (item.data["image"] ?? "").toString(),
                                type:
                                    (item.data["type"] ??
                                            item.data["category"] ??
                                            "")
                                        .toString(),
                                rating: (item.data["rating"] ?? "0.0")
                                    .toString(),
                                year: (item.data["year"] ?? "").toString(),
                                progress: 0,
                                status: item.status,
                                accentColor: getAccentColor(item.status),

                                onTap: () {
                                  Navigator.push(
                                    context,
                                    SlideFadePageRoute(
                                      child: ExplorerDetailsScreen(
                                        item: item.data,
                                        heroTag: (item.data["title"] ?? "")
                                            .toString(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
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

Color getAccentColor(String status) {
  switch (status) {
    case "Planning":
      return const Color(0xFFA855F7);

    case "Watching":
      return const Color(0xFF06B6D4);

    case "Completed":
      return const Color(0xFF22C55E);

    case "Favorites":
      return const Color(0xFFEC4899);

    default:
      return const Color(0xFFA855F7);
  }
}
