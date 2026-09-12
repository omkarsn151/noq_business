import 'package:equatable/equatable.dart';

abstract class CancelReviewEvent extends Equatable {
  const CancelReviewEvent();

  @override
  List<Object?> get props => [];
}

class CancelReviewRequested extends CancelReviewEvent {
  const CancelReviewRequested();
}
