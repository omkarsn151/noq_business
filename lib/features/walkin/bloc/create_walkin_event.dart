import 'package:equatable/equatable.dart';

abstract class CreateWalkinEvent extends Equatable {
  const CreateWalkinEvent();

  @override
  List<Object?> get props => [];
}

class CreateWalkinSubmitted extends CreateWalkinEvent {
  final String customerName;
  final String? customerPhone;
  final List<String> serviceIds;
  final List<DateTime> slotStarts;

  const CreateWalkinSubmitted({
    required this.customerName,
    this.customerPhone,
    required this.serviceIds,
    required this.slotStarts,
  });

  @override
  List<Object?> get props => [
    customerName,
    customerPhone,
    serviceIds,
    slotStarts,
  ];
}
