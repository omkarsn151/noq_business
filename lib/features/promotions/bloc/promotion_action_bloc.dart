import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/promotions/bloc/promotion_action_event.dart';
import 'package:noq_business/features/promotions/bloc/promotion_action_state.dart';
import 'package:noq_business/features/promotions/repository/promotions_repository.dart';

class PromotionActionBloc
    extends Bloc<PromotionActionEvent, PromotionActionState> {
  final PromotionsRepository _repository;

  PromotionActionBloc(this._repository)
    : super(const PromotionActionInitial()) {
    on<PromotionActionRequested>(_onPromotionActionRequested);
  }

  Future<void> _onPromotionActionRequested(
    PromotionActionRequested event,
    Emitter<PromotionActionState> emit,
  ) async {
    emit(
      PromotionActionInProgress(
        promotionId: event.promotionId,
        kind: event.kind,
      ),
    );
    try {
      await _repository.setPromotionState(
        id: event.promotionId,
        isActive: event.isActive,
        publish: event.publish,
      );
      emit(
        PromotionActionSuccess(
          promotionId: event.promotionId,
          kind: event.kind,
        ),
      );
    } on ApiException catch (e) {
      emit(PromotionActionFailure(message: e.message));
    } catch (e) {
      emit(PromotionActionFailure(message: e.toString()));
    }
    // Reset so an identical follow-up action still produces a fresh state
    // transition that listeners can react to.
    emit(const PromotionActionInitial());
  }
}
