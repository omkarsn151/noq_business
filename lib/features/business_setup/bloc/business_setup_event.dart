import 'package:equatable/equatable.dart';

abstract class BusinessSetupEvent extends Equatable {
  const BusinessSetupEvent();

  @override
  List<Object?> get props => [];
}

class BusinessSetupSubmitted extends BusinessSetupEvent {
  final String name;
  final String categoryId;
  final String addressLine;
  final String city;
  final String state;
  final String postalCode;
  final String description;
  final String gstNumber;
  final List<String> documentIds;

  const BusinessSetupSubmitted({
    required this.name,
    required this.categoryId,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.description,
    required this.gstNumber,
    required this.documentIds,
  });

  @override
  List<Object?> get props => [
    name,
    categoryId,
    addressLine,
    city,
    state,
    postalCode,
    description,
    gstNumber,
    documentIds,
  ];
}
