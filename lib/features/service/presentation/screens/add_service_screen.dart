import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:noq_business/features/categories/bloc/categories_bloc.dart';
import 'package:noq_business/features/categories/bloc/categories_event.dart';
import 'package:noq_business/features/categories/bloc/categories_state.dart';
import 'package:noq_business/features/categories/data/categories_model.dart';
import 'package:noq_business/features/categories/presentation/widgets/sub_category_bottom_sheet.dart';
import 'package:noq_business/features/service/bloc/add_service_bloc.dart';
import 'package:noq_business/features/service/bloc/add_service_event.dart';
import 'package:noq_business/features/service/bloc/add_service_state.dart';
import 'package:noq_business/features/service/bloc/service_bloc.dart';
import 'package:noq_business/features/service/bloc/service_event.dart';
import 'package:noq_business/features/service/bloc/service_state.dart';
import 'package:noq_business/features/service/data/service_model.dart';

const _maxBannerCount = 5;

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

class AddServiceScreen extends StatefulWidget {
  final ServiceModel? service;

  const AddServiceScreen({super.key, this.service});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isServiceActive = false;
  final TextEditingController serviceNameController = TextEditingController();
  final _subCategoryController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final _uploadService = UploadService();
  final _imagePickerService = ImagePickerService();

  SubCategoryModel? _selectedSubCategory;
  String? _initialSubCategoryId;

  var _thumbnailSlot = const _UploadSlotState();
  final _bannerSlots = <_UploadSlotState>[];

  /// True once the delete flow is confirmed and dispatched, so the
  /// [ServiceBloc] listener knows to act on the next success/failure.
  bool _isDeleting = false;

  bool get _isEditing => widget.service != null;

  bool get _anySlotUploading =>
      _thumbnailSlot.status == UploadSlotStatus.uploading ||
      _bannerSlots.any((s) => s.status == UploadSlotStatus.uploading);

  String? get _bannerUploadError {
    for (final slot in _bannerSlots) {
      if (slot.status == UploadSlotStatus.error && slot.errorMessage != null) {
        return slot.errorMessage;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final service = widget.service;
    if (service != null) {
      serviceNameController.text = service.name;
      durationController.text = service.durationMinutes.toString();
      priceController.text = service.price;
      descriptionController.text = service.description ?? '';
      isServiceActive = service.isActive;
      _initialSubCategoryId = service.subCategoryId;
      if (service.subCategoryId != null) {
        context.read<CategoriesBloc>().add(const SubCategoriesRequested());
      }

      final thumbnail = service.images.thumbnails.isNotEmpty
          ? service.images.thumbnails.first
          : null;
      if (thumbnail != null) {
        _thumbnailSlot = _UploadSlotState(
          status: UploadSlotStatus.uploaded,
          fileId: thumbnail.id,
          fileName: thumbnail.fileName,
          previewUrl: thumbnail.url,
        );
      }

      if (service.images.banners.isNotEmpty) {
        _bannerSlots
          ..clear()
          ..addAll(
            service.images.banners.map(
              (banner) => _UploadSlotState(
                status: UploadSlotStatus.uploaded,
                fileId: banner.id,
                fileName: banner.fileName,
                previewUrl: banner.url,
              ),
            ),
          );
      }
    }
  }

  @override
  void dispose() {
    serviceNameController.dispose();
    _subCategoryController.dispose();
    durationController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<File?> _pickImage() async {
    try {
      return await _imagePickerService.pickImageFromGallery();
    } catch (_) {
      if (mounted) {
        AppSnackbar.error(context, 'Could not open picker. Please try again.');
      }
      return null;
    }
  }

  Future<void> _uploadToSlot({
    required File file,
    required String purpose,
    required void Function(_UploadSlotState) apply,
  }) async {
    final sizeError = _uploadService.validateSize(file);
    if (sizeError != null) {
      AppSnackbar.error(context, sizeError);
      return;
    }

    setState(() => apply(const _UploadSlotState(status: UploadSlotStatus.uploading)));

    try {
      final result = await _uploadService.upload(file: file, purpose: purpose);
      if (!mounted) return;
      setState(() {
        apply(
          _UploadSlotState(
            status: UploadSlotStatus.uploaded,
            fileId: result.id,
            fileName: result.fileName,
            previewFile: file,
          ),
        );
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        apply(_UploadSlotState(status: UploadSlotStatus.error, errorMessage: e.message));
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        apply(
          const _UploadSlotState(
            status: UploadSlotStatus.error,
            errorMessage: 'Upload failed. Please try again.',
          ),
        );
      });
    }
  }

  Future<void> _pickThumbnail() async {
    final file = await _pickImage();
    if (file == null || !mounted) return;
    await _uploadToSlot(
      file: file,
      purpose: 'service_thumbnail',
      apply: (s) => _thumbnailSlot = s,
    );
  }

  Future<void> _removeThumbnail() async {
    final id = _thumbnailSlot.fileId;
    setState(() => _thumbnailSlot = const _UploadSlotState());
    if (id == null) return;
    try {
      await _uploadService.deleteUpload(id);
    } catch (_) {
      // Best-effort cleanup — the slot is already cleared locally and its id
      // won't be sent in thumbnail_ids, so a failed server-side delete here
      // isn't blocking.
    }
  }

  Future<void> _pickBanner(int index) async {
    final file = await _pickImage();
    if (file == null || !mounted) return;
    await _uploadToSlot(
      file: file,
      purpose: 'service_banner',
      apply: (s) => _bannerSlots[index] = s,
    );
  }

  Future<void> _removeBanner(int index) async {
    final id = _bannerSlots[index].fileId;
    setState(() => _bannerSlots.removeAt(index));
    if (id == null) return;
    try {
      await _uploadService.deleteUpload(id);
    } catch (_) {
      // Best-effort cleanup, see _removeThumbnail.
    }
  }

  Future<void> _addBannerSlot() async {
    if (_bannerSlots.length >= _maxBannerCount) return;
    final file = await _pickImage();
    if (file == null || !mounted) return;
    final sizeError = _uploadService.validateSize(file);
    if (sizeError != null) {
      AppSnackbar.error(context, sizeError);
      return;
    }
    final index = _bannerSlots.length;
    setState(() => _bannerSlots.add(const _UploadSlotState()));
    await _uploadToSlot(
      file: file,
      purpose: 'service_banner',
      apply: (s) => _bannerSlots[index] = s,
    );
  }

  Future<void> _openSubCategoryPicker() async {
    final subCategory = await SubCategoryBottomSheet.show(
      context,
      selected: _selectedSubCategory,
    );
    if (subCategory != null) {
      setState(() {
        _selectedSubCategory = subCategory;
        _subCategoryController.text = subCategory.name;
      });
    }
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  void _onSavePressed() {
    if (_formKey.currentState?.validate() != true) return;
    if (!_thumbnailSlot.isUploaded) {
      AppSnackbar.error(context, 'Please upload a thumbnail image.');
      return;
    }
    final bannerIds = _bannerSlots
        .where((s) => s.isUploaded)
        .map((s) => s.fileId!)
        .toList();
    final name = serviceNameController.text.trim();
    final durationMinutes = int.parse(durationController.text.trim());
    final price = priceController.text.trim();
    final subCategoryId = _selectedSubCategory?.id ?? _initialSubCategoryId;
    final description = descriptionController.text.trim().isEmpty
        ? null
        : descriptionController.text.trim();
    final thumbnailIds = [_thumbnailSlot.fileId!];

    if (_isEditing) {
      context.read<AddServiceBloc>().add(
        EditServiceSubmitted(
          serviceId: widget.service!.id,
          name: name,
          durationMinutes: durationMinutes,
          price: price,
          subCategoryId: subCategoryId,
          description: description,
          isActive: isServiceActive,
          thumbnailIds: thumbnailIds,
          bannerIds: bannerIds,
        ),
      );
    } else {
      context.read<AddServiceBloc>().add(
        AddServiceSubmitted(
          name: name,
          durationMinutes: durationMinutes,
          price: price,
          subCategoryId: subCategoryId,
          description: description,
          isActive: isServiceActive,
          thumbnailIds: thumbnailIds,
          bannerIds: bannerIds,
        ),
      );
    }
  }

  Future<void> _onDeletePressed() async {
    final service = widget.service;
    if (service == null) return;

    final confirmed = await AppAlertDialog.show(
      context,
      icon: Icons.delete_outline,
      title: 'Delete Service',
      message: 'Are you sure you want to delete "${service.name}"?',
      primaryLabel: 'Delete',
      secondaryLabel: 'Cancel',
      iconColor: AppColors.error,
      iconBackgroundColor: AppColors.primaryLight,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isDeleting = true);
    context.read<ServiceBloc>().add(
      ServiceDeleteRequested(serviceId: service.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(title: _isEditing ? 'Edit Service' : 'Add Service'),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AddServiceBloc, AddServiceState>(
            listener: (context, state) {
              if (state is AddServiceSuccess) {
                context.read<ServiceBloc>().add(const ServicesRequested());
                context.pop();
              } else if (state is AddServiceFailure) {
                AppSnackbar.error(context, state.message);
              }
            },
          ),
          // Delete goes through ServiceBloc (the same bloc the Services list
          // uses), so success here already means the list has re-fetched.
          BlocListener<ServiceBloc, ServiceState>(
            listenWhen: (_, _) => _isDeleting,
            listener: (context, state) {
              if (state is ServiceSuccess) {
                AppSnackbar.success(context, 'Service deleted');
                context.pop();
              } else if (state is ServiceFailure) {
                setState(() => _isDeleting = false);
                AppSnackbar.error(context, state.message);
              }
            },
          ),
          BlocListener<CategoriesBloc, CategoriesState>(
            listener: (context, state) {
              if (state is SubCategoriesSuccess &&
                  _selectedSubCategory == null &&
                  _initialSubCategoryId != null) {
                for (final subCategory in state.subCategories) {
                  if (subCategory.id == _initialSubCategoryId) {
                    setState(() {
                      _selectedSubCategory = subCategory;
                      _subCategoryController.text = subCategory.name;
                    });
                    break;
                  }
                }
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
                        'Is Service Active',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Switch(
                        value: isServiceActive,
                        onChanged: (value) {
                          setState(() => isServiceActive = value);
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 1.5.h),

                  AppTextField(
                    labelText: 'Service Name',
                    hintText: 'Enter Service Name',
                    controller: serviceNameController,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) =>
                        _requiredValidator(value, 'Service name'),
                  ),

                  SizedBox(height: 1.5.h),

                  AppTextField(
                    labelText: 'Sub Category',
                    hintText: 'Select Sub Category',
                    controller: _subCategoryController,
                    readOnly: true,
                    suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
                    onTap: _openSubCategoryPicker,
                  ),
                  SizedBox(height: 1.5.h),

                  AppTextField(
                    labelText: 'Service Duration',
                    hintText: 'Enter Duration in minutes',
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) => _requiredValidator(value, 'Duration'),
                  ),

                  SizedBox(height: 1.5.h),

                  AppTextField(
                    labelText: 'Price',
                    hintText: 'Enter Service Price',
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    validator: (value) => _requiredValidator(value, 'Price'),
                  ),

                  SizedBox(height: 1.5.h),

                  AppTextField(
                    labelText: 'Description',
                    hintText: 'Enter Service Description',
                    controller: descriptionController,
                    maxLines: 4,
                    maxLength: 200,
                  ),

                  SizedBox(height: 1.5.h),

                  UploadSlotField(
                    label: 'Thumbnail',
                    status: _thumbnailSlot.status,
                    fileName: _thumbnailSlot.fileName,
                    errorMessage: _thumbnailSlot.errorMessage,
                    previewFile: _thumbnailSlot.previewFile,
                    previewUrl: _thumbnailSlot.previewUrl,
                    onTap: _pickThumbnail,
                    onRemove: _removeThumbnail,
                  ),

                  SizedBox(height: 1.5.h),

                  Text(
                    'Banners (max $_maxBannerCount)',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  SizedBox(height: 0.8.h),
                  Wrap(
                    spacing: 3.w,
                    runSpacing: 1.5.h,
                    children: [
                      for (var i = 0; i < _bannerSlots.length; i++)
                        BannerUploadTile(
                          status: _bannerSlots[i].status,
                          previewFile: _bannerSlots[i].previewFile,
                          previewUrl: _bannerSlots[i].previewUrl,
                          onTap: () => _pickBanner(i),
                          onRemove: () => _removeBanner(i),
                        ),
                      if (_bannerSlots.length < _maxBannerCount)
                        AddBannerTile(onTap: _addBannerSlot),
                    ],
                  ),
                  if (_bannerUploadError != null) ...[
                    SizedBox(height: 0.6.h),
                    Text(
                      _bannerUploadError!,
                      style: TextStyle(fontSize: 13.5.sp, color: AppColors.error),
                    ),
                  ],
                  SizedBox(height: 0.7.h),

                  SizedBox(height: 1.18.h),

                  BlocBuilder<AddServiceBloc, AddServiceState>(
                    builder: (context, state) {
                      final isLoading = state is AddServiceLoading;
                      final isDisabled =
                          isLoading || _anySlotUploading || _isDeleting;
                      return SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          label: isLoading
                              ? 'Saving...'
                              : (_isEditing ? 'Save Changes' : 'Save Service'),
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
                        label: Text(_isDeleting ? 'Deleting...' : 'Delete Service'),
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
