import 'package:equatable/equatable.dart';

abstract class PromotionDetailsEvent extends Equatable {
  const PromotionDetailsEvent();

  @override
  List<Object?> get props => [];
}

class PromotionDetailsRequested extends PromotionDetailsEvent {
  final String promotionId;

  const PromotionDetailsRequested({required this.promotionId});

  @override
  List<Object?> get props => [promotionId];
}
