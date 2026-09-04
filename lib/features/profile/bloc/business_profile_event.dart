import 'package:equatable/equatable.dart';

abstract class BusinessProfileEvent extends Equatable {
  const BusinessProfileEvent();

  @override
  List<Object?> get props => [];
}

class BusinessProfileRequested extends BusinessProfileEvent {
  /// Set on a pull to refresh, so the loaded content stays on screen while
  /// the new payload is fetched.
  final bool refresh;

  const BusinessProfileRequested({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}
