import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/walkin/bloc/create_walkin_event.dart';
import 'package:noq_business/features/walkin/bloc/create_walkin_state.dart';
import 'package:noq_business/features/walkin/repository/walkin_repository.dart';

class CreateWalkinBloc extends Bloc<CreateWalkinEvent, CreateWalkinState> {
  final WalkinRepository _repository;

  CreateWalkinBloc(this._repository) : super(const CreateWalkinInitial()) {
    on<CreateWalkinSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    CreateWalkinSubmitted event,
    Emitter<CreateWalkinState> emit,
  ) async {
    emit(const CreateWalkinLoading());

    try {
      final booking = await _repository.createWalkin(
        customerName: event.customerName,
        customerPhone: event.customerPhone,
        serviceIds: event.serviceIds,
        slotStarts: event.slotStarts,
      );
      emit(CreateWalkinSuccess(booking: booking));
    } on ApiException catch (e) {
      emit(CreateWalkinFailure(message: e.message, code: e.code));
    } catch (e) {
      emit(CreateWalkinFailure(message: e.toString()));
    }
  }
}
