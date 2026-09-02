import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/dashboard/bloc/dashboard_event.dart';
import 'package:noq_business/features/dashboard/bloc/dashboard_state.dart';
import 'package:noq_business/features/dashboard/repository/dashboard_repository.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repository;

  DashboardBloc(this._repository) : super(const DashboardInitial()) {
    on<DashboardRequested>(_onDashboardRequested);
  }

  Future<void> _onDashboardRequested(
    DashboardRequested event,
    Emitter<DashboardState> emit,
  ) async {
    // On a pull to refresh the RefreshIndicator already shows a spinner, so
    // keep the loaded dashboard on screen instead of flashing back to one.
    if (!(event.refresh && state is DashboardSuccess)) {
      emit(const DashboardLoading());
    }

    try {
      final dashboard = await _repository.getDashboard();
      emit(DashboardSuccess(dashboard: dashboard));
    } on ApiException catch (e) {
      emit(DashboardFailure(message: e.message));
    } catch (e) {
      emit(DashboardFailure(message: e.toString()));
    }
  }
}
