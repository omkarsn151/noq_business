import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/auth/verify_otp/bloc/verify_otp_event.dart';
import 'package:noq_business/features/auth/verify_otp/bloc/verify_otp_state.dart';
import 'package:noq_business/features/auth/verify_otp/reopsitory/verify_otp_repository.dart';

class VerifyOtpBloc extends Bloc<VerifyOtpEvent, VerifyOtpState> {
  final VerifyOtpRepository _repository;

  VerifyOtpBloc(this._repository) : super(const VerifyOtpInitial()) {
    on<VerifyOtpSubmitted>(_onVerifyOtpSubmitted);
  }

  Future<void> _onVerifyOtpSubmitted(
    VerifyOtpSubmitted event,
    Emitter<VerifyOtpState> emit,
  ) async {
    emit(const VerifyOtpLoading());
    try {
      final result = await _repository.verifyOtp(
        phone: event.phone,
        code: event.code,
      );
      emit(
        VerifyOtpSuccess(
          fullName: result.fullName,
          businessStatus: result.businessStatus,
        ),
      );
    } on ApiException catch (e) {
      emit(VerifyOtpFailure(message: e.message));
    } catch (e) {
      emit(VerifyOtpFailure(message: e.toString()));
    }
  }
}
