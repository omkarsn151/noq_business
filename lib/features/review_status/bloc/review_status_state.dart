import 'package:equatable/equatable.dart';
import 'package:noq_business/features/review_status/data/review_status_model.dart';

abstract class ReviewStatusState extends Equatable {
  const ReviewStatusState();

  @override
  List<Object?> get props => [];
}

class ReviewStatusInitial extends ReviewStatusState {
  const ReviewStatusInitial();
}

class ReviewStatusLoading extends ReviewStatusState {
  const ReviewStatusLoading();
}

class ReviewStatusLoaded extends ReviewStatusState {
  final ReviewStatusModel data;

  const ReviewStatusLoaded({required this.data});

  @override
  List<Object?> get props => [data];
}

class ReviewStatusFailure extends ReviewStatusState {
  final String message;

  const ReviewStatusFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
