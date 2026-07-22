import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../wishlist/presentation/cubit/wishlist_cubit.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_detail.dart';
import '../cubit/product_detail_cubit.dart';
import '../widgets/grade_badge.dart';
import '../../../../core/widgets/zook_alert.dart';

/// Full product detail screen. Uses the tapped [product] as an instant preview
/// while the full detail loads from `GET /products/{id}`.
class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  void _addToCart(BuildContext context, {bool buyNow = false}) {
    context.read<CartCubit>().add(product);
    if (buyNow) {
      context.push(AppRoute.checkout.path);
    } else {
      showZookAlert(context,
          type: ZookAlertType.success,
          title: 'Added to cart',
          message: 'Item added to your cart.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductDetailCubit(repository: sl())..load(product.id),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: BlocBuilder<ProductDetailCubit, ProductDetailState>(
          builder: (context, state) {
            final d = state.detail;
            // Prefer listing/inspection photos; catalog stock is often a
            // signed URL that can fail. Fall back to list thumbnail.
            final galleryUrls = <String>[
              if (d != null && d.inspectionImages.isNotEmpty)
                ...d.inspectionImages
              else if (d != null && d.heroImageUrl.isNotEmpty)
                d.heroImageUrl
              else if (product.imageUrl.isNotEmpty)
                product.imageUrl,
            ];
            final gradient = d?.imageGradient ?? product.imageGradient;
            final emoji = d?.emoji ?? product.emoji;
            final loading =
                state.status == DetailStatus.loading ||
                state.status == DetailStatus.initial;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _Hero(
                          imageUrls: galleryUrls,
                          emoji: emoji,
                          gradient: gradient,
                          brand: d?.brand ?? product.brand,
                          product: product,
                          showOfficialBadge:
                              d != null && d.inspectionImages.isEmpty,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _brandLine(d),
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 11,
                                      color: AppColors.light,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.successPale,
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                    child: const Text(
                                      '✅ Zook Verified',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF15803D),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                d?.model ?? product.name,
                                style: AppTextStyles.title.copyWith(
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'AED ',
                                      style: AppTextStyles.subtitle.copyWith(
                                        fontSize: 14,
                                        color: AppColors.mid,
                                      ),
                                    ),
                                    TextSpan(
                                      text: formatAmount(
                                        d?.priceAed ?? product.priceAed,
                                      ),
                                      style: AppTextStyles.title.copyWith(
                                        fontSize: 28,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              _ConditionBanner(
                                grade: (d?.grade ?? product.grade).description,
                                note: d?.description,
                                badge: GradeBadge(
                                  grade: d?.grade ?? product.grade,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _DetailReport(detail: d, loading: loading),
                              // Tabby installment section hidden for now.
                              // const SizedBox(height: 14),
                              // _TabbyRow(
                              //     instalment: ((d?.priceAed ?? product.priceAed) /
                              //             4)
                              //         .round()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _StickyCta(
                  product: product,
                  onAddToCart: () => _addToCart(context),
                  onBuyNow: () => _addToCart(context, buyNow: true),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _brandLine(ProductDetail? d) {
    final brand = d?.brand ?? product.brand;
    final year = d?.year;
    return (year != null ? '$brand · $year' : brand).toUpperCase();
  }
}

class _Hero extends StatefulWidget {
  final List<String> imageUrls;
  final String emoji;
  final List<Color> gradient;
  final String brand;
  final Product product;
  final bool showOfficialBadge;
  const _Hero({
    required this.imageUrls,
    required this.emoji,
    required this.gradient,
    required this.brand,
    required this.product,
    this.showOfficialBadge = false,
  });

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> {
  int _page = 0;

  @override
  void didUpdateWidget(covariant _Hero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrls != widget.imageUrls) {
      _page = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    final count = urls.isEmpty ? 1 : urls.length;

    return Column(
      children: [
        SizedBox(
          height: 280,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.gradient,
                    ),
                  ),
                  child: urls.isEmpty
                      ? Center(
                          child: Text(
                            widget.emoji,
                            style: const TextStyle(fontSize: 100),
                          ),
                        )
                      : PageView.builder(
                          itemCount: urls.length,
                          onPageChanged: (i) => setState(() => _page = i),
                          itemBuilder: (_, i) => Image.network(
                            urls[i],
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                widget.emoji,
                                style: const TextStyle(fontSize: 100),
                              ),
                            ),
                            loadingBuilder: (context, child, progress) =>
                                progress == null
                                ? child
                                : Center(
                                    child: Text(
                                      widget.emoji,
                                      style: const TextStyle(fontSize: 100),
                                    ),
                                  ),
                          ),
                        ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _RoundBtn(icon: '←', onTap: () => context.pop()),
                      Row(
                        children: [
                          _RoundBtn(icon: '🔗', onTap: () {}),
                          const SizedBox(width: 8),
                          _RoundBtn(
                            icon:
                                context.watch<WishlistCubit>().isWishlisted(
                                  widget.product.id,
                                )
                                ? '❤️'
                                : '🤍',
                            onTap: () => context.read<WishlistCubit>().toggle(
                              widget.product,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.showOfficialBadge)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      '📸 Official ${widget.brand} photo',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        _PhotoDots(count: count, activeIndex: urls.isEmpty ? 0 : _page),
      ],
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  const _RoundBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(icon, style: const TextStyle(fontSize: 17)),
      ),
    );
  }
}

class _PhotoDots extends StatelessWidget {
  final int count;
  final int activeIndex;
  const _PhotoDots({required this.count, this.activeIndex = 0});

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox(height: 10);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final active = i == activeIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            width: active ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(9999),
            ),
          );
        }),
      ),
    );
  }
}

class _ConditionBanner extends StatelessWidget {
  final String grade;
  final String? note;
  final Widget badge;
  const _ConditionBanner({
    required this.grade,
    required this.note,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          badge,
          const SizedBox(width: 6),
          Text(
            grade,
            style: AppTextStyles.body.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFB45309),
            ),
          ),
          if (note != null && note!.trim().isNotEmpty) ...[
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '· $note',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xCCB45309)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailReport extends StatefulWidget {
  final ProductDetail? detail;
  final bool loading;
  const _DetailReport({required this.detail, required this.loading});

  @override
  State<_DetailReport> createState() => _DetailReportState();
}

class _DetailReportState extends State<_DetailReport> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    final d = widget.detail;

    final rows = <List<String>>[
      if (d?.storageVariant != null) ['Storage', d!.storageVariant!],
      if (d?.color != null) ['Color', d!.color!],
      ['Condition', d?.grade.description ?? '—'],
      [
        'Includes',
        (d?.whatIsIncluded?.trim().isNotEmpty ?? false)
            ? d!.whatIsIncluded!
            : 'Box + cable',
      ],
      if (d?.description?.trim().isNotEmpty ?? false)
        ['Notes', d!.description!],
    ];
    final images = d?.inspectionImages ?? const [];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '📸 Condition photos & report',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Text(
                      '▼',
                      style: TextStyle(fontSize: 14, color: AppColors.light),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_open) ...[
            if (widget.loading)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              )
            else ...[
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                  itemCount: images.isEmpty ? 3 : images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => _InspectionThumb(
                    url: images.isEmpty ? '' : images[i],
                    emoji: d?.emoji ?? '📦',
                    gradient:
                        d?.imageGradient ??
                        const [Color(0xFFF7F7F5), Color(0xFFEBEBEB)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Column(
                  children: [
                    for (final r in rows)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r[0],
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 12,
                                color: AppColors.mid,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                r[1],
                                textAlign: TextAlign.right,
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.charcoal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _InspectionThumb extends StatelessWidget {
  final String url;
  final String emoji;
  final List<Color> gradient;
  const _InspectionThumb({
    required this.url,
    required this.emoji,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 72,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          border: Border.all(color: AppColors.border),
        ),
        child: url.isEmpty
            ? Center(child: Text(emoji, style: const TextStyle(fontSize: 28)))
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 28)),
                ),
              ),
      ),
    );
  }
}

class _TabbyRow extends StatelessWidget {
  final int instalment;
  const _TabbyRow({required this.instalment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            'tabby',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12,
                  color: AppColors.mid,
                ),
                children: [
                  const TextSpan(text: 'Pay '),
                  TextSpan(
                    text: 'AED ${formatAmount(instalment)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const TextSpan(text: ' × 4 monthly · 0% interest'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyCta extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  const _StickyCta({
    required this.product,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.read<WishlistCubit>().toggle(product),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    context.watch<WishlistCubit>().isWishlisted(product.id)
                        ? '❤️'
                        : '🤍',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onAddToCart,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.border, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  child: Text(
                    'Add to cart',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onBuyNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  child: Text(
                    'Buy now',
                    style: AppTextStyles.button.copyWith(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
