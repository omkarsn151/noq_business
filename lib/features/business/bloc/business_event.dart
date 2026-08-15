import 'package:equatable/equatable.dart';

abstract class BusinessEvent extends Equatable {
  const BusinessEvent();

  @override
  List<Object?> get props => [];
}

class BusinessRequested extends BusinessEvent {
  const BusinessRequested();
}
