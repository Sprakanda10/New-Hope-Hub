import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RegistrationFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final FocusNode nameFocus;
  final FocusNode emailFocus;
  final FocusNode phoneFocus;
  final FocusNode passwordFocus;
  final bool isPasswordVisible;
  final bool isTermsAccepted;
  final bool isLoading;
  final String? nameError;
  final String? emailError;
  final String? phoneError;
  final String? passwordError;
  final String passwordStrength;
  final bool isFormValid;
  final VoidCallback onPasswordVisibilityToggle;
  final ValueChanged<bool?> onTermsToggle;
  final VoidCallback onRegister;

  const RegistrationFormWidget({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.nameFocus,
    required this.emailFocus,
    required this.phoneFocus,
    required this.passwordFocus,
    required this.isPasswordVisible,
    required this.isTermsAccepted,
    required this.isLoading,
    required this.nameError,
    required this.emailError,
    required this.phoneError,
    required this.passwordError,
    required this.passwordStrength,
    required this.isFormValid,
    required this.onPasswordVisibilityToggle,
    required this.onTermsToggle,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name field
          _buildInputField(
            controller: nameController,
            focusNode: nameFocus,
            nextFocus: emailFocus,
            label: 'Full Name',
            hint: 'Enter your full name',
            iconName: 'person',
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            error: nameError,
          ),

          SizedBox(height: 3.h),

          // Email field
          _buildInputField(
            controller: emailController,
            focusNode: emailFocus,
            nextFocus: phoneFocus,
            label: 'Email Address',
            hint: 'Enter your email address',
            iconName: 'email',
            keyboardType: TextInputType.emailAddress,
            error: emailError,
          ),

          SizedBox(height: 3.h),

          // Phone field
          _buildInputField(
            controller: phoneController,
            focusNode: phoneFocus,
            nextFocus: passwordFocus,
            label: 'Phone Number',
            hint: 'Enter your phone number',
            iconName: 'phone',
            keyboardType: TextInputType.phone,
            error: phoneError,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s\(\)]')),
            ],
          ),

          SizedBox(height: 3.h),

          // Password field
          _buildPasswordField(),

          SizedBox(height: 4.h),

          // Terms and Privacy checkbox
          _buildTermsCheckbox(),

          SizedBox(height: 4.h),

          // Create Account button
          _buildCreateAccountButton(),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    required String label,
    required String hint,
    required String iconName,
    required TextInputType keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? error,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.colorScheme.shadow
                    .withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            inputFormatters: inputFormatters,
            textInputAction:
                nextFocus != null ? TextInputAction.next : TextInputAction.done,
            onFieldSubmitted: (_) {
              if (nextFocus != null) {
                FocusScope.of(focusNode.context!).requestFocus(nextFocus);
              }
            },
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: iconName,
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: error != null
                      ? AppTheme.lightTheme.colorScheme.error
                      : AppTheme.lightTheme.colorScheme.outline,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: error != null
                      ? AppTheme.lightTheme.colorScheme.error
                      : AppTheme.lightTheme.colorScheme.outline,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: error != null
                      ? AppTheme.lightTheme.colorScheme.error
                      : AppTheme.lightTheme.colorScheme.secondary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppTheme.lightTheme.colorScheme.surface,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            ),
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
        ),
        if (error != null) ...[
          SizedBox(height: 0.5.h),
          Padding(
            padding: EdgeInsets.only(left: 2.w),
            child: Text(
              error,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.colorScheme.shadow
                    .withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: passwordController,
            focusNode: passwordFocus,
            obscureText: !isPasswordVisible,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'lock',
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                  size: 20,
                ),
              ),
              suffixIcon: GestureDetector(
                onTap: onPasswordVisibilityToggle,
                child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName:
                        isPasswordVisible ? 'visibility_off' : 'visibility',
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                    size: 20,
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: passwordError != null
                      ? AppTheme.lightTheme.colorScheme.error
                      : AppTheme.lightTheme.colorScheme.outline,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: passwordError != null
                      ? AppTheme.lightTheme.colorScheme.error
                      : AppTheme.lightTheme.colorScheme.outline,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: passwordError != null
                      ? AppTheme.lightTheme.colorScheme.error
                      : AppTheme.lightTheme.colorScheme.secondary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppTheme.lightTheme.colorScheme.surface,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            ),
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
        ),
        if (passwordError != null) ...[
          SizedBox(height: 0.5.h),
          Padding(
            padding: EdgeInsets.only(left: 2.w),
            child: Text(
              passwordError!,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ),
        ],
        if (passwordStrength.isNotEmpty) ...[
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.only(left: 2.w),
            child: Row(
              children: [
                Text(
                  'Password strength: ',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  passwordStrength,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: _getPasswordStrengthColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Color _getPasswordStrengthColor() {
    switch (passwordStrength) {
      case 'Weak':
        return AppTheme.lightTheme.colorScheme.error;
      case 'Medium':
        return AppTheme.getWarningColor(true);
      case 'Strong':
        return AppTheme.getSuccessColor(true);
      default:
        return AppTheme.lightTheme.colorScheme.onSurface;
    }
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 6.w,
          height: 6.w,
          child: Checkbox(
            value: isTermsAccepted,
            onChanged: onTermsToggle,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: GestureDetector(
            onTap: () => onTermsToggle(!isTermsAccepted),
            child: RichText(
              text: TextSpan(
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.8),
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateAccountButton() {
    return Container(
      width: double.infinity,
      height: 6.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isFormValid
            ? [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isFormValid && !isLoading ? onRegister : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFormValid
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.outline,
          foregroundColor: isFormValid
              ? AppTheme.lightTheme.colorScheme.onPrimary
              : AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 5.w,
                height: 5.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.colorScheme.onPrimary,
                  ),
                ),
              )
            : Text(
                'Create Account',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: isFormValid
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
