import 'package:equatable/equatable.dart';
import 'package:noq_business/features/promotions/data/promotion_status.dart';

abstract class PromotionsEvent extends Equatable {
  const PromotionsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the first page of [status]. Already loaded tabs are served from the
/// cached state unless [refresh] is set.
class PromotionsRequested extends PromotionsEvent {
  final PromotionStatus status;
  final bool refresh;

  const PromotionsRequested({required this.status, this.refresh = false});

  @override
  List<Object?> get props => [status, refresh];
}

/// Drops every cached tab and reloads [status]. Used after a promotion is
/// created, since that changes both the lists and the tab counts.
class PromotionsRefreshRequested extends PromotionsEvent {
  final PromotionStatus status;

  const PromotionsRefreshRequested({required this.status});

  @override
  List<Object?> get props => [status];
}

/// Appends the next page of [status] to the already loaded promotions.
class PromotionsNextPageRequested extends PromotionsEvent {
  final PromotionStatus status;

  const PromotionsNextPageRequested({required this.status});

  @override
  List<Object?> get props => [status];
}
