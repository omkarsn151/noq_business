import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/bookings/bloc/booking_action_event.dart';
import 'package:noq_business/features/bookings/bloc/booking_action_state.dart';
import 'package:noq_business/features/bookings/repository/bookings_repository.dart';

/// Drives the unified `POST /business/bookings/{id}/actions` endpoint for both
/// the bookings list and the details screen.
class BookingActionBloc extends Bloc<BookingActionEvent, BookingActionState> {
  final BookingsRepository _repository;

  BookingActionBloc(this._repository) : super(const BookingActionInitial()) {
    on<BookingActionRequested>(_onBookingActionRequested);
  }

  Future<void> _onBookingActionRequested(
    BookingActionRequested event,
    Emitter<BookingActionState> emit,
  ) async {
    emit(
      BookingActionInProgress(
        bookingId: event.bookingId,
        action: event.action,
      ),
    );

    try {
      final result = await _repository.performAction(
        bookingId: event.bookingId,
        action: event.action,
        reason: event.reason,
        verificationCode: event.verificationCode,
        slots: event.slots,
        staffId: event.staffId,
      );
      emit(
        BookingActionSuccess(
          bookingId: event.bookingId,
          action: event.action,
          message: result.message.isEmpty
              ? event.action.successMessage
              : result.message,
        ),
      );
    } on ApiException catch (e) {
      // The server sends the useful copy here - 'Cannot start a booking that
      // is not confirmed.' beats anything the app could invent.
      emit(BookingActionFailure(message: e.message));
    } catch (e) {
      emit(BookingActionFailure(message: e.toString()));
    }
    // Reset so an identical follow-up action still produces a fresh state
    // transition that listeners can react to.
    emit(const BookingActionInitial());
  }
}
