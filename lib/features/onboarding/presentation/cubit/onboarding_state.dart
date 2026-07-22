part of 'onboarding_cubit.dart';

class OnboardingState extends Equatable {
  final int pageIndex;
  final int totalPages;

  const OnboardingState({this.pageIndex = 0, required this.totalPages});

  bool get isLastPage => pageIndex == totalPages - 1;

  OnboardingState copyWith({int? pageIndex}) => OnboardingState(
        pageIndex: pageIndex ?? this.pageIndex,
        totalPages: totalPages,
      );

  @override
  List<Object?> get props => [pageIndex, totalPages];
}
