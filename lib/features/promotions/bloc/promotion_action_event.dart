import 'package:equatable/equatable.dart';

/// Which quick action was tapped, so the UI can pick the right confirm and
/// toast copy.
enum PromotionActionKind { pause, resume, publish }

abstract class PromotionActionEvent extends Equatable {
  const PromotionActionEvent();

  @override
  List<Object?> get props => [];
}

/// Pause / resume / publish a single promo via `PUT /promos/{id}` without
/// opening the full edit form.
class PromotionActionRequested extends PromotionActionEvent {
  final String promotionId;
  final PromotionActionKind kind;
  final bool? isActive;
  final bool? publish;

  const PromotionActionRequested({
    required this.promotionId,
    required this.kind,
    this.isActive,
    this.publish,
  });

  @override
  List<Object?> get props => [promotionId, kind, isActive, publish];
}
