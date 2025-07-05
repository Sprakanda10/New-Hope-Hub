import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PhotoUploadWidget extends StatelessWidget {
  final String? selectedImagePath;
  final Function(String) onImageSelected;

  const PhotoUploadWidget({
    super.key,
    this.selectedImagePath,
    required this.onImageSelected,
  });

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Add Photo',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: _buildSourceOption(
                      context,
                      icon: 'camera_alt',
                      label: 'Camera',
                      onTap: () => _selectFromCamera(context),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: _buildSourceOption(
                      context,
                      icon: 'photo_library',
                      label: 'Gallery',
                      onTap: () => _selectFromGallery(context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceOption(
    BuildContext context, {
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 8.w,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _selectFromCamera(BuildContext context) {
    Navigator.of(context).pop();
    // Simulate camera capture
    Future.delayed(Duration(milliseconds: 500), () {
      onImageSelected(
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop');
    });
  }

  void _selectFromGallery(BuildContext context) {
    Navigator.of(context).pop();
    // Simulate gallery selection
    Future.delayed(Duration(milliseconds: 500), () {
      onImageSelected(
          'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400&h=400&fit=crop');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 30.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedImagePath != null
              ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3)
              : AppTheme.lightTheme.colorScheme.outline,
          width: selectedImagePath != null ? 2 : 1,
        ),
      ),
      child: selectedImagePath != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomImageWidget(
                    imageUrl: selectedImagePath!,
                    width: double.infinity,
                    height: 30.h,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 2.w,
                  right: 2.w,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => _showImageSourceDialog(context),
                      icon: CustomIconWidget(
                        iconName: 'edit',
                        color: Colors.white,
                        size: 5.w,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : InkWell(
              onTap: () => _showImageSourceDialog(context),
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: double.infinity,
                height: 30.h,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'add_a_photo',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 8.w,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Add Photo',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Tap to add a photo of the missing person',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
