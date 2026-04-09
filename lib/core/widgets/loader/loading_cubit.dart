import 'package:abyadpos_tab/core/widgets/loader/loading_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoadingCubit extends Cubit<LoadingState> {
  LoadingCubit() : super(LoadingState());

  void showLoading({String? feedback}) {
    emit(state.copyWith(
      isLoading: true,
      feedback: feedback,
    ));
  }

  void hideLoading() {
    emit(state.copyWith(
      isLoading: false,
      clearFeedback: true,
    ));
  }
}
