import 'package:equatable/equatable.dart';
import 'package:noq_business/features/business/data/business_model.dart';

abstract class BusinessState extends Equatable {
  const BusinessState();

  @override
  List<Object?> get props => [];
}

class BusinessInitial extends BusinessState {
  const BusinessInitial();
}

class BusinessLoading extends BusinessState {
  const BusinessLoading();
}

class BusinessLoaded extends BusinessState {
  final BusinessModel business;

  const BusinessLoaded({required this.business});

  @override
  List<Object?> get props => [business];
}

class BusinessFailure extends BusinessState {
  final String message;

  const BusinessFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
