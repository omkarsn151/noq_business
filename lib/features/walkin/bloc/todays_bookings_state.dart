import 'package:equatable/equatable.dart';
import 'package:noq_business/features/walkin/data/todays_bookings_model.dart';

enum TodaysBookingsStatus { initial, loading, success, failure }

class TodaysBookingsState extends Equatable {
  final TodaysBookingsStatus status;
  final TodaysBookingsModel model;
  final String message;

  const TodaysBookingsState({
    this.status = TodaysBookingsStatus.initial,
    this.model = const TodaysBookingsModel(),
    this.message = '',
  });

  TodaysBookingsState copyWith({
    TodaysBookingsStatus? status,
    TodaysBookingsModel? model,
    String? message,
  }) {
    return TodaysBookingsState(
      status: status ?? this.status,
      model: model ?? this.model,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, model, message];
}
