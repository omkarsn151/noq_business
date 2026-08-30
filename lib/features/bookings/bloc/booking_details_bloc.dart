import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/bookings/bloc/booking_details_event.dart';
import 'package:noq_business/features/bookings/bloc/booking_details_state.dart';
import 'package:noq_business/features/bookings/repository/bookings_repository.dart';

class BookingDetailsBloc
    extends Bloc<BookingDetailsEvent, BookingDetailsState> {
  final BookingsRepository _repository;

  BookingDetailsBloc(this._repository) : super(const BookingDetailsInitial()) {
    on<BookingDetailsRequested>(_onBookingDetailsRequested);
  }

  Future<void> _onBookingDetailsRequested(
    BookingDetailsRequested event,
    Emitter<BookingDetailsState> emit,
  ) async {
    emit(const BookingDetailsLoading());
    try {
      final details = await _repository.getBookingDetails(event.bookingId);
      emit(BookingDetailsSuccess(details: details));
    } on ApiException catch (e) {
      emit(BookingDetailsFailure(message: e.message));
    } catch (e) {
      emit(BookingDetailsFailure(message: e.toString()));
    }
  }
}
