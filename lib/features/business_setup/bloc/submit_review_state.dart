import 'package:equatable/equatable.dart';

abstract class SubmitReviewState extends Equatable {
  const SubmitReviewState();

  @override
  List<Object?> get props => [];
}

class SubmitReviewInitial extends SubmitReviewState {
  const SubmitReviewInitial();
}

class SubmitReviewLoading extends SubmitReviewState {
  const SubmitReviewLoading();
}

class SubmitReviewSuccess extends SubmitReviewState {
  const SubmitReviewSuccess();
}

class SubmitReviewFailure extends SubmitReviewState {
  final String message;

  const SubmitReviewFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
