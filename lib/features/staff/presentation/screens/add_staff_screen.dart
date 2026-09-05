import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/core/common/app_alert_dialog.dart';
import 'package:noq_business/core/common/app_appbar.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/core/common/app_snackbar.dart';
import 'package:noq_business/core/common/app_text_field.dart';
import 'package:noq_business/core/services/image_picker_service.dart';
import 'package:noq_business/core/services/upload_service.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/business_setup/presentation/widgets/upload_slot_field.dart';
import 'package:noq_business/features/service/bloc/service_bloc.dart';
import 'package:noq_business/features/service/bloc/service_event.dart';
import 'package:noq_business/features/service/bloc/service_state.dart';
import 'package:noq_business/features/service/data/service_model.dart';
import 'package:noq_business/features/service/presentation/widgets/add_service_tile.dart';
import 'package:noq_business/features/service/presentation/widgets/service_selection_bottom_sheet.dart';
import 'package:noq_business/features/service/presentation/widgets/service_tile.dart';
import 'package:noq_business/features/staff/bloc/add_staff_bloc.dart';
import 'package:noq_business/features/staff/bloc/add_staff_event.dart';
import 'package:noq_business/features/staff/bloc/add_staff_state.dart';
import 'package:noq_business/features/staff/bloc/staff_bloc.dart';
import 'package:noq_business/features/staff/bloc/staff_event.dart';
import 'package:noq_business/features/staff/bloc/staff_state.dart';
import 'package:noq_business/features/staff/data/staff_model.dart';

class _UploadSlotState {
  final UploadSlotStatus status;
  final String? fileId;
  final String? fileName;
  final String? errorMessage;
  final File? previewFile;
  final String? previewUrl;

  const _UploadSlotState({
    this.status = UploadSlotStatus.idle,
    this.fileId,
    this.fileName,
    this.errorMessage,
    this.previewFile,
    this.previewUrl,
  });

  bool get isUploaded => status == UploadSlotStatus.uploaded && fileId != null;
}

class AddStaffScreen extends StatefulWidget {
  final StaffModel? staff;

  const AddStaffScreen({super.key, this.staff});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isActive = true;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController worksFromController = TextEditingController();
  final TextEditingController worksToController = TextEditingController();
  final TextEditingController breakStartController = TextEditingController();
  final TextEditingController breakEndController = TextEditingController();

  TimeOfDay? _worksFrom;
  TimeOfDay? _worksTo;
  TimeOfDay? _breakStart;
  TimeOfDay? _breakEnd;
  List<ServiceModel> _selectedServices = [];

  final _uploadService = UploadService();
  final _imagePickerService = ImagePickerService();
  var _photoSlot = const _UploadSlotState();

  bool get _isEditing => widget.staff != null;
  bool _timeControllersInitialized = false;

  /// True once the assigned services have been matched against the master
  /// list - guards the [ServiceBloc] listener so a later refetch (e.g. from
  /// the service picker) doesn't wipe out the owner's in-progress selection.
  bool _initialServicesResolved = false;

  /// True once the delete flow is confirmed and dispatched, so the
  /// [StaffBloc] listener knows to act on the next success/failure.
  bool _isDeleting = false;

  /// Keys for the break fields so a pick can re-validate just those, without
  /// flagging untouched fields like Name.
  final _breakStartFieldKey = GlobalKey<FormFieldState<String>>();
  final _breakEndFieldKey = GlobalKey<FormFieldState<String>>();

  @override
  void initState() {
    super.initState();
    final staff = widget.staff;
    if (staff != null) {
      nameController.text = staff.name;
      isActive = staff.isActive;
      _worksFrom = _parseTimeOfDay(staff.worksFrom);
      _worksTo = _parseTimeOfDay(staff.worksTo);
      _breakStart = _parseTimeOfDay(staff.breakStart);
      _breakEnd = _parseTimeOfDay(staff.breakEnd);
      if (staff.photo != null) {
        _photoSlot = _UploadSlotState(
          status: UploadSlotStatus.uploaded,
          fileId: staff.photo!.id,
          fileName: staff.photo!.fileName,
          previewUrl: staff.photo!.url,
        );
      }
      // Always fetch fresh rather than trusting whatever ServiceBloc happens
      // to hold - the BlocListener below fills in the assigned services once
      // this lands.
      context.read<ServiceBloc>().add(const ServicesRequested());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_timeControllersInitialized) {
      _timeControllersInitialized = true;
      if (_worksFrom != null) worksFromController.text = _worksFrom!.format(context);
      if (_worksTo != null) worksToController.text = _worksTo!.format(context);
      if (_breakStart != null) {
        breakStartController.text = _breakStart!.format(context);
      }
      if (_breakEnd != null) breakEndController.text = _breakEnd!.format(context);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    worksFromController.dispose();
    worksToController.dispose();
    breakStartController.dispose();
    breakEndController.dispose();
    super.dispose();
  }

  /// Null for anything that is not an 'HH:mm' prefix - the API allows a staff
  /// member with no hours set, and the field should just open empty.
  TimeOfDay? _parseTimeOfDay(String? value) {
    final parts = (value ?? '').split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }

  List<ServiceModel> _resolveInitialServices(
    StaffModel staff,
    List<ServiceModel> allServices,
  ) {
    final resolved = <ServiceModel>[];
    for (final ref in staff.services) {
      for (final service in allServices) {
        if (service.id == ref.id) {
          resolved.add(service);
          break;
        }
      }
    }
    return resolved;
  }

  Future<void> _pickPhoto() async {
    File? file;
    try {
      file = await _imagePickerService.pickImageFromGallery();
    } catch (_) {
      if (mounted) {
        AppSnackbar.error(context, 'Could not open picker. Please try again.');
      }
      return;
    }
    if (file == null || !mounted) return;

    final sizeError = _uploadService.validateSize(file);
    if (sizeError != null) {
      AppSnackbar.error(context, sizeError);
      return;
    }

    setState(() => _photoSlot = const _UploadSlotState(status: UploadSlotStatus.uploading));

    try {
      final result = await _uploadService.upload(file: file, purpose: 'staff_photo');
      if (!mounted) return;
      setState(() {
        _photoSlot = _UploadSlotState(
          status: UploadSlotStatus.uploaded,
          fileId: result.id,
          fileName: result.fileName,
          previewFile: file,
        );
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _photoSlot = _UploadSlotState(status: UploadSlotStatus.error, errorMessage: e.message);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _photoSlot = const _UploadSlotState(
          status: UploadSlotStatus.error,
          errorMessage: 'Upload failed. Please try again.',
        );
      });
    }
  }

  Future<void> _removePhoto() async {
    final id = _photoSlot.fileId;
    setState(() => _photoSlot = const _UploadSlotState());
    if (id == null) return;
    try {
      await _uploadService.deleteUpload(id);
    } catch (_) {
      // Best-effort cleanup — the slot is already cleared locally and its id
      // won't be sent as photo_id, so a failed server-side delete here
      // isn't blocking.
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  int _minutesOf(TimeOfDay time) => time.hour * 60 + time.minute;

  String? _breakStartValidator(String? value) {
    if (_breakStart == null) {
      return _breakEnd != null ? 'Break Start is required' : null;
    }
    if (_worksFrom == null || _worksTo == null) return null;
    final breakStart = _minutesOf(_breakStart!);
    if (breakStart < _minutesOf(_worksFrom!) ||
        breakStart >= _minutesOf(_worksTo!)) {
      return 'Break Start must be within Works From and Works To';
    }
    return null;
  }

  String? _breakEndValidator(String? value) {
    if (_breakEnd == null) {
      return _breakStart != null ? 'Break End is required' : null;
    }
    final breakEnd = _minutesOf(_breakEnd!);
    if (_breakStart != null && breakEnd <= _minutesOf(_breakStart!)) {
      return 'Break End must be later than Break Start';
    }
    if (_worksFrom == null || _worksTo == null) return null;
    if (breakEnd <= _minutesOf(_worksFrom!) || breakEnd > _minutesOf(_worksTo!)) {
      return 'Break End must be within Works From and Works To';
    }
    return null;
  }

  Future<void> _pickTime(
    TextEditingController controller,
    ValueChanged<TimeOfDay> onPicked, {
    TimeOfDay? initialTime,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        onPicked(picked);
        controller.text = picked.format(context);
      });
      _validateTimeFields();
    }
  }

  Future<void> _openServicePicker() async {
    final result = await ServiceSelectionBottomSheet.show(
      context,
      selected: _selectedServices,
    );
    if (result != null) {
      setState(() {
        _selectedServices = result;
      });
    }
  }

  void _removeService(String id) {
    setState(() {
      _selectedServices = _selectedServices.where((s) => s.id != id).toList();
    });
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  /// Re-validates both break fields. Any pick can invalidate the other one
  /// (e.g. moving Works To can push the break outside working hours), so they
  /// are always checked together.
  void _validateTimeFields() {
    _breakStartFieldKey.currentState?.validate();
    _breakEndFieldKey.currentState?.validate();
  }

  void _onSavePressed() {
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedServices.isEmpty) {
      AppSnackbar.error(context, 'Select at least one service');
      return;
    }

    final name = nameController.text.trim();
    final photoId = _photoSlot.isUploaded ? _photoSlot.fileId : null;
    final worksFrom = _formatTimeOfDay(_worksFrom!);
    final worksTo = _formatTimeOfDay(_worksTo!);
    final breakStart = _breakStart != null ? _formatTimeOfDay(_breakStart!) : null;
    final breakEnd = _breakEnd != null ? _formatTimeOfDay(_breakEnd!) : null;
    final serviceIds = _selectedServices.map((s) => s.id).toList();

    if (_isEditing) {
      context.read<AddStaffBloc>().add(
        EditStaffSubmitted(
          staffId: widget.staff!.id,
          name: name,
          photoId: photoId,
          worksFrom: worksFrom,
          worksTo: worksTo,
          breakStart: breakStart,
          breakEnd: breakEnd,
          isActive: isActive,
          serviceIds: serviceIds,
        ),
      );
    } else {
      context.read<AddStaffBloc>().add(
        AddStaffSubmitted(
          name: name,
          photoId: photoId,
          worksFrom: worksFrom,
          worksTo: worksTo,
          breakStart: breakStart,
          breakEnd: breakEnd,
          isActive: isActive,
          serviceIds: serviceIds,
        ),
      );
    }
  }

  Future<void> _onDeletePressed() async {
    final staff = widget.staff;
    if (staff == null) return;

    final confirmed = await AppAlertDialog.show(
      context,
      icon: Icons.delete_outline,
      title: 'Delete Staff',
      message: 'Are you sure you want to delete "${staff.name}"?',
      primaryLabel: 'Delete',
      secondaryLabel: 'Cancel',
      iconColor: AppColors.error,
      iconBackgroundColor: AppColors.primaryLight,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isDeleting = true);
    context.read<StaffBloc>().add(StaffDeleteRequested(staffId: staff.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(title: _isEditing ? 'Edit Staff' : 'Add Staff'),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AddStaffBloc, AddStaffState>(
            listener: (context, state) {
              if (state is AddStaffSuccess) {
                context.read<StaffBloc>().add(const StaffRequested());
                context.pop();
              } else if (state is AddStaffFailure) {
                AppSnackbar.error(context, state.message);
              }
            },
          ),
          // Catches the fetch kicked off in initState when ServiceBloc had
          // nothing loaded yet - e.g. arriving from the Staff Profile screen.
          BlocListener<ServiceBloc, ServiceState>(
            listener: (context, state) {
              final staff = widget.staff;
              if (staff == null || _initialServicesResolved) return;
              if (state is ServiceSuccess) {
                setState(() {
                  _selectedServices = _resolveInitialServices(
                    staff,
                    state.services,
                  );
                  _initialServicesResolved = true;
                });
              }
            },
          ),
          // Delete goes through StaffBloc (the same bloc the Staff list
          // uses), so success here already means the list has re-fetched.
          BlocListener<StaffBloc, StaffState>(
            listenWhen: (_, _) => _isDeleting,
            listener: (context, state) {
              if (state is StaffSuccess) {
                AppSnackbar.success(context, 'Staff deleted');
                context.pop();
              } else if (state is StaffFailure) {
                setState(() => _isDeleting = false);
                AppSnackbar.error(context, state.message);
              }
            },
          ),
        ],
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Is Active',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Switch(
                        value: isActive,
                        onChanged: (value) {
                          setState(() => isActive = value);
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 1.5.h),

                  AppTextField(
                    labelText: 'Name',
                    hintText: 'Enter Staff Name',
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => _requiredValidator(value, 'Name'),
                  ),

                  SizedBox(height: 1.5.h),

                  UploadSlotField(
                    label: 'Photo',
                    status: _photoSlot.status,
                    fileName: _photoSlot.fileName,
                    errorMessage: _photoSlot.errorMessage,
                    previewFile: _photoSlot.previewFile,
                    previewUrl: _photoSlot.previewUrl,
                    onTap: _pickPhoto,
                    onRemove: _removePhoto,
                  ),

                  SizedBox(height: 1.5.h),

                  AppTextField(
                    labelText: 'Works From',
                    hintText: 'Set Start Time',
                    controller: worksFromController,
                    readOnly: true,
                    onTap: () => _pickTime(
                      worksFromController,
                      (time) => _worksFrom = time,
                    ),
                    validator: (value) =>
                        _requiredValidator(value, 'Works From'),
                  ),

                  SizedBox(height: 1.5.h),

                  AppTextField(
                    labelText: 'Works To',
                    hintText: 'Set End Time',
                    controller: worksToController,
                    readOnly: true,
                    onTap: () => _pickTime(
                      worksToController,
                      (time) => _worksTo = time,
                      initialTime: _worksTo ?? _worksFrom,
                    ),
                    validator: (value) => _requiredValidator(value, 'Works To'),
                  ),

                  SizedBox(height: 1.5.h),

                  AppTextField(
                    labelText: 'Break Start',
                    hintText: 'Set Break Start Time',
                    fieldKey: _breakStartFieldKey,
                    controller: breakStartController,
                    readOnly: true,
                    onTap: () => _pickTime(
                      breakStartController,
                      (time) => _breakStart = time,
                      initialTime: _breakStart ?? _worksFrom,
                    ),
                    validator: _breakStartValidator,
                  ),

                  SizedBox(height: 1.5.h),

                  AppTextField(
                    labelText: 'Break End',
                    hintText: 'Set Break End Time',
                    fieldKey: _breakEndFieldKey,
                    controller: breakEndController,
                    readOnly: true,
                    onTap: () => _pickTime(
                      breakEndController,
                      (time) => _breakEnd = time,
                      initialTime: _breakEnd ?? _breakStart,
                    ),
                    validator: _breakEndValidator,
                  ),

                  SizedBox(height: 1.5.h),

                  Text(
                    'Services',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  SizedBox(height: 0.95.h),
                  SizedBox(
                    height: 14.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedServices.length + 1,
                      separatorBuilder: (_, _) => SizedBox(width: 2.56.w),
                      itemBuilder: (context, index) {
                        if (index == _selectedServices.length) {
                          return AddServiceTile(onTap: _openServicePicker);
                        }
                        final service = _selectedServices[index];
                        return _SelectedServiceTile(
                          service: service,
                          onRemove: () => _removeService(service.id),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 2.37.h),

                  BlocBuilder<AddStaffBloc, AddStaffState>(
                    builder: (context, state) {
                      final isLoading = state is AddStaffLoading;
                      final isDisabled =
                          isLoading ||
                          _photoSlot.status == UploadSlotStatus.uploading ||
                          _isDeleting;
                      return SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          label: isLoading
                              ? 'Saving...'
                              : (_isEditing ? 'Save Changes' : 'Save Staff'),
                          isLoading: isLoading,
                          onPressed: isDisabled ? null : _onSavePressed,
                        ),
                      );
                    },
                  ),
                  if (_isEditing) ...[
                    SizedBox(height: 1.5.h),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isDeleting ? null : _onDeletePressed,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                        ),
                        icon: _isDeleting
                            ? SizedBox(
                                width: 16.sp,
                                height: 16.sp,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.error,
                                ),
                              )
                            : const Icon(Icons.delete_outline),
                        label: Text(_isDeleting ? 'Deleting...' : 'Delete Staff'),
                      ),
                    ),
                  ],
                  SizedBox(height: 1.5.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedServiceTile extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onRemove;

  const _SelectedServiceTile({required this.service, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ServiceTile(service: service, showDeleteButton: false),
        Positioned(
          top: 0.h,
          right: 0.w,
          child: InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(3.08.w),
            child: Container(
              padding: EdgeInsets.all(1.03.w),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 14.sp, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
