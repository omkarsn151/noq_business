import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/core/common/app_appbar.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/core/common/app_snackbar.dart';
import 'package:noq_business/core/common/app_text_field.dart';
import 'package:noq_business/core/common/pick_source_sheet.dart';
import 'package:noq_business/core/services/file_picker_service.dart';
import 'package:noq_business/core/services/image_picker_service.dart';
import 'package:noq_business/core/services/upload_service.dart';
import 'package:noq_business/features/business/bloc/business_bloc.dart';
import 'package:noq_business/features/business/bloc/business_event.dart';
import 'package:noq_business/features/business/bloc/business_state.dart';
import 'package:noq_business/features/business/data/business_model.dart';
import 'package:noq_business/features/business_setup/bloc/business_setup_bloc.dart';
import 'package:noq_business/features/business_setup/bloc/business_setup_event.dart';
import 'package:noq_business/features/business_setup/bloc/business_setup_state.dart';
import 'package:noq_business/features/categories/presentation/widgets/category_bottom_sheet.dart';
import 'package:noq_business/features/business_setup/presentation/widgets/upload_slot_field.dart';
import 'package:noq_business/features/categories/data/categories_model.dart';

const _imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.heic'];

bool _hasImageExtension(String fileName) {
  final lower = fileName.toLowerCase();
  return _imageExtensions.any(lower.endsWith);
}

class _UploadSlotState {
  UploadSlotStatus status;
  String? fileId;
  String? fileName;
  String? errorMessage;
  File? previewFile;
  String? previewUrl;

  _UploadSlotState({
    this.status = UploadSlotStatus.idle,
    this.fileId,
    this.fileName,
    this.errorMessage,
    this.previewFile,
    this.previewUrl,
  });

  bool get isUploaded => status == UploadSlotStatus.uploaded && fileId != null;
}

class BusinessSetupScreen extends StatefulWidget {
  const BusinessSetupScreen({super.key});

  @override
  State<BusinessSetupScreen> createState() => _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends State<BusinessSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _businessNameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _gstNumberController = TextEditingController();

  final _uploadService = UploadService();
  final _imagePickerService = ImagePickerService();
  final _filePickerService = FilePickerService();

  CategoryModel? _selectedCategory;

  var _licenseSlot = _UploadSlotState();
  var _idProofSlot = _UploadSlotState();
  var _taxDocumentSlot = _UploadSlotState();
  var _thumbnailSlot = _UploadSlotState();

  bool get _anySlotUploading =>
      _licenseSlot.status == UploadSlotStatus.uploading ||
      _idProofSlot.status == UploadSlotStatus.uploading ||
      _taxDocumentSlot.status == UploadSlotStatus.uploading ||
      _thumbnailSlot.status == UploadSlotStatus.uploading;

  @override
  void initState() {
    super.initState();
    context.read<BusinessBloc>().add(const BusinessRequested());
  }

  void _applyBusinessData(BusinessModel business) {
    final details = business.business;
    setState(() {
      _businessNameController.text = details.name;
      _selectedCategory = CategoryModel(
        id: details.categoryId,
        name: details.categoryName,
        slug: '',
      );
      _categoryController.text = details.categoryName;
      _descriptionController.text = details.description;
      _addressController.text = details.addressLine;
      _cityController.text = details.city;
      _stateController.text = details.state;
      _postalCodeController.text = details.postalCode;
      _gstNumberController.text = details.gstNumber;

      for (final doc in business.documents) {
        final slotState = _UploadSlotState(
          status: UploadSlotStatus.uploaded,
          fileId: doc.uploadId,
          fileName: doc.fileName,
          previewUrl: _hasImageExtension(doc.fileName) ? doc.url : null,
        );
        switch (doc.docType) {
          case 'license':
            _licenseSlot = slotState;
          case 'id_proof':
            _idProofSlot = slotState;
          case 'tax_document':
            _taxDocumentSlot = slotState;
        }
      }

      final thumbnails = business.media?.thumbnails ?? [];
      if (thumbnails.isNotEmpty) {
        final thumbnail = thumbnails.first;
        _thumbnailSlot = _UploadSlotState(
          status: UploadSlotStatus.uploaded,
          fileId: thumbnail.uploadId,
          fileName: thumbnail.fileName,
          previewUrl: thumbnail.url,
        );
      }
    });
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _categoryController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _descriptionController.dispose();
    _gstNumberController.dispose();
    super.dispose();
  }

  Future<void> _openCategoryPicker() async {
    final category = await CategoryBottomSheet.show(
      context,
      selected: _selectedCategory,
    );
    if (category != null) {
      setState(() {
        _selectedCategory = category;
        _categoryController.text = category.name;
      });
    }
  }

  Future<void> _handleSlotPick({
    required String purpose,
    required void Function(_UploadSlotState) apply,
  }) async {
    final source = await PickSourceSheet.show(context);
    if (source == null || !mounted) return;

    final isImage = source == PickSource.image;
    File? file;
    try {
      file = isImage
          ? await _imagePickerService.pickImageFromGallery()
          : await _filePickerService.pickPdf();
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

    setState(() {
      apply(_UploadSlotState(status: UploadSlotStatus.uploading));
    });

    try {
      final result = await _uploadService.upload(file: file, purpose: purpose);
      if (!mounted) return;
      setState(() {
        apply(
          _UploadSlotState(
            status: UploadSlotStatus.uploaded,
            fileId: result.id,
            fileName: result.fileName,
            previewFile: isImage ? file : null,
          ),
        );
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        apply(
          _UploadSlotState(
            status: UploadSlotStatus.error,
            errorMessage: e.message,
          ),
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        apply(
          _UploadSlotState(
            status: UploadSlotStatus.error,
            errorMessage: 'Upload failed. Please try again.',
          ),
        );
      });
    }
  }

  Future<void> _handleImageSlotPick({
    required String purpose,
    required void Function(_UploadSlotState) apply,
  }) async {
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

    setState(() {
      apply(_UploadSlotState(status: UploadSlotStatus.uploading));
    });

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
        apply(
          _UploadSlotState(
            status: UploadSlotStatus.error,
            errorMessage: e.message,
          ),
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        apply(
          _UploadSlotState(
            status: UploadSlotStatus.error,
            errorMessage: 'Upload failed. Please try again.',
          ),
        );
      });
    }
  }

  Future<void> _pickThumbnail() => _handleImageSlotPick(
    purpose: 'business_thumbnail',
    apply: (s) => _thumbnailSlot = s,
  );

  Future<void> _pickLicense() =>
      _handleSlotPick(purpose: 'license', apply: (s) => _licenseSlot = s);

  Future<void> _pickIdProof() =>
      _handleSlotPick(purpose: 'id_proof', apply: (s) => _idProofSlot = s);

  Future<void> _pickTaxDocument() => _handleSlotPick(
    purpose: 'tax_document',
    apply: (s) => _taxDocumentSlot = s,
  );

  Future<void> _handleSlotRemove(
    _UploadSlotState slot,
    void Function(_UploadSlotState) apply,
  ) async {
    final id = slot.fileId;
    setState(() => apply(_UploadSlotState()));
    if (id == null) return;
    try {
      await _uploadService.deleteUpload(id);
    } catch (_) {
      // Best-effort cleanup — the slot is already cleared locally and its id
      // won't be sent in document_ids, so a failed server-side delete here
      // isn't blocking.
    }
  }

  Future<void> _removeLicense() =>
      _handleSlotRemove(_licenseSlot, (s) => _licenseSlot = s);

  Future<void> _removeIdProof() =>
      _handleSlotRemove(_idProofSlot, (s) => _idProofSlot = s);

  Future<void> _removeTaxDocument() =>
      _handleSlotRemove(_taxDocumentSlot, (s) => _taxDocumentSlot = s);

  Future<void> _removeThumbnail() =>
      _handleSlotRemove(_thumbnailSlot, (s) => _thumbnailSlot = s);

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  void _onProceedPressed() {
    if (_formKey.currentState?.validate() != true) return;
    if (!_licenseSlot.isUploaded ||
        !_idProofSlot.isUploaded ||
        !_taxDocumentSlot.isUploaded) {
      AppSnackbar.error(
        context,
        'Please upload License, ID Proof, and Tax Document.',
      );
      return;
    }
    context.read<BusinessSetupBloc>().add(
      BusinessSetupSubmitted(
        name: _businessNameController.text.trim(),
        categoryId: _selectedCategory!.id,
        addressLine: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        description: _descriptionController.text.trim(),
        gstNumber: _gstNumberController.text.trim(),
        documentIds: [
          _licenseSlot.fileId!,
          _idProofSlot.fileId!,
          _taxDocumentSlot.fileId!,
        ],
        thumbnailUploadIds: _thumbnailSlot.isUploaded
            ? [_thumbnailSlot.fileId!]
            : [],
      ),
    );
  }

  void _onBackPressed(BuildContext context) {
    context.go('/register');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onBackPressed(context);
      },
      child: Scaffold(
        appBar: AppAppBar(
          title: 'Business Setup',
          subtitle: 'Step 2 of 3',
          onLeadingPressed: () => _onBackPressed(context),
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<BusinessSetupBloc, BusinessSetupState>(
              listener: (context, state) {
                if (state is BusinessSetupSuccess) {
                  context.go('/operation-setup');
                } else if (state is BusinessSetupFailure) {
                  AppSnackbar.error(context, state.message);
                }
              },
            ),
            BlocListener<BusinessBloc, BusinessState>(
              listener: (context, state) {
                if (state is BusinessLoaded) {
                  _applyBusinessData(state.business);
                } else if (state is BusinessFailure) {
                  AppSnackbar.error(context, state.message);
                }
              },
            ),
          ],
          child: BlocBuilder<BusinessBloc, BusinessState>(
            builder: (context, businessState) {
              if (businessState is BusinessLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 1.5.h),
                        AppTextField(
                          labelText: 'Business Name',
                          hintText: 'Enter Business Name',
                          controller: _businessNameController,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) =>
                              _requiredValidator(value, 'Business name'),
                        ),
                        SizedBox(height: 1.5.h),
                        AppTextField(
                          labelText: 'Category',
                          hintText: 'Enter Category',
                          controller: _categoryController,
                          readOnly: true,
                          suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
                          onTap: _openCategoryPicker,
                          validator: (value) =>
                              _requiredValidator(value, 'Category'),
                        ),
                        SizedBox(height: 1.5.h),
                        AppTextField(
                          labelText: 'Description',
                          hintText: 'Enter Business Description',
                          controller: _descriptionController,
                          maxLines: 3,
                          validator: (value) =>
                              _requiredValidator(value, 'Description'),
                        ),
                        SizedBox(height: 1.5.h),
                        AppTextField(
                          labelText: 'Address',
                          hintText: 'Enter Address Line 1',
                          controller: _addressController,
                          validator: (value) =>
                              _requiredValidator(value, 'Address'),
                        ),
                        SizedBox(height: 1.5.h),
                        AppTextField(
                          labelText: 'City',
                          hintText: 'Enter City',
                          controller: _cityController,
                          validator: (value) =>
                              _requiredValidator(value, 'City'),
                        ),
                        SizedBox(height: 1.5.h),
                        AppTextField(
                          labelText: 'State',
                          hintText: 'Enter State',
                          controller: _stateController,
                          validator: (value) =>
                              _requiredValidator(value, 'State'),
                        ),
                        SizedBox(height: 1.5.h),
                        AppTextField(
                          labelText: 'Postal Code',
                          hintText: 'Enter Postal Code',
                          controller: _postalCodeController,
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              _requiredValidator(value, 'Postal code'),
                        ),
                        SizedBox(height: 1.5.h),
                        AppTextField(
                          labelText: 'GST Number',
                          hintText: 'Enter GST Number',
                          controller: _gstNumberController,
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) =>
                              _requiredValidator(value, 'GST number'),
                        ),
                        SizedBox(height: 1.5.h),
                        UploadSlotField(
                          label: 'Business Thumbnail',
                          status: _thumbnailSlot.status,
                          fileName: _thumbnailSlot.fileName,
                          errorMessage: _thumbnailSlot.errorMessage,
                          previewFile: _thumbnailSlot.previewFile,
                          previewUrl: _thumbnailSlot.previewUrl,
                          onTap: _pickThumbnail,
                          onRemove: _removeThumbnail,
                        ),
                        SizedBox(height: 1.5.h),
                        UploadSlotField(
                          label: 'License',
                          status: _licenseSlot.status,
                          fileName: _licenseSlot.fileName,
                          errorMessage: _licenseSlot.errorMessage,
                          previewFile: _licenseSlot.previewFile,
                          previewUrl: _licenseSlot.previewUrl,
                          onTap: _pickLicense,
                          onRemove: _removeLicense,
                        ),
                        SizedBox(height: 1.5.h),
                        UploadSlotField(
                          label: 'ID Proof',
                          status: _idProofSlot.status,
                          fileName: _idProofSlot.fileName,
                          errorMessage: _idProofSlot.errorMessage,
                          previewFile: _idProofSlot.previewFile,
                          previewUrl: _idProofSlot.previewUrl,
                          onTap: _pickIdProof,
                          onRemove: _removeIdProof,
                        ),
                        SizedBox(height: 1.5.h),
                        UploadSlotField(
                          label: 'Tax Document',
                          status: _taxDocumentSlot.status,
                          fileName: _taxDocumentSlot.fileName,
                          errorMessage: _taxDocumentSlot.errorMessage,
                          previewFile: _taxDocumentSlot.previewFile,
                          previewUrl: _taxDocumentSlot.previewUrl,
                          onTap: _pickTaxDocument,
                          onRemove: _removeTaxDocument,
                        ),
                        SizedBox(height: 2.h),
                        BlocBuilder<BusinessSetupBloc, BusinessSetupState>(
                          builder: (context, state) {
                            final isLoading = state is BusinessSetupLoading;
                            final isDisabled = isLoading || _anySlotUploading;
                            return SizedBox(
                              width: double.infinity,
                              child: AppButton(
                                label: isLoading
                                    ? 'Saving...'
                                    : 'Proceed Setup',
                                isLoading: isLoading,
                                onPressed: isDisabled
                                    ? null
                                    : _onProceedPressed,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 1.5.h),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
