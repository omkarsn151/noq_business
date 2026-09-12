import 'package:equatable/equatable.dart';
import 'package:noq_business/features/insights/data/insights_model.dart';

abstract class InsightsEvent extends Equatable {
  const InsightsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the currently selected period.
class InsightsRequested extends InsightsEvent {
  const InsightsRequested();
}

/// Switches the filter and reloads. A tap on the active period is ignored.
class InsightsPeriodChanged extends InsightsEvent {
  final InsightsPeriod period;

  const InsightsPeriodChanged(this.period);

  @override
  List<Object?> get props => [period];
}
