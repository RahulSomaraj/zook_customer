import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/onboarding_content.dart';
import '../cubit/onboarding_cubit.dart';
import '../widgets/onboarding_slide.dart';
import '../widgets/page_indicator.dart';

/// 3-slide onboarding carousel.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(totalPages: kOnboardingItems.length),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() => context.go(AppRoute.login.path);

  void _next(OnboardingState state) {
    if (state.isLastPage) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: BlocBuilder<OnboardingCubit, OnboardingState>(
          builder: (context, state) {
            return Column(
              children: [
                // Top bar: step + skip
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${state.pageIndex + 1} of ${state.totalPages}',
                        style: AppTextStyles.caption,
                      ),
                      GestureDetector(
                        onTap: _finish,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPale,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            AppStrings.skip,
                            style: AppTextStyles.label.copyWith(
                              fontSize: 13,
                              letterSpacing: 0,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Slides
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: kOnboardingItems.length,
                    onPageChanged: cubit.onPageChanged,
                    itemBuilder: (_, i) =>
                        OnboardingSlide(item: kOnboardingItems[i]),
                  ),
                ),
                // Dots
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: PageIndicator(
                      count: state.totalPages,
                      activeIndex: state.pageIndex,
                    ),
                  ),
                ),
                // CTA
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: PrimaryButton(
                    label: state.isLastPage
                        ? '${AppStrings.getStarted} 🎉'
                        : AppStrings.next,
                    color: state.isLastPage ? AppColors.black : AppColors.primary,
                    trailing: state.isLastPage
                        ? null
                        : const Icon(Icons.chevron_right,
                            color: AppColors.white, size: 20),
                    onPressed: () => _next(state),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
