import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/walkin/bloc/walkin_slots_event.dart';
import 'package:noq_business/features/walkin/bloc/walkin_slots_state.dart';
import 'package:noq_business/features/walkin/repository/walkin_repository.dart';

class WalkinSlotsBloc extends Bloc<WalkinSlotsEvent, WalkinSlotsState> {
  final WalkinRepository _repository;

  List<String> _serviceIds = const [];

  WalkinSlotsBloc(this._repository) : super(const WalkinSlotsState()) {
    on<WalkinSlotsRequested>(_onRequested);
    on<WalkinSlotsRetried>(_onRetried);
    on<WalkinSlotsDateSelected>(_onDateSelected);
    on<WalkinSlotStartSelected>(_onStartSelected);
    on<WalkinSlotSelectionCleared>(_onSelectionCleared);
  }

  Future<void> _onRequested(
    WalkinSlotsRequested event,
    Emitter<WalkinSlotsState> emit,
  ) async {
    _serviceIds = event.serviceIds;
    await _load(emit);
  }

  Future<void> _onRetried(
    WalkinSlotsRetried event,
    Emitter<WalkinSlotsState> emit,
  ) => _load(emit);

  Future<void> _load(Emitter<WalkinSlotsState> emit) async {
    emit(
      state.copyWith(
        status: WalkinSlotsStatus.loading,
        message: '',
        selectedStart: null,
      ),
    );

    try {
      final model = await _repository.getSlots(serviceIds: _serviceIds);
      emit(
        state.copyWith(
          status: WalkinSlotsStatus.success,
          model: model,
          selectedDate: model.window.selectedDate,
          isTimesLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WalkinSlotsStatus.failure,
          isTimesLoading: false,
          message: _messageOf(e),
        ),
      );
    }
  }

  Future<void> _onDateSelected(
    WalkinSlotsDateSelected event,
    Emitter<WalkinSlotsState> emit,
  ) async {
    final date = event.date.date;
    if (date == state.selectedDate) return;

    // A closed day has no grid to fetch - the UI just says so.
    if (event.date.isClosed) {
      emit(
        state.copyWith(
          selectedDate: date,
          isTimesLoading: false,
          message: '',
          selectedStart: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        selectedDate: date,
        isTimesLoading: true,
        message: '',
        selectedStart: null,
      ),
    );

    try {
      final model = await _repository.getSlots(
        serviceIds: _serviceIds,
        date: date,
      );
      // The clerk may have tapped another chip while this was in flight.
      if (state.selectedDate != date) return;
      emit(
        state.copyWith(
          status: WalkinSlotsStatus.success,
          model: model,
          isTimesLoading: false,
        ),
      );
    } catch (e) {
      if (state.selectedDate != date) return;
      emit(
        state.copyWith(isTimesLoading: false, message: _messageOf(e)),
      );
    }
  }

  void _onStartSelected(
    WalkinSlotStartSelected event,
    Emitter<WalkinSlotsState> emit,
  ) {
    emit(state.copyWith(selectedStart: event.start));
  }

  void _onSelectionCleared(
    WalkinSlotSelectionCleared event,
    Emitter<WalkinSlotsState> emit,
  ) {
    emit(state.copyWith(selectedStart: null));
  }

  String _messageOf(Object error) =>
      error is ApiException ? error.message : error.toString();
}
