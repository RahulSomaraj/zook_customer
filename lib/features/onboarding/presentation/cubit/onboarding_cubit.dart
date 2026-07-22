import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'onboarding_state.dart';

/// Tracks the current onboarding page index.
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({required int totalPages})
      : super(OnboardingState(totalPages: totalPages));

  void onPageChanged(int index) => emit(state.copyWith(pageIndex: index));
}
