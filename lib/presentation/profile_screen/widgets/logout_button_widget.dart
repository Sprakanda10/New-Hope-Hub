import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LogoutButtonWidget extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutButtonWidget({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: OutlinedButton(
        onPressed: onLogout,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.lightTheme.colorScheme.error,
          side: BorderSide(
            color: AppTheme.lightTheme.colorScheme.error,
            width: 1.5,
          ),
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'logout',
              size: 5.w,
              color: AppTheme.lightTheme.colorScheme.error,
            ),
            SizedBox(width: 2.w),
            Text(
              'Logout',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
