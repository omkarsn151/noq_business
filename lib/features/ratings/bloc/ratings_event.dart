import 'package:equatable/equatable.dart';

abstract class RatingsEvent extends Equatable {
  const RatingsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the first page.
class RatingsRequested extends RatingsEvent {
  const RatingsRequested();
}

/// Clears the list and reloads the first page - the pull to refresh gesture.
class RatingsRefreshRequested extends RatingsEvent {
  const RatingsRefreshRequested();
}

/// Appends the next page to the already loaded reviews.
class RatingsNextPageRequested extends RatingsEvent {
  const RatingsNextPageRequested();
}
