import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

enum UploadSlotStatus { idle, uploading, uploaded, error }

class UploadSlotField extends StatelessWidget {
  final String label;
  final UploadSlotStatus status;
  final String? fileName;
  final String? errorMessage;
  final File? previewFile;
  final String? previewUrl;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const UploadSlotField({
    super.key,
    required this.label,
    required this.status,
    this.fileName,
    this.errorMessage,
    this.previewFile,
    this.previewUrl,
    required this.onTap,
    required this.onRemove,
  });

  bool get _isInteractive => status != UploadSlotStatus.uploading;

  @override
  Widget build(BuildContext context) {
    final isError = status == UploadSlotStatus.error;
    final showImagePreview =
        status == UploadSlotStatus.uploaded &&
        (previewFile != null || previewUrl != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        SizedBox(height: 0.6.h),
        if (showImagePreview)
          _buildImagePreview(context)
        else
          InkWell(
            onTap: _isInteractive ? onTap : null,
            borderRadius: BorderRadius.circular(3.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.1.w, vertical: 1.7.h),
              decoration: BoxDecoration(
                color: AppColors.textfieldFilledColor,
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(
                  color: isError ? AppColors.error : AppColors.borderLight,
                  width: 1.5,
                ),
              ),
              child: _buildContent(context),
            ),
          ),
        if (isError && errorMessage != null) ...[
          SizedBox(height: 0.5.h),
          Text(
            errorMessage!,
            style: TextStyle(fontSize: 13.5.sp, color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: _isInteractive ? onTap : null,
          borderRadius: BorderRadius.circular(2.56.w),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2.56.w),
            child: Container(
              width: 30.77.w,
              height: 30.77.w,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight),
              ),
              child: previewFile != null
                  ? Image.file(previewFile!, fit: BoxFit.cover)
                  : Image.network(
                      previewUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                          ? child
                          : const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                      errorBuilder: (_, _, _) => Icon(
                        Icons.broken_image_outlined,
                        size: 22.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
            ),
          ),
        ),
        Positioned(
          top: 0.47.h,
          right: 1.03.w,
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

  Widget _buildContent(BuildContext context) {
    switch (status) {
      case UploadSlotStatus.uploading:
        return Row(
          children: [
            SizedBox(
              width: 16.sp,
              height: 16.sp,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 3.w),
            Text(
              'Uploading...',
              style: TextStyle(fontSize: 15.sp, color: AppColors.textSecondary),
            ),
          ],
        );
      case UploadSlotStatus.uploaded:
        final isPdf = (fileName ?? '').toLowerCase().endsWith('.pdf');
        final accentColor = isPdf ? AppColors.error : AppColors.primary;
        return Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.1.w),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(2.3.w),
              ),
              child: Icon(
                isPdf ? Icons.picture_as_pdf_rounded : Icons.insert_drive_file_rounded,
                size: 20.sp,
                color: accentColor,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName ?? 'Uploaded',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    isPdf ? 'PDF Document' : 'Document uploaded',
                    style: TextStyle(fontSize: 12.5.sp, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            SizedBox(width: 2.w),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(3.08.w),
              child: Container(
                padding: EdgeInsets.all(1.1.w),
                decoration: BoxDecoration(
                  color: AppColors.textfieldFilledColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 16.sp, color: AppColors.textSecondary),
              ),
            ),
          ],
        );
      case UploadSlotStatus.error:
        return Row(
          children: [
            Icon(Icons.error_outline, size: 18.sp, color: AppColors.error),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                'Upload failed. Tap to retry.',
                style: TextStyle(fontSize: 15.sp, color: AppColors.error),
              ),
            ),
          ],
        );
      case UploadSlotStatus.idle:
        return Row(
          children: [
            Expanded(
              child: Text(
                'Upload $label',
                style: TextStyle(fontSize: 15.sp, color: AppColors.textSecondary),
              ),
            ),
            Icon(Icons.cloud_upload_outlined, size: 18.sp, color: AppColors.textSecondary),
          ],
        );
    }
  }
}

/// Square gallery-style tile used to render a single banner slot inline in a
/// [Wrap], rather than the full-width [UploadSlotField] layout.
class BannerUploadTile extends StatelessWidget {
  final UploadSlotStatus status;
  final File? previewFile;
  final String? previewUrl;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const BannerUploadTile({
    super.key,
    required this.status,
    this.previewFile,
    this.previewUrl,
    required this.onTap,
    required this.onRemove,
  });

  bool get _isInteractive => status != UploadSlotStatus.uploading;

  @override
  Widget build(BuildContext context) {
    final size = 26.w;
    final isError = status == UploadSlotStatus.error;
    final showImagePreview =
        status == UploadSlotStatus.uploaded &&
        (previewFile != null || previewUrl != null);

    if (showImagePreview) {
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              onTap: _isInteractive ? onTap : null,
              borderRadius: BorderRadius.circular(2.56.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2.56.w),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: previewFile != null
                      ? Image.file(previewFile!, fit: BoxFit.cover)
                      : Image.network(
                          previewUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) =>
                              progress == null
                              ? child
                              : const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                          errorBuilder: (_, _, _) => Icon(
                            Icons.broken_image_outlined,
                            size: 20.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                ),
              ),
            ),
            Positioned(
              top: -0.8.h,
              right: -1.5.w,
              child: InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(3.08.w),
                child: Container(
                  padding: EdgeInsets.all(0.9.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 12.sp, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: _isInteractive ? onTap : null,
      borderRadius: BorderRadius.circular(2.56.w),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.textfieldFilledColor,
          borderRadius: BorderRadius.circular(2.56.w),
          border: Border.all(
            color: isError ? AppColors.error : AppColors.borderLight,
            width: 1.5,
          ),
        ),
        child: Center(
          child: status == UploadSlotStatus.uploading
              ? SizedBox(
                  width: 18.sp,
                  height: 18.sp,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  isError ? Icons.error_outline : Icons.add_photo_alternate_outlined,
                  size: 22.sp,
                  color: isError ? AppColors.error : AppColors.textSecondary,
                ),
        ),
      ),
    );
  }
}

/// Trailing "+" tile shown at the end of the banner [Wrap] to add a new slot,
/// while the banner count is under the max.
class AddBannerTile extends StatelessWidget {
  final VoidCallback onTap;

  const AddBannerTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = 26.w;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(2.56.w),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.textfieldFilledColor,
          borderRadius: BorderRadius.circular(2.56.w),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Icon(Icons.add, size: 26.sp, color: AppColors.primary),
      ),
    );
  }
}
