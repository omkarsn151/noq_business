import 'package:equatable/equatable.dart';

abstract class RatingsEvent extends Equatable {
  const RatingsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the first page. A cached successful load is reused unless [refresh].
class RatingsRequested extends RatingsEvent {
  final bool refresh;

  const RatingsRequested({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

/// Clears the list and reloads the first page - the pull to refresh gesture.
class RatingsRefreshRequested extends RatingsEvent {
  const RatingsRefreshRequested();
}

/// Appends the next page to the already loaded reviews.
class RatingsNextPageRequested extends RatingsEvent {
  const RatingsNextPageRequested();
}
