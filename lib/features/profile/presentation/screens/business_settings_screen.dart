import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final Set<int> _workingDays = {1, 2, 3, 4, 5};
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 19, minute: 0);
  TimeOfDay? _breakStart;
  TimeOfDay? _breakEnd;

  /// Hours errors stay hidden until the first save attempt.
  bool _hoursValidated = false;

  @override
  void dispose() {
    bookingLimitPerSlotController.dispose();
    cancellationCutOffHoursController.dispose();
    cancellationPercentController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
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

    AppSnackbar.success(context, 'Settings saved');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: 'Settings',
        onLeadingPressed: () => context.pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                      border: Border.all(
                        color: AppColors.borderLight,
                        width: 1.5,
                      ),
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
                    validator: (value) =>
                        _requiredValidator(value, 'Booking Limit'),
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
                    validator: (value) =>
                        _requiredValidator(value, 'Cancellation Fee Percent'),
                  ),
                  SizedBox(height: 2.5.h),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(label: 'Save', onPressed: _onSavePressed),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
