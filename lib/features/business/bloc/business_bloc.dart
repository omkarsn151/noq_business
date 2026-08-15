import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/business/bloc/business_event.dart';
import 'package:noq_business/features/business/bloc/business_state.dart';
import 'package:noq_business/features/business/repository/business_repository.dart';

class BusinessBloc extends Bloc<BusinessEvent, BusinessState> {
  final BusinessRepository _repository;

  BusinessBloc(this._repository) : super(const BusinessInitial()) {
    on<BusinessRequested>(_onBusinessRequested);
  }

  Future<void> _onBusinessRequested(
    BusinessRequested event,
    Emitter<BusinessState> emit,
  ) async {
    emit(const BusinessLoading());
    try {
      final business = await _repository.getBusiness();
      emit(BusinessLoaded(business: business));
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        emit(const BusinessInitial());
      } else {
        emit(BusinessFailure(message: e.message));
      }
    } catch (e) {
      emit(BusinessFailure(message: e.toString()));
    }
  }
}
