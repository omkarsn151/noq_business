import 'package:equatable/equatable.dart';
import 'package:noq_business/features/walkin/data/walkin_slots_model.dart';

abstract class WalkinSlotsEvent extends Equatable {
  const WalkinSlotsEvent();

  @override
  List<Object?> get props => [];
}

/// First load. No date is sent - the server defaults to the shop's local today
/// and tells us which day that was in `window.selected_date`.
class WalkinSlotsRequested extends WalkinSlotsEvent {
  final List<String> serviceIds;

  const WalkinSlotsRequested(this.serviceIds);

  @override
  List<Object?> get props => [serviceIds];
}

/// Re-run the first load with the same services after a failure.
class WalkinSlotsRetried extends WalkinSlotsEvent {
  const WalkinSlotsRetried();
}

/// A date chip was tapped. Closed days are handled without a request.
class WalkinSlotsDateSelected extends WalkinSlotsEvent {
  final WalkinDate date;

  const WalkinSlotsDateSelected(this.date);

  @override
  List<Object?> get props => [date.date];
}

/// An available chip outside the current run was tapped.
class WalkinSlotStartSelected extends WalkinSlotsEvent {
  final DateTime start;

  const WalkinSlotStartSelected(this.start);

  @override
  List<Object?> get props => [start];
}

/// A chip inside the current run was tapped - drop the highlight.
class WalkinSlotSelectionCleared extends WalkinSlotsEvent {
  const WalkinSlotSelectionCleared();
}
