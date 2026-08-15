import 'package:equatable/equatable.dart';

abstract class AddServiceEvent extends Equatable {
  const AddServiceEvent();

  @override
  List<Object?> get props => [];
}

class AddServiceSubmitted extends AddServiceEvent {
  final String name;
  final int durationMinutes;
  final String price;
  final String? subCategoryId;
  final String? description;
  final bool isActive;
  final List<String> thumbnailIds;
  final List<String> bannerIds;

  const AddServiceSubmitted({
    required this.name,
    required this.durationMinutes,
    required this.price,
    this.subCategoryId,
    this.description,
    required this.isActive,
    required this.thumbnailIds,
    this.bannerIds = const [],
  });

  @override
  List<Object?> get props => [
    name,
    durationMinutes,
    price,
    subCategoryId,
    description,
    isActive,
    thumbnailIds,
    bannerIds,
  ];
}

class EditServiceSubmitted extends AddServiceEvent {
  final String serviceId;
  final String name;
  final int durationMinutes;
  final String price;
  final String? subCategoryId;
  final String? description;
  final bool isActive;
  final List<String> thumbnailIds;
  final List<String> bannerIds;

  const EditServiceSubmitted({
    required this.serviceId,
    required this.name,
    required this.durationMinutes,
    required this.price,
    this.subCategoryId,
    this.description,
    required this.isActive,
    required this.thumbnailIds,
    this.bannerIds = const [],
  });

  @override
  List<Object?> get props => [
    serviceId,
    name,
    durationMinutes,
    price,
    subCategoryId,
    description,
    isActive,
    thumbnailIds,
    bannerIds,
  ];
}
