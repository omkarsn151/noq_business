import 'package:equatable/equatable.dart';

abstract class ReviewStatusEvent extends Equatable {
  const ReviewStatusEvent();

  @override
  List<Object?> get props => [];
}

class ReviewStatusRequested extends ReviewStatusEvent {
  const ReviewStatusRequested();
}
