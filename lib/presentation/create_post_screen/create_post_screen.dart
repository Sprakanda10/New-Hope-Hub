import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/person_info_form_widget.dart';
import './widgets/photo_upload_widget.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedImagePath;
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _setupTextControllerListeners();
    _checkAuthentication();
  }

  void _checkAuthentication() {
    if (!AuthService.isAuthenticated()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login-screen');
      });
    }
  }

  void _setupTextControllerListeners() {
    _nameController.addListener(_onContentChanged);
    _ageController.addListener(_onContentChanged);
    _locationController.addListener(_onContentChanged);
    _descriptionController.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  void _onImageSelected(String imagePath) {
    setState(() {
      _selectedImagePath = imagePath;
      _hasUnsavedChanges = true;
    });
  }

  bool get _canPost {
    return _nameController.text.trim().isNotEmpty &&
        _ageController.text.trim().isNotEmpty &&
        _locationController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty;
  }

  Future<void> _handlePost() async {
    if (!_formKey.currentState!.validate() || !_canPost) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final age = int.tryParse(_ageController.text.trim());
      if (age == null || age < 0 || age > 150) {
        throw Exception('Please enter a valid age between 0 and 150');
      }

      final report = await MissingPersonService.createReport(
        personName: _nameController.text.trim(),
        personAge: age,
        lastSeenLocation: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        imagePath: _selectedImagePath,
      );

      // Haptic feedback for success
      HapticFeedback.lightImpact();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Missing person report posted successfully.\nCase ID: ${report['case_id']}'),
            backgroundColor: AppTheme.getSuccessColor(true),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );

        // Navigate back to main feed
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to post report. Please try again.';

        if (e.toString().contains('age')) {
          errorMessage = 'Please enter a valid age between 0 and 150.';
        } else if (e.toString().contains('image')) {
          errorMessage = 'Failed to upload image. Please try again.';
        } else if (e.toString().contains('authenticated')) {
          errorMessage = 'Please sign in to create a report.';
          Navigator.pushReplacementNamed(context, '/login-screen');
          return;
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Discard changes?'),
        content:
            Text('You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Discard'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
          elevation: 0,
          leading: TextButton(
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop) Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.secondary,
              ),
            ),
          ),
          leadingWidth: 20.w,
          title: Text(
            'Report Missing Person',
            style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 4.w),
              child: TextButton(
                onPressed: _canPost && !_isLoading ? _handlePost : null,
                child: _isLoading
                    ? SizedBox(
                        width: 4.w,
                        height: 4.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      )
                    : Text(
                        'Post',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: _canPost
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.38),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo Upload Section
                  PhotoUploadWidget(
                    selectedImagePath: _selectedImagePath,
                    onImageSelected: _onImageSelected,
                  ),

                  SizedBox(height: 3.h),

                  // Person Information Form
                  PersonInfoFormWidget(
                    nameController: _nameController,
                    ageController: _ageController,
                    locationController: _locationController,
                    descriptionController: _descriptionController,
                  ),

                  SizedBox(height: 4.h),

                  // Emergency Contact Info
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'info',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 5.w,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Important Information',
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Your report will be shared with the community immediately. Please ensure all information is accurate. Contact local authorities if this is an emergency.',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10.h), // Extra space for keyboard
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
