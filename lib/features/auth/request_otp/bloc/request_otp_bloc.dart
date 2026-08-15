import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/auth/request_otp/bloc/request_otp_event.dart';
import 'package:noq_business/features/auth/request_otp/bloc/request_otp_state.dart';
import 'package:noq_business/features/auth/request_otp/repository/request_otp_repository.dart';

class RequestOtpBloc extends Bloc<RequestOtpEvent, RequestOtpState> {
  final RequestOtpRepository _repository;

  RequestOtpBloc(this._repository) : super(const RequestOtpInitial()) {
    on<RequestOtpSubmitted>(_onRequestOtpSubmitted);
  }

  Future<void> _onRequestOtpSubmitted(
    RequestOtpSubmitted event,
    Emitter<RequestOtpState> emit,
  ) async {
    emit(const RequestOtpLoading());
    try {
      final expiresAt = await _repository.requestOtp(event.phone);
      emit(RequestOtpSuccess(expiresAt: expiresAt, phone: event.phone));
    } on ApiException catch (e) {
      emit(RequestOtpFailure(message: e.message));
    } catch (e) {
      emit(RequestOtpFailure(message: e.toString()));
    }
  }
}
