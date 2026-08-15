import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/core/enums/business_status.dart';
import 'package:noq_business/core/services/secure_storage_service.dart';
import 'package:noq_business/features/business_setup/bloc/business_setup_event.dart';
import 'package:noq_business/features/business_setup/bloc/business_setup_state.dart';
import 'package:noq_business/features/business_setup/repository/business_setup_repository.dart';

class BusinessSetupBloc extends Bloc<BusinessSetupEvent, BusinessSetupState> {
  final BusinessSetupRepository _repository;

  BusinessSetupBloc(this._repository) : super(const BusinessSetupInitial()) {
    on<BusinessSetupSubmitted>(_onBusinessSetupSubmitted);
  }

  Future<void> _onBusinessSetupSubmitted(
    BusinessSetupSubmitted event,
    Emitter<BusinessSetupState> emit,
  ) async {
    emit(const BusinessSetupLoading());
    try {
      await _repository.createBusiness(
        name: event.name,
        categoryId: event.categoryId,
        addressLine: event.addressLine,
        city: event.city,
        state: event.state,
        postalCode: event.postalCode,
        description: event.description,
        gstNumber: event.gstNumber,
        documentIds: event.documentIds,
      );
      await SecureStorageService().saveBusinessStatus(
        BusinessStatus.businessSetup,
      );
      emit(const BusinessSetupSuccess());
    } on ApiException catch (e) {
      emit(BusinessSetupFailure(message: e.message));
    } catch (e) {
      emit(BusinessSetupFailure(message: e.toString()));
    }
  }
}
