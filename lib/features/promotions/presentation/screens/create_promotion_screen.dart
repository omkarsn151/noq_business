import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/core/common/app_alert_dialog.dart';
import 'package:noq_business/core/common/app_appbar.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/core/common/app_snackbar.dart';
import 'package:noq_business/core/common/app_text_field.dart';
import 'package:noq_business/core/services/image_picker_service.dart';
import 'package:noq_business/core/services/upload_service.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/core/utils/date_formats.dart';
import 'package:noq_business/features/business_setup/presentation/widgets/upload_slot_field.dart';
import 'package:noq_business/features/promotions/bloc/create_promotion_bloc.dart';
import 'package:noq_business/features/promotions/bloc/create_promotion_event.dart';
import 'package:noq_business/features/promotions/bloc/create_promotion_state.dart';
import 'package:noq_business/features/promotions/bloc/promotion_details_bloc.dart';
import 'package:noq_business/features/promotions/bloc/promotion_details_event.dart';
import 'package:noq_business/features/promotions/bloc/promotions_bloc.dart';
import 'package:noq_business/features/promotions/bloc/promotions_event.dart';
import 'package:noq_business/features/promotions/data/promotion_details_model.dart';
import 'package:noq_business/features/promotions/data/promotion_model.dart';
import 'package:noq_business/features/promotions/data/promotion_status.dart';

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
}

class CreatePromotionScreen extends StatefulWidget {
  /// When non-null the screen opens in edit mode, prefilled from this promo.
  final PromotionDetailModel? promotion;

  const CreatePromotionScreen({super.key, this.promotion});

  @override
  State<CreatePromotionScreen> createState() => _CreatePromotionScreenState();
}

class _CreatePromotionScreenState extends State<CreatePromotionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _minBookingController = TextEditingController();
  final _maxDiscountController = TextEditingController();
  final _validFromController = TextEditingController();
  final _validUntilController = TextEditingController();
  final _totalRedemptionController = TextEditingController();
  final _perCustomerController = TextEditingController();

  final _uploadService = UploadService();
  final _imagePickerService = ImagePickerService();

  DiscountType _discountType = DiscountType.percent;
  DateTime? _validFrom;
  DateTime? _validUntil;
  var _bannerSlot = const _UploadSlotState();
  bool _isActive = false;

  bool get _isBannerUploading =>
      _bannerSlot.status == UploadSlotStatus.uploading;

  PromotionDetailModel? get _promotion => widget.promotion;
  bool get _isEditing => _promotion != null;

  /// Editing a promo that is still a draft: keep the publish / save-as-draft
  /// buttons instead of the active toggle.
  bool get _isDraftEdit =>
      _isEditing && _promotion!.status == PromotionStatus.draft;

  bool get _isPublishedEdit => _isEditing && !_isDraftEdit;

  @override
  void initState() {
    super.initState();
    final promo = _promotion;
    if (promo == null) return;

    _titleController.text = promo.title;
    _codeController.text = promo.code;
    _descriptionController.text = promo.description ?? '';
    _discountType = promo.discount.type;
    _discountValueController.text = promo.discount.value;
    _minBookingController.text = promo.discount.minBookingAmount ?? '';
    if (_discountType == DiscountType.percent) {
      _maxDiscountController.text = promo.discount.maxDiscountAmount ?? '';
    }

    final from = promo.validity.from?.toLocal();
    final until = promo.validity.until?.toLocal();
    if (from != null) {
      _validFrom = from;
      _validFromController.text = formatDateTime(from);
    }
    if (until != null) {
      _validUntil = until;
      _validUntilController.text = formatDateTime(until);
    }

    if (promo.limits.totalRedemptionLimit > 0) {
      _totalRedemptionController.text =
          promo.limits.totalRedemptionLimit.toString();
    }
    if (promo.limits.perCustomerLimit > 0) {
      _perCustomerController.text = promo.limits.perCustomerLimit.toString();
    }

    _isActive = promo.isActive;

    final banner = promo.banner;
    if (banner != null) {
      _bannerSlot = _UploadSlotState(
        status: UploadSlotStatus.uploaded,
        fileId: banner.id,
        fileName: banner.fileName,
        previewUrl: banner.url,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _discountValueController.dispose();
    _minBookingController.dispose();
    _maxDiscountController.dispose();
    _validFromController.dispose();
    _validUntilController.dispose();
    _totalRedemptionController.dispose();
    _perCustomerController.dispose();
    super.dispose();
  }

  Future<void> _pickBanner() async {
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

    setState(
      () => _bannerSlot = const _UploadSlotState(
        status: UploadSlotStatus.uploading,
      ),
    );

    try {
      final result = await _uploadService.upload(
        file: file,
        purpose: 'promo_banner',
      );
      if (!mounted) return;
      setState(() {
        _bannerSlot = _UploadSlotState(
          status: UploadSlotStatus.uploaded,
          fileId: result.id,
          fileName: result.fileName,
          previewFile: file,
        );
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _bannerSlot = _UploadSlotState(
          status: UploadSlotStatus.error,
          errorMessage: e.message,
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _bannerSlot = const _UploadSlotState(
          status: UploadSlotStatus.error,
          errorMessage: 'Upload failed. Please try again.',
        );
      });
    }
  }

  Future<void> _removeBanner() async {
    final id = _bannerSlot.fileId;
    setState(() => _bannerSlot = const _UploadSlotState());
    if (id == null) return;
    try {
      await _uploadService.deleteUpload(id);
    } catch (_) {
      // Best-effort cleanup — the slot is already cleared locally and its id
      // won't be sent as banner_upload_id.
    }
  }

  Future<void> _pickDateTime({required bool isFrom}) async {
    final now = DateTime.now();
    final current = isFrom ? _validFrom : _validUntil;
    // 'Valid until' can never start before 'valid from', and neither can start
    // in the past.
    var earliest = isFrom
        ? now
        : (_validFrom != null && _validFrom!.isAfter(now) ? _validFrom! : now);
    // A running promo's stored dates are legitimately in the past when editing;
    // let the vendor keep or move the existing value.
    if (_isEditing && current != null && current.isBefore(earliest)) {
      earliest = current;
    }
    final initial = current != null && !current.isBefore(earliest)
        ? current
        : earliest;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(earliest.year, earliest.month, earliest.day),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;

    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    // The date picker can only bar whole days, so a time earlier today still
    // has to be rejected here. When editing, past dates are allowed (see above).
    if (!_isEditing && picked.isBefore(DateTime.now())) {
      AppSnackbar.error(
        context,
        '${isFrom ? 'Valid from' : 'Valid until'} cannot be in the past.',
      );
      return;
    }

    if (!isFrom && _validFrom != null && !picked.isAfter(_validFrom!)) {
      AppSnackbar.error(context, 'Valid until must be after valid from.');
      return;
    }

    setState(() {
      if (isFrom) {
        _validFrom = picked;
        _validFromController.text = formatDateTime(picked);
      } else {
        _validUntil = picked;
        _validUntilController.text = formatDateTime(picked);
      }
    });
    // Re-runs the 'until must be after from' check against the new pair.
    _formKey.currentState?.validate();
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  String? _discountValueValidator(String? value) {
    final required = _requiredValidator(value, 'Discount value');
    if (required != null) return required;

    final parsed = num.tryParse(value!.trim());
    if (parsed == null || parsed <= 0) return 'Enter a valid discount';
    if (_discountType == DiscountType.percent && parsed > 100) {
      return 'Percentage cannot be more than 100';
    }
    return null;
  }

  String? _validFromValidator(String? value) {
    final required = _requiredValidator(value, 'Valid from');
    if (required != null) return required;
    // Guards against the picked time going stale before the form is submitted.
    // A promo being edited may already have started, so the check is create-only.
    if (!_isEditing &&
        _validFrom != null &&
        _validFrom!.isBefore(DateTime.now())) {
      return 'Valid from cannot be in the past';
    }
    return null;
  }

  String? _validUntilValidator(String? value) {
    final required = _requiredValidator(value, 'Valid until');
    if (required != null) return required;
    if (!_isEditing &&
        _validUntil != null &&
        _validUntil!.isBefore(DateTime.now())) {
      return 'Valid until cannot be in the past';
    }
    if (_validFrom != null &&
        _validUntil != null &&
        !_validUntil!.isAfter(_validFrom!)) {
      return 'Valid until must be after valid from';
    }
    return null;
  }

  num? _optionalNum(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : num.tryParse(text);
  }

  int? _optionalInt(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : int.tryParse(text);
  }

  Future<void> _onSubmit({required bool publish}) async {
    if (_formKey.currentState?.validate() != true) return;

    final title = _titleController.text.trim();
    final isPublishedEdit = _isEditing && !_isDraftEdit;

    final confirmed = await AppAlertDialog.show(
      context,
      icon: (publish || isPublishedEdit)
          ? Icons.check_circle_outline
          : Icons.drafts_outlined,
      title: isPublishedEdit
          ? 'Save Changes'
          : publish
          ? 'Publish Promo'
          : _isEditing
          ? 'Save as Draft'
          : 'Move to Draft',
      message: isPublishedEdit
          ? 'Save changes to the $title promo?'
          : publish
          ? 'Are you sure you want to publish the promo of $title?'
          : _isEditing
          ? 'Save the $title promo as a draft?'
          : 'Are you sure you want to move the $title promo to draft',
      primaryLabel: isPublishedEdit
          ? 'Save'
          : publish
          ? 'Yes, Publish'
          : _isEditing
          ? 'Yes, Save'
          : 'Yes, Move',
      secondaryLabel: 'No',
    );
    if (!confirmed || !mounted) return;

    final code = _codeController.text.trim();
    final description = _descriptionController.text.trim().isEmpty
        ? null
        : _descriptionController.text.trim();
    final discountValue = num.parse(_discountValueController.text.trim());
    final bloc = context.read<CreatePromotionBloc>();

    if (_isEditing) {
      bloc.add(
        UpdatePromotionSubmitted(
          promotionId: _promotion!.id,
          title: title,
          description: description,
          bannerUploadId: _bannerSlot.fileId,
          discountType: _discountType,
          discountValue: discountValue,
          minBookingAmount: _optionalNum(_minBookingController),
          maxDiscountAmount: _optionalNum(_maxDiscountController),
          validFrom: _validFrom!,
          validUntil: _validUntil!,
          totalRedemptionLimit: _optionalInt(_totalRedemptionController),
          perCustomerLimit: _optionalInt(_perCustomerController),
          publish: _isDraftEdit ? (publish ? true : null) : null,
          isActive: _isDraftEdit ? null : _isActive,
          includeDiscountFields: !_isPublishedEdit,
        ),
      );
    } else {
      bloc.add(
        CreatePromotionSubmitted(
          code: code,
          title: title,
          description: description,
          bannerUploadId: _bannerSlot.fileId,
          discountType: _discountType,
          discountValue: discountValue,
          minBookingAmount: _optionalNum(_minBookingController),
          maxDiscountAmount: _optionalNum(_maxDiscountController),
          validFrom: _validFrom!,
          validUntil: _validUntil!,
          totalRedemptionLimit: _optionalInt(_totalRedemptionController),
          perCustomerLimit: _optionalInt(_perCustomerController),
          publish: publish,
        ),
      );
    }
  }

  Future<void> _onSaved(CreatePromotionSuccess state) async {
    final title = _titleController.text.trim();
    final isEdit = state.isEdit;
    await AppAlertDialog.show(
      context,
      icon: Icons.check_circle_outline,
      title: isEdit
          ? 'Promo Updated'
          : state.published
          ? 'Published Promo'
          : 'Moved to Draft',
      message: isEdit
          ? '$title promo has been updated successfully'
          : state.published
          ? '$title promo has been published successfully'
          : '$title promo has been moved to draft successfully',
      primaryLabel: 'Done',
      secondaryLabel: null,
    );
    if (!mounted) return;

    context.read<PromotionsBloc>().add(
      PromotionsRefreshRequested(
        status: isEdit
            ? _promotion!.status
            : state.published
            ? PromotionStatus.active
            : PromotionStatus.draft,
      ),
    );
    if (isEdit) {
      context.read<PromotionDetailsBloc>().add(
        PromotionDetailsRequested(promotionId: _promotion!.id),
      );
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(title: _isEditing ? 'Edit Promo' : 'Create Promo'),
      body: BlocListener<CreatePromotionBloc, CreatePromotionState>(
        listener: (context, state) {
          if (state is CreatePromotionSuccess) {
            _onSaved(state);
          } else if (state is CreatePromotionFailure) {
            AppSnackbar.error(context, state.message);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 1.h),

                  if (_isEditing && !_isDraftEdit) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Promo Active',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Switch(
                          value: _isActive,
                          onChanged: (value) =>
                              setState(() => _isActive = value),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                  ],

                  AppTextField(
                    labelText: 'Promo Title',
                    hintText: 'Enter Promo Title',
                    controller: _titleController,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) =>
                        _requiredValidator(value, 'Promo title'),
                  ),

                  SizedBox(height: 1.5.h),

                  AppTextField(
                    labelText: 'Promo Code',
                    hintText: 'Enter Promo Code',
                    controller: _codeController,
                    readOnly: _isEditing,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      TextInputFormatter.withFunction(
                        (_, newValue) => newValue.copyWith(
                          text: newValue.text.toUpperCase(),
                        ),
                      ),
                    ],
                    validator: (value) =>
                        _requiredValidator(value, 'Promo code'),
                  ),

                  SizedBox(height: 1.5.h),

                  AppTextField(
                    labelText: 'Description',
                    hintText: 'Enter Promo Description',
                    controller: _descriptionController,
                    maxLines: 4,
                    maxLength: 200,
                  ),

                  SizedBox(height: 0.5.h),

                  Text(
                    'Discount Type',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      for (final type in DiscountType.values) ...[
                        if (type != DiscountType.values.first)
                          SizedBox(width: 3.w),
                        Expanded(
                          child: _DiscountTypeChip(
                            label: type == DiscountType.percent
                                ? 'Percent (%)'
                                : 'Flat (₹)',
                            isSelected: _discountType == type,
                            onTap: _isPublishedEdit
                                ? null
                                : () {
                                    setState(() => _discountType = type);
                                    _formKey.currentState?.validate();
                                  },
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 1.5.h),

                  AppTextField(
                    labelText: 'Discount Value',
                    hintText: _discountType == DiscountType.percent
                        ? 'Enter discount percentage'
                        : 'Enter discount amount',
                    controller: _discountValueController,
                    readOnly: _isPublishedEdit,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    validator: _discountValueValidator,
                  ),

                  SizedBox(height: 1.5.h),

                  AppTextField(
                    labelText: 'Minimum Booking Amount',
                    hintText: 'Optional',
                    controller: _minBookingController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                  ),

                  SizedBox(height: 1.5.h),

                  // Only a percentage discount can run away with the bill, so
                  // the cap is offered for that type alone.
                  if (_discountType == DiscountType.percent) ...[
                    AppTextField(
                      labelText: 'Maximum Discount Amount',
                      hintText: 'Optional',
                      controller: _maxDiscountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.5.h),
                  ],

                  AppTextField(
                    labelText: 'Valid From',
                    hintText: 'Select start date and time',
                    controller: _validFromController,
                    readOnly: true,
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                    onTap: () => _pickDateTime(isFrom: true),
                    validator: _validFromValidator,
                  ),

                  SizedBox(height: 1.5.h),

                  AppTextField(
                    labelText: 'Valid Until',
                    hintText: 'Select end date and time',
                    controller: _validUntilController,
                    readOnly: true,
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                    onTap: () => _pickDateTime(isFrom: false),
                    validator: _validUntilValidator,
                  ),

                  SizedBox(height: 1.5.h),

                  AppTextField(
                    labelText: 'Total Redemption Limit',
                    hintText: 'Optional',
                    controller: _totalRedemptionController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),

                  SizedBox(height: 1.5.h),

                  AppTextField(
                    labelText: 'Per Customer Limit',
                    hintText: 'Optional',
                    controller: _perCustomerController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),

                  SizedBox(height: 1.5.h),

                  UploadSlotField(
                    label: 'Banner',
                    status: _bannerSlot.status,
                    fileName: _bannerSlot.fileName,
                    errorMessage: _bannerSlot.errorMessage,
                    previewFile: _bannerSlot.previewFile,
                    previewUrl: _bannerSlot.previewUrl,
                    onTap: _pickBanner,
                    onRemove: _removeBanner,
                  ),

                  SizedBox(height: 3.h),

                  BlocBuilder<CreatePromotionBloc, CreatePromotionState>(
                    builder: (context, state) {
                      final isLoading = state is CreatePromotionLoading;
                      final isDisabled = isLoading || _isBannerUploading;

                      // Editing a published promo: one 'Save Changes' button,
                      // status is driven by the active toggle above.
                      if (_isEditing && !_isDraftEdit) {
                        return SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            label: 'Save Changes',
                            isLoading: isLoading,
                            onPressed: isDisabled
                                ? null
                                : () => _onSubmit(publish: false),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              label: _isEditing
                                  ? 'Save & Publish'
                                  : 'Create & Publish Promo',
                              isLoading: isLoading,
                              onPressed: isDisabled
                                  ? null
                                  : () => _onSubmit(publish: true),
                            ),
                          ),
                          SizedBox(height: 1.5.h),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: isDisabled
                                  ? null
                                  : () => _onSubmit(publish: false),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 2.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.w),
                                ),
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                              child: Text(
                                _isEditing ? 'Save as Draft' : 'Move to draft',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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

/// Selectable pill used to switch between the percent and flat discount types.
class _DiscountTypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _DiscountTypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.w),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.4.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(6.w),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: onTap == null
                ? AppColors.border
                : isSelected
                ? AppColors.background
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
