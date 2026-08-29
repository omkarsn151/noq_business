import 'package:equatable/equatable.dart';
import 'package:noq_business/features/walkin/data/walkin_booking_model.dart';

abstract class CreateWalkinState extends Equatable {
  const CreateWalkinState();

  @override
  List<Object?> get props => [];
}

class CreateWalkinInitial extends CreateWalkinState {
  const CreateWalkinInitial();
}

class CreateWalkinLoading extends CreateWalkinState {
  const CreateWalkinLoading();
}

class CreateWalkinSuccess extends CreateWalkinState {
  final WalkinBookingModel booking;

  const CreateWalkinSuccess({required this.booking});

  @override
  List<Object?> get props => [booking.id];
}

class CreateWalkinFailure extends CreateWalkinState {
  final String message;

  /// Server error code, so the screen can tell a stale slot from a bad name.
  final String? code;

  const CreateWalkinFailure({required this.message, this.code});

  /// The chips we sent are no longer usable - make the clerk pick again.
  bool get isSlotStale => const {
    'SLOT_FULL',
    'SLOT_IN_PAST',
    'SLOTS_NOT_CONSECUTIVE',
    'SLOTS_INSUFFICIENT',
    'SLOT_DAY_CLOSED',
    'SLOT_DATE_OUT_OF_WINDOW',
  }.contains(code);

  @override
  List<Object?> get props => [message, code];
}
