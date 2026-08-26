import 'package:equatable/equatable.dart';
import 'package:noq_business/features/promotions/data/promotion_details_model.dart';

abstract class PromotionDetailsState extends Equatable {
  const PromotionDetailsState();

  @override
  List<Object?> get props => [];
}

class PromotionDetailsInitial extends PromotionDetailsState {
  const PromotionDetailsInitial();
}

class PromotionDetailsLoading extends PromotionDetailsState {
  const PromotionDetailsLoading();
}

class PromotionDetailsSuccess extends PromotionDetailsState {
  final PromotionDetailsModel details;

  const PromotionDetailsSuccess({required this.details});

  @override
  List<Object?> get props => [details];
}

class PromotionDetailsFailure extends PromotionDetailsState {
  final String message;

  const PromotionDetailsFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
