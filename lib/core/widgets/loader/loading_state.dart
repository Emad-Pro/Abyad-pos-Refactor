import 'package:flutter_bloc/flutter_bloc.dart';

class LoadingState {
  final bool isLoading;
  final String? feedback;

  LoadingState({
    this.isLoading = false,
    this.feedback,
  });

  LoadingState copyWith({
    bool? isLoading,
    String? feedback,
    bool clearFeedback = false,
  }) {
    return LoadingState(
      isLoading: isLoading ?? this.isLoading,
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
    );
  }
}
