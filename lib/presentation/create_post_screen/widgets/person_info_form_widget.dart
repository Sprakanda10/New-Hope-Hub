import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PersonInfoFormWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController locationController;
  final TextEditingController descriptionController;

  const PersonInfoFormWidget({
    super.key,
    required this.nameController,
    required this.ageController,
    required this.locationController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Person Information',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),

        // Name Field
        _buildInputField(
          controller: nameController,
          label: 'Full Name *',
          hint: 'Enter the person\'s full name',
          icon: 'person',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Name is required';
            }
            return null;
          },
        ),

        SizedBox(height: 2.h),

        // Age Field
        _buildInputField(
          controller: ageController,
          label: 'Age *',
          hint: 'Enter age',
          icon: 'cake',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Age is required';
            }
            final age = int.tryParse(value);
            if (age == null || age < 0 || age > 150) {
              return 'Please enter a valid age';
            }
            return null;
          },
        ),

        SizedBox(height: 2.h),

        // Last Seen Location Field
        _buildInputField(
          controller: locationController,
          label: 'Last Seen Location *',
          hint: 'Enter the last known location',
          icon: 'location_on',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Last seen location is required';
            }
            return null;
          },
        ),

        SizedBox(height: 2.h),

        // Description Field
        _buildInputField(
          controller: descriptionController,
          label: 'Additional Details',
          hint: 'Describe clothing, physical features, circumstances...',
          icon: 'description',
          maxLines: 4,
          isOptional: true,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          maxLines: maxLines,
          minLines: maxLines > 1 ? 3 : 1,
          style: AppTheme.lightTheme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTheme.lightTheme.inputDecorationTheme.hintStyle,
            filled: true,
            fillColor: AppTheme.lightTheme.colorScheme.surface,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: maxLines > 1 ? 2.h : 1.5.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.error,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
