import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/logout_button_widget.dart';
import './widgets/my_reports_section_widget.dart';
import './widgets/settings_list_widget.dart';
import './widgets/user_info_card_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userProfile;
  List<Map<String, dynamic>> _userReports = [];
  bool _isLoading = true;
  bool _isLoadingReports = true;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadData();
  }

  void _checkAuthAndLoadData() {
    if (!AuthService.isAuthenticated()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login-screen');
      });
      return;
    }

    _loadUserProfile();
    _loadUserReports();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await AuthService.getCurrentUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to load profile: $e'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating));
      }
    }
  }

  Future<void> _loadUserReports() async {
    try {
      final reports = await MissingPersonService.getUserReports(limit: 20);
      if (mounted) {
        setState(() {
          _userReports = reports;
          _isLoadingReports = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingReports = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to load reports: $e'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating));
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await AuthService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/main-feed-screen', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to sign out: $e'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating));
      }
    }
  }

  Future<void> _refreshProfile() async {
    await Future.wait([
      _loadUserProfile(),
      _loadUserReports(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
            backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
            elevation: AppTheme.lightTheme.appBarTheme.elevation,
            title: Text('Profile',
                style: AppTheme.lightTheme.appBarTheme.titleTextStyle),
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24)),
            actions: [
              IconButton(
                  onPressed: _refreshProfile,
                  icon: CustomIconWidget(
                      iconName: 'refresh',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 24)),
              SizedBox(width: 2.w),
            ]),
        body: SafeArea(
            child: _isLoading
                ? _buildLoadingState()
                : RefreshIndicator(
                    onRefresh: _refreshProfile,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User Info Card
                              UserInfoCardWidget(
                                  userProfile: _userProfile,
                                  onEditProfile: () {
                                    // TODO: Navigate to edit profile screen
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Edit profile feature coming soon'),
                                            behavior:
                                                SnackBarBehavior.floating));
                                  }),

                              SizedBox(height: 4.h),

                              // My Reports Section
                              MyReportsSectionWidget(
                                  userReports: _userReports,
                                  isLoading: _isLoadingReports,
                                  onViewAllReports: () {
                                    // TODO: Navigate to all reports screen
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'View all reports feature coming soon'),
                                            behavior:
                                                SnackBarBehavior.floating));
                                  },
                                  onReportTap: (report) {
                                    // TODO: Navigate to report details
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Viewing report: ${report['case_id']}'),
                                            behavior:
                                                SnackBarBehavior.floating));
                                  }),

                              SizedBox(height: 4.h),

                              // Settings List
                              SettingsListWidget(
                                onPrivacySettings: () {
                                  // TODO: Navigate to privacy settings
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Privacy settings feature coming soon'),
                                          behavior: SnackBarBehavior.floating));
                                }, 
                                onEditProfile: () {
                                  // Handle edit profile action
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Edit profile feature coming soon'),
                                          behavior: SnackBarBehavior.floating));
                                },
                                onNotificationSettings: () {
                                  // Handle notification settings action
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Notification settings feature coming soon'),
                                          behavior: SnackBarBehavior.floating));
                                },
                                onAbout: () {
                                  // TODO: Navigate to about screen
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('About feature coming soon'),
                                          behavior: SnackBarBehavior.floating));
                                }),

                              SizedBox(height: 4.h),

                              // Logout Button
                              LogoutButtonWidget(onLogout: _handleLogout),

                              SizedBox(height: 2.h),
                            ])))));
  }

  Widget _buildLoadingState() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.colorScheme.primary)),
      SizedBox(height: 2.h),
      Text('Loading profile...',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7))),
    ]));
  }
}