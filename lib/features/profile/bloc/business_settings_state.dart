import 'package:equatable/equatable.dart';
import 'package:noq_business/features/profile/data/business_settings_model.dart';

enum BusinessSettingsStatus { initial, loading, success, failure }

enum BusinessSettingsSaveStatus { idle, saving, success, failure }

/// Load and save are tracked separately so a failed save leaves the settings
/// already on screen untouched.
class BusinessSettingsState extends Equatable {
  final BusinessSettingsStatus status;
  final BusinessSettingsSaveStatus saveStatus;
  final BusinessSettingsModel model;
  final String message;
  final String saveMessage;

  const BusinessSettingsState({
    this.status = BusinessSettingsStatus.initial,
    this.saveStatus = BusinessSettingsSaveStatus.idle,
    this.model = const BusinessSettingsModel(),
    this.message = '',
    this.saveMessage = '',
  });

  BusinessSettingsState copyWith({
    BusinessSettingsStatus? status,
    BusinessSettingsSaveStatus? saveStatus,
    BusinessSettingsModel? model,
    String? message,
    String? saveMessage,
  }) {
    return BusinessSettingsState(
      status: status ?? this.status,
      saveStatus: saveStatus ?? this.saveStatus,
      model: model ?? this.model,
      message: message ?? this.message,
      saveMessage: saveMessage ?? this.saveMessage,
    );
  }

  @override
  List<Object?> get props => [status, saveStatus, model, message, saveMessage];
}
