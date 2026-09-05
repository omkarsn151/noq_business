import 'package:equatable/equatable.dart';
import 'package:noq_business/features/staff/data/staff_profile_model.dart';

enum StaffDetailsStatus { initial, loading, success, failure }

class StaffDetailsState extends Equatable {
  final StaffDetailsStatus status;

  /// Null until the first load lands. Kept through a failed toggle so the
  /// screen can stay on-screen and show the error as a snackbar instead.
  final StaffProfileModel? profile;

  final String message;

  /// True while the Active PATCH is in flight - the switch is disabled and
  /// already showing the optimistic value.
  final bool isTogglingActive;

  const StaffDetailsState({
    this.status = StaffDetailsStatus.initial,
    this.profile,
    this.message = '',
    this.isTogglingActive = false,
  });

  StaffDetailsState copyWith({
    StaffDetailsStatus? status,
    StaffProfileModel? profile,
    String? message,
    bool? isTogglingActive,
  }) {
    return StaffDetailsState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      message: message ?? this.message,
      isTogglingActive: isTogglingActive ?? this.isTogglingActive,
    );
  }

  @override
  List<Object?> get props => [status, profile, message, isTogglingActive];
}
