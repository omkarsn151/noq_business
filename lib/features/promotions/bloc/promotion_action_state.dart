import 'package:equatable/equatable.dart';
import 'package:noq_business/features/promotions/bloc/promotion_action_event.dart';

abstract class PromotionActionState extends Equatable {
  const PromotionActionState();

  @override
  List<Object?> get props => [];
}

class PromotionActionInitial extends PromotionActionState {
  const PromotionActionInitial();
}

class PromotionActionInProgress extends PromotionActionState {
  final String promotionId;
  final PromotionActionKind kind;

  const PromotionActionInProgress({
    required this.promotionId,
    required this.kind,
  });

  @override
  List<Object?> get props => [promotionId, kind];
}

class PromotionActionSuccess extends PromotionActionState {
  final String promotionId;
  final PromotionActionKind kind;

  const PromotionActionSuccess({required this.promotionId, required this.kind});

  @override
  List<Object?> get props => [promotionId, kind];
}

class PromotionActionFailure extends PromotionActionState {
  final String message;

  const PromotionActionFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
