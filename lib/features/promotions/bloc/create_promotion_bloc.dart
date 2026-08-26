import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/promotions/bloc/create_promotion_event.dart';
import 'package:noq_business/features/promotions/bloc/create_promotion_state.dart';
import 'package:noq_business/features/promotions/repository/promotions_repository.dart';

class CreatePromotionBloc
    extends Bloc<CreatePromotionEvent, CreatePromotionState> {
  final PromotionsRepository _repository;

  CreatePromotionBloc(this._repository)
    : super(const CreatePromotionInitial()) {
    on<CreatePromotionSubmitted>(_onCreatePromotionSubmitted);
  }

  Future<void> _onCreatePromotionSubmitted(
    CreatePromotionSubmitted event,
    Emitter<CreatePromotionState> emit,
  ) async {
    emit(const CreatePromotionLoading());
    try {
      await _repository.createPromotion(
        code: event.code,
        title: event.title,
        description: event.description,
        bannerUploadId: event.bannerUploadId,
        discountType: event.discountType,
        discountValue: event.discountValue,
        minBookingAmount: event.minBookingAmount,
        maxDiscountAmount: event.maxDiscountAmount,
        validFrom: event.validFrom,
        validUntil: event.validUntil,
        totalRedemptionLimit: event.totalRedemptionLimit,
        perCustomerLimit: event.perCustomerLimit,
        publish: event.publish,
      );
      emit(CreatePromotionSuccess(published: event.publish));
    } on ApiException catch (e) {
      emit(CreatePromotionFailure(message: e.message));
    } catch (e) {
      emit(CreatePromotionFailure(message: e.toString()));
    }
  }
}
