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

  /// True when this came from editing an existing promo rather than creating one.
  final bool isEdit;

  const CreatePromotionSuccess({required this.published, this.isEdit = false});

  @override
  List<Object?> get props => [published, isEdit];
}

class CreatePromotionFailure extends CreatePromotionState {
  final String message;

  const CreatePromotionFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
