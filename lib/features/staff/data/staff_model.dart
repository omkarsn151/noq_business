import 'package:noq_business/core/models/upload_model.dart';

class StaffServiceRef {
  final String id;
  final String name;

  const StaffServiceRef({required this.id, required this.name});

  factory StaffServiceRef.fromJson(Map<String, dynamic> json) {
    return StaffServiceRef(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class StaffModel {
  final String id;
  final String name;
  final UploadModel? photo;
  final String worksFrom;
  final String worksTo;
  final String? breakStart;
  final String? breakEnd;
  final bool isActive;
  final List<StaffServiceRef> services;

  const StaffModel({
    required this.id,
    required this.name,
    this.photo,
    required this.worksFrom,
    required this.worksTo,
    this.breakStart,
    this.breakEnd,
    required this.isActive,
    required this.services,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] as String,
      name: json['name'] as String,
      photo: json['photo'] != null
          ? UploadModel.fromJson(json['photo'] as Map<String, dynamic>)
          : null,
      worksFrom: json['works_from'] as String,
      worksTo: json['works_to'] as String,
      breakStart: json['break_start'] as String?,
      breakEnd: json['break_end'] as String?,
      isActive: json['is_active'] as bool,
      services: (json['services'] as List? ?? [])
          .map((e) => StaffServiceRef.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
