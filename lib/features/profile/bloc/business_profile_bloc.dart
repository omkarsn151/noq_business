import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/profile/bloc/business_profile_event.dart';
import 'package:noq_business/features/profile/bloc/business_profile_state.dart';
import 'package:noq_business/features/profile/repository/business_profile_repository.dart';

class BusinessProfileBloc
    extends Bloc<BusinessProfileEvent, BusinessProfileState> {
  final BusinessProfileRepository _repository;

  BusinessProfileBloc(this._repository)
    : super(const BusinessProfileInitial()) {
    on<BusinessProfileRequested>(_onBusinessProfileRequested);
  }

  Future<void> _onBusinessProfileRequested(
    BusinessProfileRequested event,
    Emitter<BusinessProfileState> emit,
  ) async {
    emit(const BusinessProfileLoading());

    try {
      final overview = await _repository.getBusinessOverview();
      emit(BusinessProfileSuccess(overview: overview));
    } on ApiException catch (e) {
      emit(
        BusinessProfileFailure(
          message: e.message,
          businessNotFound: e.statusCode == 404,
        ),
      );
    } catch (e) {
      emit(BusinessProfileFailure(message: e.toString()));
    }
  }
}
