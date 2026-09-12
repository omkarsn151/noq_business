import 'package:equatable/equatable.dart';
import 'package:noq_business/features/staff/data/staff_profile_model.dart';

abstract class StaffDetailsState extends Equatable {
  const StaffDetailsState();

  @override
  List<Object?> get props => [];
}

class StaffDetailsInitial extends StaffDetailsState {
  const StaffDetailsInitial();
}

class StaffDetailsLoading extends StaffDetailsState {
  const StaffDetailsLoading();
}

class StaffDetailsSuccess extends StaffDetailsState {
  final StaffProfileModel profile;

  /// True while the Active PATCH is in flight - the switch is disabled and
  /// already showing the optimistic value.
  final bool isTogglingActive;

  const StaffDetailsSuccess({
    required this.profile,
    this.isTogglingActive = false,
  });

  @override
  List<Object?> get props => [profile, isTogglingActive];
}

class StaffDetailsFailure extends StaffDetailsState {
  final String message;

  /// Set only when a toggle PATCH fails, not on a failed first load - keeps
  /// the profile on screen so the switch can snap back and the error shows
  /// as a snackbar instead of losing the whole page.
  final StaffProfileModel? profile;

  const StaffDetailsFailure({required this.message, this.profile});

  @override
  List<Object?> get props => [message, profile];
}
