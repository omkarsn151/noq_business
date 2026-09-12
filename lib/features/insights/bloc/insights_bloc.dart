import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/insights/bloc/insights_event.dart';
import 'package:noq_business/features/insights/bloc/insights_state.dart';
import 'package:noq_business/features/insights/data/insights_model.dart';
import 'package:noq_business/features/insights/repository/insights_repository.dart';

class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  final InsightsRepository _repository;

  InsightsPeriod _period = InsightsPeriod.thisWeek;

  InsightsBloc(this._repository) : super(const InsightsInitial()) {
    on<InsightsRequested>(_onRequested);
    on<InsightsPeriodChanged>(_onPeriodChanged);
  }

  Future<void> _onPeriodChanged(
    InsightsPeriodChanged event,
    Emitter<InsightsState> emit,
  ) async {
    if (event.period == _period) return;
    _period = event.period;
    await _load(emit);
  }

  Future<void> _onRequested(
    InsightsRequested event,
    Emitter<InsightsState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<InsightsState> emit) async {
    emit(InsightsLoading(_period));

    try {
      final insights = await _repository.getInsights(period: _period);
      emit(InsightsSuccess(insights: insights, period: _period));
    } on ApiException catch (e) {
      emit(InsightsFailure(message: e.message, period: _period));
    } catch (e) {
      emit(InsightsFailure(message: e.toString(), period: _period));
    }
  }
}
