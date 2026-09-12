import 'package:equatable/equatable.dart';

abstract class BusinessProfileEvent extends Equatable {
  const BusinessProfileEvent();

  @override
  List<Object?> get props => [];
}

class BusinessProfileRequested extends BusinessProfileEvent {
  const BusinessProfileRequested();
}
