import 'package:equatable/equatable.dart';
import 'package:noq_business/features/bookings/data/booking_detail_model.dart';

abstract class BookingDetailsState extends Equatable {
  const BookingDetailsState();

  @override
  List<Object?> get props => [];
}

class BookingDetailsInitial extends BookingDetailsState {
  const BookingDetailsInitial();
}

class BookingDetailsLoading extends BookingDetailsState {
  const BookingDetailsLoading();
}

class BookingDetailsSuccess extends BookingDetailsState {
  final BookingDetailModel details;

  const BookingDetailsSuccess({required this.details});

  @override
  List<Object?> get props => [details];
}

class BookingDetailsFailure extends BookingDetailsState {
  final String message;

  const BookingDetailsFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
