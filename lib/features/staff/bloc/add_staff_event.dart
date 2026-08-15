import 'package:equatable/equatable.dart';

abstract class AddStaffEvent extends Equatable {
  const AddStaffEvent();

  @override
  List<Object?> get props => [];
}

class AddStaffSubmitted extends AddStaffEvent {
  final String name;
  final String? photoId;
  final String worksFrom;
  final String worksTo;
  final String? breakStart;
  final String? breakEnd;
  final bool isActive;
  final List<String> serviceIds;

  const AddStaffSubmitted({
    required this.name,
    this.photoId,
    required this.worksFrom,
    required this.worksTo,
    this.breakStart,
    this.breakEnd,
    required this.isActive,
    required this.serviceIds,
  });

  @override
  List<Object?> get props => [
    name,
    photoId,
    worksFrom,
    worksTo,
    breakStart,
    breakEnd,
    isActive,
    serviceIds,
  ];
}

class EditStaffSubmitted extends AddStaffEvent {
  final String staffId;
  final String name;
  final String? photoId;
  final String worksFrom;
  final String worksTo;
  final String? breakStart;
  final String? breakEnd;
  final bool isActive;
  final List<String> serviceIds;

  const EditStaffSubmitted({
    required this.staffId,
    required this.name,
    this.photoId,
    required this.worksFrom,
    required this.worksTo,
    this.breakStart,
    this.breakEnd,
    required this.isActive,
    required this.serviceIds,
  });

  @override
  List<Object?> get props => [
    staffId,
    name,
    photoId,
    worksFrom,
    worksTo,
    breakStart,
    breakEnd,
    isActive,
    serviceIds,
  ];
}
