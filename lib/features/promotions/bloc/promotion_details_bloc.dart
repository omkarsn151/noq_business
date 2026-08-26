import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/promotions/bloc/promotion_details_event.dart';
import 'package:noq_business/features/promotions/bloc/promotion_details_state.dart';
import 'package:noq_business/features/promotions/repository/promotions_repository.dart';

class PromotionDetailsBloc
    extends Bloc<PromotionDetailsEvent, PromotionDetailsState> {
  final PromotionsRepository _repository;

  PromotionDetailsBloc(this._repository)
    : super(const PromotionDetailsInitial()) {
    on<PromotionDetailsRequested>(_onPromotionDetailsRequested);
  }

  Future<void> _onPromotionDetailsRequested(
    PromotionDetailsRequested event,
    Emitter<PromotionDetailsState> emit,
  ) async {
    emit(const PromotionDetailsLoading());
    try {
      final details = await _repository.getPromotionDetails(event.promotionId);
      emit(PromotionDetailsSuccess(details: details));
    } on ApiException catch (e) {
      emit(PromotionDetailsFailure(message: e.message));
    } catch (e) {
      emit(PromotionDetailsFailure(message: e.toString()));
    }
  }
}
