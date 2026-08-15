import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/core/services/secure_storage_service.dart';
import 'package:noq_business/features/auth/register/bloc/register_event.dart';
import 'package:noq_business/features/auth/register/bloc/register_state.dart';
import 'package:noq_business/features/auth/register/repository/register_repository.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterRepository _repository;

  RegisterBloc(this._repository) : super(const RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(const RegisterLoading());
    try {
      await _repository.updateName(event.fullName);
      await SecureStorageService().saveFullName(event.fullName);
      emit(const RegisterSuccess());
    } on ApiException catch (e) {
      emit(RegisterFailure(message: e.message));
    } catch (e) {
      emit(RegisterFailure(message: e.toString()));
    }
  }
}
