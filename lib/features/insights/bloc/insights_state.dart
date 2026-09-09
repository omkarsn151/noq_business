import 'package:equatable/equatable.dart';
import 'package:noq_business/features/insights/data/insights_model.dart';

abstract class InsightsState extends Equatable {
  /// The selected filter. Carried on every state so the pill keeps its label
  /// while loading and Retry re-fetches the same window.
  final InsightsPeriod period;

  const InsightsState(this.period);

  @override
  List<Object?> get props => [period];
}

class InsightsInitial extends InsightsState {
  const InsightsInitial([super.period = InsightsPeriod.thisWeek]);
}

class InsightsLoading extends InsightsState {
  const InsightsLoading(super.period);
}

class InsightsSuccess extends InsightsState {
  final InsightsModel insights;

  const InsightsSuccess({required this.insights, required InsightsPeriod period})
    : super(period);

  @override
  List<Object?> get props => [insights, period];
}

class InsightsFailure extends InsightsState {
  final String message;

  const InsightsFailure({required this.message, required InsightsPeriod period})
    : super(period);

  @override
  List<Object?> get props => [message, period];
}
