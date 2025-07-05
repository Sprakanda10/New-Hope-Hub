import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text);

      if (response.user != null) {
        // Success - trigger haptic feedback
        HapticFeedback.lightImpact();

        if (mounted) {
          // Navigate to main feed
          Navigator.pushReplacementNamed(context, '/main-feed-screen');
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Login failed. Please try again.';

        if (e.toString().contains('invalid_credentials')) {
          errorMessage = 'Invalid email or password.';
        } else if (e.toString().contains('email_not_confirmed')) {
          errorMessage = 'Please check your email and confirm your account.';
        } else if (e.toString().contains('too_many_requests')) {
          errorMessage = 'Too many attempts. Please try again later.';
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter your email address first.'),
          behavior: SnackBarBehavior.floating));
      return;
    }

    try {
      await AuthService.resetPassword(_emailController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Password reset email sent to ${_emailController.text.trim()}'),
            backgroundColor: AppTheme.getSuccessColor(true),
            behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to send reset email. Please try again.'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating));
      }
    }
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
                                MediaQuery.of(context).padding.bottom),
                        child: IntrinsicHeight(
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6.w),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      SizedBox(height: 8.h),

                                      // Logo and welcome text
                                      Column(children: [
                                        CustomImageWidget(
                                            imageUrl: '', width: 20.w, height: 20.w),
                                        SizedBox(height: 3.h),
                                        Text('Welcome Back',
                                            style: AppTheme.lightTheme.textTheme
                                                .headlineMedium,
                                            textAlign: TextAlign.center),
                                        SizedBox(height: 1.h),
                                        Text(
                                            'Sign in to continue helping our community',
                                            style: AppTheme
                                                .lightTheme.textTheme.bodyMedium
                                                ?.copyWith(
                                                    color: AppTheme.lightTheme
                                                        .colorScheme.onSurface
                                                        .withValues(
                                                            alpha: 0.7)),
                                            textAlign: TextAlign.center),
                                      ]),

                                      SizedBox(height: 6.h),

                                      // Login form
                                      Expanded(
                                          child: Form(
                                              key: _formKey,
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    // Email field
                                                    TextFormField(
                                                        controller:
                                                            _emailController,
                                                        focusNode: _emailFocus,
                                                        keyboardType:
                                                            TextInputType
                                                                .emailAddress,
                                                        textInputAction:
                                                            TextInputAction
                                                                .next,
                                                        decoration: InputDecoration(
                                                            labelText: 'Email',
                                                            prefixIcon: CustomIconWidget(
                                                                iconName:
                                                                    'email',
                                                                size: 5.w,
                                                                color: AppTheme
                                                                    .lightTheme
                                                                    .colorScheme
                                                                    .onSurface
                                                                    .withValues(
                                                                        alpha:
                                                                            0.6))),
                                                        validator: (value) {
                                                          if (value?.isEmpty ??
                                                              true) {
                                                            return 'Please enter your email';
                                                          }
                                                          if (!RegExp(
                                                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                                              .hasMatch(
                                                                  value!)) {
                                                            return 'Please enter a valid email address';
                                                          }
                                                          return null;
                                                        },
                                                        onFieldSubmitted: (_) =>
                                                            _passwordFocus
                                                                .requestFocus()),

                                                    SizedBox(height: 3.h),

                                                    // Password field
                                                    TextFormField(
                                                        controller:
                                                            _passwordController,
                                                        focusNode:
                                                            _passwordFocus,
                                                        obscureText:
                                                            !_isPasswordVisible,
                                                        textInputAction: TextInputAction
                                                            .done,
                                                        decoration: InputDecoration(
                                                            labelText:
                                                                'Password',
                                                            prefixIcon: CustomIconWidget(
                                                                iconName:
                                                                    'lock',
                                                                size: 5.w,
                                                                color: AppTheme
                                                                    .lightTheme
                                                                    .colorScheme
                                                                    .onSurface
                                                                    .withValues(
                                                                        alpha:
                                                                            0.6)),
                                                            suffixIcon: GestureDetector(
                                                                onTap: () => setState(() => _isPasswordVisible =
                                                                    !_isPasswordVisible),
                                                                child: CustomIconWidget(
                                                                    iconName: _isPasswordVisible
                                                                        ? 'visibility_off'
                                                                        : 'visibility',
                                                                    size: 5.w,
                                                                    color: AppTheme
                                                                        .lightTheme
                                                                        .colorScheme
                                                                        .onSurface
                                                                        .withValues(alpha: 0.6)))),
                                                        validator: (value) {
                                                          if (value?.isEmpty ??
                                                              true) {
                                                            return 'Please enter your password';
                                                          }
                                                          return null;
                                                        },
                                                        onFieldSubmitted: (_) => _handleLogin()),

                                                    SizedBox(height: 2.h),

                                                    // Remember me and forgot password
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(children: [
                                                            Checkbox(
                                                                value:
                                                                    _rememberMe,
                                                                onChanged: (value) =>
                                                                    setState(() =>
                                                                        _rememberMe =
                                                                            value ??
                                                                                false)),
                                                            Text('Remember me',
                                                                style: AppTheme
                                                                    .lightTheme
                                                                    .textTheme
                                                                    .bodyMedium),
                                                          ]),
                                                          TextButton(
                                                              onPressed:
                                                                  _handleForgotPassword,
                                                              child: Text(
                                                                  'Forgot Password?',
                                                                  style: AppTheme
                                                                      .lightTheme
                                                                      .textTheme
                                                                      .bodyMedium
                                                                      ?.copyWith(
                                                                          color: AppTheme
                                                                              .lightTheme
                                                                              .colorScheme
                                                                              .primary))),
                                                        ]),

                                                    SizedBox(height: 4.h),

                                                    // Login button
                                                    ElevatedButton(
                                                        onPressed: _isLoading
                                                            ? null
                                                            : _handleLogin,
                                                        child: _isLoading
                                                            ? SizedBox(
                                                                width: 5.w,
                                                                height: 5.w,
                                                                child: CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2,
                                                                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme
                                                                        .lightTheme
                                                                        .colorScheme
                                                                        .onPrimary)))
                                                            : Text('Sign In')),

                                                    const Spacer(),

                                                    // Sign up link
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                              'Don\'t have an account? ',
                                                              style: AppTheme
                                                                  .lightTheme
                                                                  .textTheme
                                                                  .bodyMedium),
                                                          TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pushNamed(
                                                                      context,
                                                                      '/registration-screen'),
                                                              child: Text(
                                                                  'Sign Up',
                                                                  style: AppTheme
                                                                      .lightTheme
                                                                      .textTheme
                                                                      .bodyMedium
                                                                      ?.copyWith(
                                                                          color: AppTheme
                                                                              .lightTheme
                                                                              .colorScheme
                                                                              .primary,
                                                                          fontWeight:
                                                                              FontWeight.w600))),
                                                        ]),

                                                    SizedBox(height: 2.h),
                                                  ]))),
                                    ]))))))));
  }
}