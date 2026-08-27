import 'package:bucky_verse/widgets/profile/continue_journey.dart';
import 'package:bucky_verse/widgets/profile/journey_stats.dart';
import 'package:bucky_verse/widgets/profile/profilebanneer.dart';
import 'package:bucky_verse/widgets/shimmer/profile_shimmer.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onOpenBucket;

  const ProfileScreen({super.key, this.onOpenBucket});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static bool _hasLoadedOnce = false;
  late bool loading = !_hasLoadedOnce;

  @override
  void initState() {
    super.initState();

    if (loading) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;

        setState(() {
          loading = false;
          _hasLoadedOnce = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF09080F),
      body: SafeArea(
        child: loading
            ? const SingleChildScrollView(child: ProfileShimmer())
            : CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: ProfileBanner()),

                  SliverToBoxAdapter(
                    child: SizedBox(height: size.height * .03),
                  ),

                  const SliverToBoxAdapter(child: JourneyStats()),

                  SliverToBoxAdapter(
                    child: SizedBox(height: size.height * .032),
                  ),

                  SliverToBoxAdapter(
                    child: ContinueJourney(onSeeAll: widget.onOpenBucket),
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(height: size.height * .035),
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(height: size.height * .045),
                  ),
                ],
              ),
      ),
    );
  }
}
