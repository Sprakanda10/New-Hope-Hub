import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/registration_footer_widget.dart';
import './widgets/registration_form_widget.dart';
import './widgets/registration_header_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _isPasswordVisible = false;
  bool _isTermsAccepted = false;
  bool _isLoading = false;
  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String _passwordStrength = '';

  @override
  void initState() {
    super.initState();
    _setupValidationListeners();
  }

  void _setupValidationListeners() {
    _nameController.addListener(() => _validateName());
    _emailController.addListener(() => _validateEmail());
    _phoneController.addListener(() => _validatePhone());
    _passwordController.addListener(() => _validatePassword());
  }

  void _validateName() {
    setState(() {
      if (_nameController.text.isEmpty) {
        _nameError = null;
      } else if (_nameController.text.length < 2) {
        _nameError = 'Name must be at least 2 characters';
      } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(_nameController.text)) {
        _nameError = 'Name can only contain letters and spaces';
      } else {
        _nameError = null;
      }
    });
  }

  void _validateEmail() {
    setState(() {
      if (_emailController.text.isEmpty) {
        _emailError = null;
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
          .hasMatch(_emailController.text)) {
        _emailError = 'Please enter a valid email address';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePhone() {
    setState(() {
      if (_phoneController.text.isEmpty) {
        _phoneError = null;
      } else if (_phoneController.text.length < 10) {
        _phoneError = 'Phone number must be at least 10 digits';
      } else if (!RegExp(r'^[0-9+\-\s\(\)]+$')
          .hasMatch(_phoneController.text)) {
        _phoneError = 'Please enter a valid phone number';
      } else {
        _phoneError = null;
      }
    });
  }

  void _validatePassword() {
    setState(() {
      final password = _passwordController.text;
      if (password.isEmpty) {
        _passwordError = null;
        _passwordStrength = '';
      } else if (password.length < 8) {
        _passwordError = 'Password must be at least 8 characters';
        _passwordStrength = 'Weak';
      } else {
        _passwordError = null;
        int strength = 0;
        if (password.length >= 8) strength++;
        if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
        if (RegExp(r'[a-z]').hasMatch(password)) strength++;
        if (RegExp(r'[0-9]').hasMatch(password)) strength++;
        if (RegExp(r'[!@#\$&*~]').hasMatch(password)) strength++;

        if (strength <= 2) {
          _passwordStrength = 'Weak';
        } else if (strength <= 3) {
          _passwordStrength = 'Medium';
        } else {
          _passwordStrength = 'Strong';
        }
      }
    });
  }

  bool get _isFormValid {
    return _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _nameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _passwordError == null &&
        _isTermsAccepted;
  }

  Future<void> _handleRegistration() async {
    if (!_isFormValid) return;

    setState(() => _isLoading = true);

    try {
      // Use Supabase Auth for registration
      final response = await AuthService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      if (response.user != null) {
        // Success - trigger haptic feedback
        HapticFeedback.lightImpact();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration successful! Welcome to HopeHub.'),
              backgroundColor: AppTheme.getSuccessColor(true),
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Navigate to main feed
          Navigator.pushReplacementNamed(context, '/main-feed-screen');
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Registration failed. Please try again.';

        if (e.toString().contains('email_address_invalid')) {
          errorMessage = 'Please enter a valid email address.';
        } else if (e.toString().contains('signup_disabled')) {
          errorMessage = 'Registration is currently disabled.';
        } else if (e.toString().contains('weak_password')) {
          errorMessage =
              'Password is too weak. Please choose a stronger password.';
        } else if (e.toString().contains('email_address_not_authorized')) {
          errorMessage =
              'This email address is not authorized for registration.';
        } else if (e.toString().contains('User already registered')) {
          errorMessage = 'An account with this email already exists.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 2.h),

                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.lightTheme.colorScheme.outline,
                              ),
                            ),
                            child: CustomIconWidget(
                              iconName: 'arrow_back',
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                              size: 20,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // Header with logo and title
                      RegistrationHeaderWidget(),

                      SizedBox(height: 4.h),

                      // Registration form
                      Expanded(
                        child: RegistrationFormWidget(
                          formKey: _formKey,
                          nameController: _nameController,
                          emailController: _emailController,
                          phoneController: _phoneController,
                          passwordController: _passwordController,
                          nameFocus: _nameFocus,
                          emailFocus: _emailFocus,
                          phoneFocus: _phoneFocus,
                          passwordFocus: _passwordFocus,
                          isPasswordVisible: _isPasswordVisible,
                          isTermsAccepted: _isTermsAccepted,
                          isLoading: _isLoading,
                          nameError: _nameError,
                          emailError: _emailError,
                          phoneError: _phoneError,
                          passwordError: _passwordError,
                          passwordStrength: _passwordStrength,
                          isFormValid: _isFormValid,
                          onPasswordVisibilityToggle: () {
                            setState(
                                () => _isPasswordVisible = !_isPasswordVisible);
                          },
                          onTermsToggle: (value) {
                            setState(() => _isTermsAccepted = value ?? false);
                          },
                          onRegister: _handleRegistration,
                        ),
                      ),

                      SizedBox(height: 2.h),

                      // Footer with sign in link
                      RegistrationFooterWidget(),

                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
