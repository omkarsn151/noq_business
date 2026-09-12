import 'package:equatable/equatable.dart';

abstract class CancelReviewState extends Equatable {
  const CancelReviewState();

  @override
  List<Object?> get props => [];
}

class CancelReviewInitial extends CancelReviewState {
  const CancelReviewInitial();
}

class CancelReviewLoading extends CancelReviewState {
  const CancelReviewLoading();
}

class CancelReviewSuccess extends CancelReviewState {
  const CancelReviewSuccess();
}

class CancelReviewFailure extends CancelReviewState {
  final String message;

  const CancelReviewFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
