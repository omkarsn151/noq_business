import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/walkin/bloc/todays_bookings_event.dart';
import 'package:noq_business/features/walkin/bloc/todays_bookings_state.dart';
import 'package:noq_business/features/walkin/repository/walkin_repository.dart';

class TodaysBookingsBloc
    extends Bloc<TodaysBookingsEvent, TodaysBookingsState> {
  final WalkinRepository _repository;

  TodaysBookingsBloc(this._repository) : super(const TodaysBookingsState()) {
    on<TodaysBookingsRequested>(_onRequested);
  }

  Future<void> _onRequested(
    TodaysBookingsRequested event,
    Emitter<TodaysBookingsState> emit,
  ) async {
    emit(state.copyWith(status: TodaysBookingsStatus.loading, message: ''));

    try {
      final model = await _repository.getTodaysBookings();
      emit(
        state.copyWith(status: TodaysBookingsStatus.success, model: model),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TodaysBookingsStatus.failure,
          message: _messageOf(e),
        ),
      );
    }
  }

  String _messageOf(Object error) =>
      error is ApiException ? error.message : error.toString();
}
