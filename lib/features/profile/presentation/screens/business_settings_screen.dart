import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_appbar.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/core/common/app_snackbar.dart';
import 'package:noq_business/core/common/app_text_field.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/business_setup/data/business_hour_model.dart';
import 'package:noq_business/features/business_setup/presentation/widgets/business_hours_section.dart';
import 'package:noq_business/features/business_setup/presentation/widgets/option_grid.dart';
import 'package:noq_business/features/business_setup/presentation/widgets/option_row.dart';
import 'package:noq_business/features/profile/bloc/business_settings_bloc.dart';
import 'package:noq_business/features/profile/bloc/business_settings_event.dart';
import 'package:noq_business/features/profile/bloc/business_settings_state.dart';
import 'package:noq_business/features/profile/data/business_settings_model.dart';
import 'package:noq_business/features/profile/presentation/widgets/business_settings_loading_widget.dart';

class BusinessSettingsScreen extends StatefulWidget {
  const BusinessSettingsScreen({super.key});

  @override
  State<BusinessSettingsScreen> createState() => _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState extends State<BusinessSettingsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController bookingLimitPerSlotController =
      TextEditingController();
  final TextEditingController cancellationCutOffHoursController =
      TextEditingController();
  final TextEditingController cancellationPercentController =
      TextEditingController();

  bool autoApproval = false;

  final List<(String, int)> bookingBlockOptions = [
    ('15m', 15),
    ('30m', 30),
    ('45m', 45),
    ('60m', 60),
  ];
  int? selectedBookingBlock;

  final List<(String, int)> bufferTimeOptions = [
    ('None', 0),
    ('5m', 5),
    ('10m', 10),
    ('15m', 15),
  ];
  int? selectedBufferTime;

  final List<(String, int)> bookingWindowOptions = [
    ('Same Day', 1),
    ('7 Days', 7),
    ('2 Weeks', 14),
    ('1 Month', 30),
  ];
  int? selectedBookingWindow;

  /// Working days as the API's `day_of_week` values (Sunday 0 … Saturday 6).
  /// One set of hours is shared across every selected day. Defaults to Mon–Fri.
  Set<int> _workingDays = {1, 2, 3, 4, 5};
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 19, minute: 0);
  TimeOfDay? _breakStart;
  TimeOfDay? _breakEnd;

  /// Hours errors stay hidden until the first save attempt.
  bool _hoursValidated = false;

  /// Guards the form against being refilled underneath edits in progress.
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    context.read<BusinessSettingsBloc>().add(const BusinessSettingsRequested());
  }

  @override
  void dispose() {
    bookingLimitPerSlotController.dispose();
    cancellationCutOffHoursController.dispose();
    cancellationPercentController.dispose();
    super.dispose();
  }

  void _reload() {
    context.read<BusinessSettingsBloc>().add(const BusinessSettingsRequested());
  }

  /// Fills the form from the saved settings. Chip selections only take a value
  /// the row can actually show, so an off-list setting leaves the row empty and
  /// asks the owner to pick a supported one rather than saving it back blind.
  void _seedForm(BusinessSettingsModel model) {
    setState(() {
      bookingLimitPerSlotController.text = model.bookingLimitPerSlot.toString();
      cancellationCutOffHoursController.text = model.cancellationCutoffHours
          .toString();
      cancellationPercentController.text = model.lateCancellationFeePercent
          .toString();
      autoApproval = model.autoApproveEnabled;

      selectedBookingBlock = _optionOrNull(
        bookingBlockOptions,
        model.blockMinutes,
      );
      selectedBufferTime = _optionOrNull(
        bufferTimeOptions,
        model.bufferMinutes,
      );
      selectedBookingWindow = _optionOrNull(
        bookingWindowOptions,
        model.bookingWindowDays,
      );

      final workingDays = model.workingDays;
      if (workingDays.isNotEmpty) {
        _workingDays = workingDays;
      }
      _startTime = model.opensAt ?? _startTime;
      _endTime = model.closesAt ?? _endTime;
      _breakStart = model.breakStart;
      _breakEnd = model.breakEnd;

      _hoursValidated = false;
    });
  }

  int? _optionOrNull(List<(String, int)> options, int value) {
    return options.any((option) => option.$2 == value) ? value : null;
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  /// Booking limit must be at least one - the API rejects 0.
  String? _bookingLimitValidator(String? value) {
    final required = _requiredValidator(value, 'Booking Limit');
    if (required != null) return required;
    final limit = int.tryParse(value!.trim());
    if (limit == null || limit < 1) return 'Booking Limit must be at least 1';
    return null;
  }

  /// The API caps the late-cancellation fee at 100%.
  String? _percentValidator(String? value) {
    final required = _requiredValidator(value, 'Cancellation Fee Percent');
    if (required != null) return required;
    final percent = int.tryParse(value!.trim());
    if (percent == null || percent > 100) return 'Enter a percent up to 100';
    return null;
  }

  /// Expands the single working-hours window into the per-day list the API
  /// expects: selected days carry the shared timings, the rest are closed.
  List<BusinessHourModel> _buildHours() {
    return List.generate(7, (day) {
      if (!_workingDays.contains(day)) {
        return BusinessHourModel(dayOfWeek: day, isClosed: true);
      }
      return BusinessHourModel(
        dayOfWeek: day,
        opensAt: _startTime,
        closesAt: _endTime,
        breakStart: _breakStart,
        breakEnd: _breakEnd,
      );
    });
  }

  /// Reports the first business-hours problem, or null when it is valid.
  String? _hoursError() {
    if (_workingDays.isEmpty) {
      return 'Select at least one working day';
    }
    // Validate the shared window once by borrowing a single day's rules.
    return BusinessHourModel(
      dayOfWeek: 1,
      opensAt: _startTime,
      closesAt: _endTime,
      breakStart: _breakStart,
      breakEnd: _breakEnd,
    ).error;
  }

  void _onSavePressed() {
    setState(() => _hoursValidated = true);
    if (_formKey.currentState?.validate() != true) return;

    final missing = <String>[];
    if (selectedBookingBlock == null) missing.add('Booking Block Time');
    if (selectedBufferTime == null) missing.add('Buffer Time');
    if (selectedBookingWindow == null) missing.add('Booking Window');

    if (missing.isNotEmpty) {
      AppSnackbar.error(context, 'Please add: ${missing.join(', ')}');
      return;
    }

    final hoursError = _hoursError();
    if (hoursError != null) {
      AppSnackbar.error(context, hoursError);
      return;
    }

    context.read<BusinessSettingsBloc>().add(
      BusinessSettingsSaveRequested(
        blockMinutes: selectedBookingBlock!,
        bufferMinutes: selectedBufferTime!,
        bookingLimitPerSlot: int.parse(
          bookingLimitPerSlotController.text.trim(),
        ),
        bookingWindowDays: selectedBookingWindow!,
        cancellationCutoffHours: int.parse(
          cancellationCutOffHoursController.text.trim(),
        ),
        lateCancellationFeePercent: int.parse(
          cancellationPercentController.text.trim(),
        ),
        autoApproveEnabled: autoApproval,
        hours: _buildHours(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: 'Settings',
        onLeadingPressed: () => context.pop(),
      ),
      body: SafeArea(
        child: BlocListener<BusinessSettingsBloc, BusinessSettingsState>(
          listener: (context, state) {
            if (state.status == BusinessSettingsStatus.success && !_seeded) {
              _seeded = true;
              _seedForm(state.model);
            }

            if (state.saveStatus == BusinessSettingsSaveStatus.success) {
              _seedForm(state.model);
              AppSnackbar.success(context, state.saveMessage);
            } else if (state.saveStatus == BusinessSettingsSaveStatus.failure) {
              AppSnackbar.error(context, state.saveMessage);
            }
          },
          child: BlocBuilder<BusinessSettingsBloc, BusinessSettingsState>(
            builder: (context, state) => _body(state),
          ),
        ),
      ),
    );
  }

  Widget _body(BusinessSettingsState state) {
    if (!_seeded) {
      if (state.status == BusinessSettingsStatus.failure) {
        return _SettingsMessage(
          title: 'Could not load settings',
          hint: state.message,
          onRetry: _reload,
        );
      }
      if (state.status != BusinessSettingsStatus.success) {
        return const BusinessSettingsLoadingWidget();
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 1.5.h),
              BusinessHoursSection(
                selectedDays: _workingDays,
                startTime: _startTime,
                endTime: _endTime,
                breakStart: _breakStart,
                breakEnd: _breakEnd,
                error: _hoursValidated ? _hoursError() : null,
                onDayToggled: (day) {
                  setState(() {
                    if (!_workingDays.remove(day)) {
                      _workingDays.add(day);
                    }
                  });
                },
                onStartChanged: (time) {
                  setState(() => _startTime = time);
                },
                onEndChanged: (time) {
                  setState(() => _endTime = time);
                },
                onBreakStartChanged: (time) {
                  setState(() => _breakStart = time);
                },
                onBreakEndChanged: (time) {
                  setState(() => _breakEnd = time);
                },
                onAddBreak: () {
                  setState(() {
                    _breakStart = BusinessHourModel.defaultBreakStart;
                    _breakEnd = BusinessHourModel.defaultBreakEnd;
                  });
                },
                onRemoveBreak: () {
                  setState(() {
                    _breakStart = null;
                    _breakEnd = null;
                  });
                },
              ),
              SizedBox(height: 2.h),
              Text(
                'Set Approval Mode',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              SizedBox(height: 0.25.h),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.5.w,
                  vertical: 0.5.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textfieldFilledColor,
                  border: Border.all(color: AppColors.borderLight, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Auto Approval',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Switch(
                      value: autoApproval,
                      onChanged: (value) {
                        setState(() => autoApproval = value);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              AppTextField(
                labelText: 'Booking Limit',
                hintText: 'Booking Limit per slot',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: bookingLimitPerSlotController,
                validator: (value) => _bookingLimitValidator(value),
              ),
              SizedBox(height: 2.h),
              Text(
                'Booking Block Time',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              SizedBox(height: 0.25.h),
              OptionRow(
                options: bookingBlockOptions,
                selected: selectedBookingBlock,
                onSelected: (value) {
                  setState(() => selectedBookingBlock = value);
                },
              ),
              SizedBox(height: 2.h),
              Text(
                'Buffer Time',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              SizedBox(height: 0.25.h),
              OptionRow(
                options: bufferTimeOptions,
                selected: selectedBufferTime,
                onSelected: (value) {
                  setState(() => selectedBufferTime = value);
                },
              ),
              SizedBox(height: 2.h),
              Text(
                'Booking Window',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              SizedBox(height: 0.25.h),
              OptionGrid(
                options: bookingWindowOptions,
                selected: selectedBookingWindow,
                onSelected: (value) {
                  setState(() => selectedBookingWindow = value);
                },
              ),
              SizedBox(height: 2.h),
              AppTextField(
                labelText: 'Cancellation Cutoff Hours',
                hintText: 'Specify Cutoff hours',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: cancellationCutOffHoursController,
                validator: (value) =>
                    _requiredValidator(value, 'Cancellation Cutoff Hours'),
              ),
              SizedBox(height: 2.h),
              AppTextField(
                labelText: 'Cancellation Fee Percent',
                hintText: 'Enter Cancellation %',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: cancellationPercentController,
                validator: (value) => _percentValidator(value),
              ),
              SizedBox(height: 2.5.h),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Save',
                  isLoading:
                      state.saveStatus == BusinessSettingsSaveStatus.saving,
                  onPressed: _onSavePressed,
                ),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsMessage extends StatelessWidget {
  final String title;
  final String hint;
  final VoidCallback onRetry;

  const _SettingsMessage({
    required this.title,
    required this.hint,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => onRetry(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        children: [
          SizedBox(height: 12.h),
          Center(
            child: Container(
              width: 22.w,
              height: 22.w,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                size: 26.sp,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: 0.8.h),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: 1.5.h),
          Center(
            child: TextButton(onPressed: onRetry, child: const Text('Retry')),
          ),
        ],
      ),
    );
  }
}
