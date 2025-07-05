import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onCreateReport;

  const EmptyStateWidget({
    super.key,
    required this.onCreateReport,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIllustration(),
            SizedBox(height: 4.h),
            _buildTitle(),
            SizedBox(height: 2.h),
            _buildDescription(),
            SizedBox(height: 4.h),
            _buildCreateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: 'people_outline',
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 20.w,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'No Reports Yet',
      style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
        color: AppTheme.lightTheme.colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    return Text(
      'Be the first to help your community by reporting a missing person. Every report can make a difference in bringing someone home safely.',
      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCreateButton() {
    return ElevatedButton.icon(
      onPressed: onCreateReport,
      icon: CustomIconWidget(
        iconName: 'add',
        color: AppTheme.lightTheme.colorScheme.onPrimary,
        size: 20,
      ),
      label: Text(
        'Create First Report',
        style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: AppTheme.lightTheme.elevatedButtonTheme.style?.copyWith(
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        ),
        minimumSize: WidgetStateProperty.all(Size(50.w, 6.h)),
      ),
    );
  }
}
