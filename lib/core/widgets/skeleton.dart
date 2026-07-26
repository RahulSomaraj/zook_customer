import 'package:flutter/material.dart';

const Color _base = Color(0xFFE7E8EA);
const Color _highlight = Color(0xFFF4F5F7);

/// Wraps a tree of [SkeletonBox]es and sweeps a highlight across them.
/// One [Shimmer] drives a whole page's skeleton, so there's a single loader.
class Shimmer extends StatefulWidget {
  final Widget child;
  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [_base, _highlight, _base],
              stops: const [0.35, 0.5, 0.65],
              transform: _SlideTransform(_c.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlideTransform extends GradientTransform {
  final double t;
  const _SlideTransform(this.t);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final dx = (t * 2 - 1) * bounds.width;
    return Matrix4.translationValues(dx, 0, 0);
  }
}

/// A single grey placeholder block.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;
  const SkeletonBox({super.key, this.width, this.height, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _base,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Reusable skeleton bodies (no Shimmer — wrap once at the page level) ──

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SizedBox(
          width: double.infinity,
          child: AspectRatio(aspectRatio: 4 / 3, child: SkeletonBox(radius: 14)),
        ),
        SizedBox(height: 8),
        SkeletonBox(width: 40, height: 8, radius: 4),
        SizedBox(height: 6),
        SkeletonBox(width: double.infinity, height: 11, radius: 4),
        SizedBox(height: 6),
        SkeletonBox(width: 64, height: 13, radius: 4),
      ],
    );
  }
}

class _ProductGridBody extends StatelessWidget {
  final int count;
  final EdgeInsets padding;
  const _ProductGridBody({this.count = 6, this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 16)});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 214,
      ),
      itemBuilder: (_, __) => const _CardSkeleton(),
    );
  }
}

class _ListRowSkeleton extends StatelessWidget {
  const _ListRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: const [
          SkeletonBox(width: 80, height: 80, radius: 12),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 50, height: 8, radius: 4),
                SizedBox(height: 8),
                SkeletonBox(width: double.infinity, height: 12, radius: 4),
                SizedBox(height: 8),
                SkeletonBox(width: 120, height: 10, radius: 4),
                SizedBox(height: 8),
                SkeletonBox(width: 70, height: 14, radius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 2-column product grid skeleton (category browse, product lists).
class ProductGridSkeleton extends StatelessWidget {
  final int count;
  final EdgeInsets padding;
  const ProductGridSkeleton(
      {super.key,
      this.count = 6,
      this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 16)});

  @override
  Widget build(BuildContext context) =>
      Shimmer(child: _ProductGridBody(count: count, padding: padding));
}

/// Vertical list skeleton (search results).
class ProductListSkeleton extends StatelessWidget {
  final int count;
  const ProductListSkeleton({super.key, this.count = 7});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            for (var i = 0; i < count; i++) const _ListRowSkeleton(),
          ],
        ),
      ),
    );
  }
}

/// Home feed content skeleton (category pills + banner + section + grid).
/// The dark header is already loaded, so only this area animates.
class HomeContentSkeleton extends StatelessWidget {
  const HomeContentSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category pills
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: const [
                  SkeletonBox(width: 64, height: 60, radius: 12),
                  SizedBox(width: 8),
                  SkeletonBox(width: 64, height: 60, radius: 12),
                  SizedBox(width: 8),
                  SkeletonBox(width: 64, height: 60, radius: 12),
                  SizedBox(width: 8),
                  SkeletonBox(width: 64, height: 60, radius: 12),
                  SizedBox(width: 8),
                  SkeletonBox(width: 64, height: 60, radius: 12),
                ],
              ),
            ),
            // Promo banner
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SkeletonBox(width: double.infinity, height: 96, radius: 18),
            ),
            // Section header
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonBox(width: 120, height: 16, radius: 4),
                  SkeletonBox(width: 56, height: 12, radius: 4),
                ],
              ),
            ),
            const _ProductGridBody(count: 4),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
