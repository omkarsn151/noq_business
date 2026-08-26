import 'package:equatable/equatable.dart';

abstract class CreatePromotionState extends Equatable {
  const CreatePromotionState();

  @override
  List<Object?> get props => [];
}

class CreatePromotionInitial extends CreatePromotionState {
  const CreatePromotionInitial();
}

class CreatePromotionLoading extends CreatePromotionState {
  const CreatePromotionLoading();
}

class CreatePromotionSuccess extends CreatePromotionState {
  /// Which action succeeded, so the screen can show the matching dialog.
  final bool published;

  const CreatePromotionSuccess({required this.published});

  @override
  List<Object?> get props => [published];
}

class CreatePromotionFailure extends CreatePromotionState {
  final String message;

  const CreatePromotionFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
