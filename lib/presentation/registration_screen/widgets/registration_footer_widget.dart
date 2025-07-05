import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class RegistrationFooterWidget extends StatelessWidget {
  const RegistrationFooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacementNamed(context, '/login-screen');
        },
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
            children: [
              const TextSpan(text: 'Already have an account? '),
              TextSpan(
                text: 'Sign In',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
