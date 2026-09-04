import 'package:equatable/equatable.dart';
import 'package:noq_business/features/profile/data/business_overview_model.dart';

abstract class BusinessProfileState extends Equatable {
  const BusinessProfileState();

  @override
  List<Object?> get props => [];
}

class BusinessProfileInitial extends BusinessProfileState {
  const BusinessProfileInitial();
}

class BusinessProfileLoading extends BusinessProfileState {
  const BusinessProfileLoading();
}

class BusinessProfileSuccess extends BusinessProfileState {
  final BusinessOverviewModel overview;

  const BusinessProfileSuccess({required this.overview});

  @override
  List<Object?> get props => [overview];
}

class BusinessProfileFailure extends BusinessProfileState {
  final String message;

  /// True on a 404 BUSINESS_NOT_FOUND - the owner has no shop yet, so the
  /// screen should point them at Business Setup instead of offering Retry.
  final bool businessNotFound;

  const BusinessProfileFailure({
    required this.message,
    this.businessNotFound = false,
  });

  @override
  List<Object?> get props => [message, businessNotFound];
}
