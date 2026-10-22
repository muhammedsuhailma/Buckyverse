import 'package:bucky_verse/widgets/shimmer/home_shimmer.dart';
import 'package:bucky_verse/widgets/shimmer/explore_shimmer.dart';
import 'package:bucky_verse/widgets/shimmer/bucket_shimmer.dart';
import 'package:bucky_verse/widgets/shimmer/profile_shimmer.dart';
import 'package:bucky_verse/services/discovery_service.dart';
import 'package:bucky_verse/widgets/discovery/discovery_tip.dart';
import 'package:bucky_verse/providers/api_provider.dart';
import 'package:bucky_verse/providers/bucket_provider.dart';
import 'package:bucky_verse/providers/network_provider.dart';
import 'package:bucky_verse/services/shake_detector.dart';
import 'package:bucky_verse/widgets/bottom_nav.dart';
import 'package:bucky_verse/widgets/network/connection_restored_overlay.dart';
import 'package:bucky_verse/widgets/network/offline_screen.dart';
import 'package:bucky_verse/widgets/refresh/cosmic_refresh_overlay.dart';
import 'package:flutter/material.dart';
import 'package:bucky_verse/screens/home/homescreen.dart';
import 'package:bucky_verse/features/explorer/presentation/screens/explore_screeen.dart';
import 'package:bucky_verse/screens/bucket/bucket_screen.dart';
import 'package:bucky_verse/screens/profile/profile_screen.dart';
import 'package:provider/provider.dart';
// ── In-app updater ────────────────────────────────────────────────────────────
import 'package:bucky_verse/services/update_service.dart';
import 'package:bucky_verse/widgets/update_dialog.dart';
// ─────────────────────────────────────────────────────────────────────────────


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  String _exploreCategory = "All Universes";
  String _exploreSort = "Trending";
  int _exploreNavKey = 0;

  // ── Shake to Refresh ─────────────────────────────────────────────────────
  late ShakeDetector _shakeDetector;
  bool _isRefreshing = false;
  final GlobalKey<_CosmicRefreshWrapperState> _refreshKey = GlobalKey();

  // ── Explore state (held here so shake can call reload) ───────────────────
  String _currentExploreCategory = "All Universes";
  String _currentExploreLanguage = "🌐 All";

  @override
  void initState() {
    super.initState();

    _shakeDetector = ShakeDetector(
      onShake: _onShake,
      threshold: 12.0,
      debounce: const Duration(milliseconds: 1800),
    );
    _shakeDetector.start();

    // ── In-app update check (once per launch, after first frame) ──────────
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  @override
  void dispose() {
    _shakeDetector.stop();
    super.dispose();
  }

  /// Checks for a newer GitHub Release and shows the update dialog if one
  /// is found. Runs at most once per launch (result cached in UpdateService).
  Future<void> _checkForUpdate() async {
    debugPrint('[MainScreen] ▶ _checkForUpdate() entered');
    final info = await UpdateService.instance.checkForUpdate();
    debugPrint(
      '[MainScreen] ◀ checkForUpdate() returned: '
      '${info != null ? "UpdateInfo(v${info.latestVersion})" : "null (no update)"}',
    );
    if (!mounted || info == null) return;
    debugPrint('[MainScreen] Showing update dialog for v${info.latestVersion}');
    showUpdateDialog(context, info);
  }


  void _handleOpenExplore(String category, String sort) {
    setState(() {
      _exploreCategory = category;
      _exploreSort = sort;
      _exploreNavKey++;
      currentIndex = 1;
      _currentExploreCategory = category;
    });
  }

  // ── Screen-specific refresh callbacks ────────────────────────────────────

  Future<void> _refreshCurrentScreen() async {
    final api = context.read<ApiProvider>();
    final bucket = context.read<BucketProvider>();

    switch (currentIndex) {
      case 0: // Home
        await api.loadAll();
        break;

      case 1: // Explore — reload active category/language dataset
        if (_currentExploreLanguage != "🌐 All") {
          final code = _exploreLanguageCode(_currentExploreLanguage);
          if (code.isNotEmpty) {
            await api.fetchLanguageCategoryDataset(
              category: _currentExploreCategory,
              languageCode: code,
            );
          }
        } else {
          switch (_currentExploreCategory) {
            case "Anime":
              await api.loadTopAnime();
              break;
            case "Movies":
              await api.loadTrendingMovies();
              break;
            case "Series":
              await api.loadTrendingSeries();
              break;
            case "K-Drama":
              await api.loadKdramas();
              break;
            default:
              await api.loadAll();
          }
        }
        break;

      case 2: // Bucket
        await bucket.loadBucket();
        break;

      case 3: // Profile — stats driven by bucket
        await bucket.loadBucket();
        break;
    }
  }

  /// Converts explore language label (e.g. "🇮🇳 Hindi") to ISO code ("hi").
  String _exploreLanguageCode(String label) {
    const map = {
      "Hindi": "hi",
      "Malayalam": "ml",
      "Tamil": "ta",
      "Telugu": "te",
      "Korean": "ko",
      "Japanese": "ja",
      "English": "en",
    };
    final parts = label.split(" ");
    final clean = parts.length > 1 ? parts.sublist(1).join(" ") : label;
    return map[clean] ?? "";
  }

  
  Widget _getShimmerForIndex(int index) {
    switch (index) {
      case 0: return const HomeShimmer();
      case 1: return const ExploreShimmer();
      case 2: return const BucketShimmer();
      case 3: return const ProfileShimmer();
      default: return const SizedBox.shrink();
    }
  }

  void _onShake() async {
    // Block while refreshing or offline
    if (_isRefreshing) return;
    if (!mounted) return;
    if (!context.read<NetworkProvider>().isOnline) return;

    setState(() => _isRefreshing = true);
    _shakeDetector.pause();

    // Show the overlay immediately — before the data call starts.
    _refreshKey.currentState?.show();

    try {
      // ── Run refresh + minimum display timer in parallel ──────────────────
      // This guarantees:
      //   • The network request starts at the exact same moment as the animation.
      //   • The overlay stays visible for at least 700ms (premium feel).
      //   • If the request takes longer than 700ms, overlay stays until it finishes.
      await Future.wait([
        _refreshCurrentScreen(),
        Future.delayed(const Duration(milliseconds: 700)),
      ]);
    } catch (e) {
      debugPrint("Shake refresh error: $e");
    } finally {
      // Fade out overlay
      if (mounted) {
        await _refreshKey.currentState?.hide();
        if (mounted) {
          setState(() => _isRefreshing = false);
          _shakeDetector.resume();

          // Show shake discovery tip once
          final shouldTip =
              await DiscoveryService.instance.shouldShowShakeTip();
          if (mounted && shouldTip) {
            await DiscoveryService.instance.markShakeSeen();
            if (mounted) {
              DiscoveryTip.show(
                context,
                emoji: '✨',
                title: 'Cosmic Refresh Activated!',
                body: "You're ready to refresh your universe anytime with a shake.",
              );
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final network = context.watch<NetworkProvider>();

    return Stack(
      children: [
        Scaffold(
          body: Stack(
            children: [
              IndexedStack(
                index: currentIndex,
                children: [
              HomeScreen(onOpenExplore: _handleOpenExplore),
              ExploreScreen(
                key: ValueKey(
                  "explore_${_exploreCategory}_${_exploreSort}_$_exploreNavKey",
                ),
                initialCategory: _exploreCategory,
                initialSort: _exploreSort,
                onCategoryChanged: (cat) => _currentExploreCategory = cat,
                onLanguageChanged: (lang) => _currentExploreLanguage = lang,
              ),
              const BucketScreen(),
              ProfileScreen(
                onOpenBucket: () {
                  setState(() {
                    currentIndex = 2;
                  });
                },
              ),
            ],
              ),
              if (_isRefreshing)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.6,
                      child: _getShimmerForIndex(currentIndex),
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: BuckyBottomNav(
            currentIndex: currentIndex,
            onChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
        ),

        // ── Cosmic Shake-to-Refresh overlay (always above Scaffold) ─────────
        _CosmicRefreshWrapper(key: _refreshKey),

        // ── Offline state overlay ───────────────────────────────────────────
        if (!network.isOnline)
          const Positioned.fill(child: OfflineScreen()),

        // ── Connection Restored animation overlay ───────────────────────────
        if (network.showRestoredAnimation)
          const Positioned.fill(child: ConnectionRestoredOverlay()),
      ],
    );
  }
}

// ── CosmicRefreshWrapper ──────────────────────────────────────────────────────
// A small wrapper that holds the CosmicRefreshOverlay widget in the tree
// (hidden by default) and exposes show/hide methods.

class _CosmicRefreshWrapper extends StatefulWidget {
  const _CosmicRefreshWrapper({super.key});

  @override
  State<_CosmicRefreshWrapper> createState() => _CosmicRefreshWrapperState();
}

class _CosmicRefreshWrapperState extends State<_CosmicRefreshWrapper> {
  bool _visible = false;

  void show() {
    if (!mounted) return;
    setState(() => _visible = true);
  }

  Future<void> hide() async {
    if (!mounted || !_visible) return;
    // CosmicRefreshOverlay handles its own fade-out animation.
    // We just wait a beat then remove it from the tree.
    await Future.delayed(const Duration(milliseconds: 350));
    if (mounted) setState(() => _visible = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return Positioned.fill(
      child: CosmicRefreshOverlay(),
    );
  }
}
