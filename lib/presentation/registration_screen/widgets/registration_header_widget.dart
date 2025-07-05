import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RegistrationHeaderWidget extends StatelessWidget {
  const RegistrationHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Logo
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/logoo.png',
            fit: BoxFit.cover,
          ),
          // child: Center(
          //   child: CustomIconWidget(
          //     iconName: 'shop',
          //     color: AppTheme.lightTheme.colorScheme.onPrimary,
          //     size: 8.w,
          //   ),
          // ),
        ),

        SizedBox(height: 3.h),

        // App Name
        Text(
          'HopeHub',
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 1.h),

        // Welcome message
        Text(
          'Create your account to help keep\nour community safe',
          textAlign: TextAlign.center,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.7),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
