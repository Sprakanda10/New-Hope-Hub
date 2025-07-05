import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/missing_person_card_widget.dart';

class MainFeedScreen extends StatefulWidget {
  const MainFeedScreen({super.key});

  @override
  State<MainFeedScreen> createState() => _MainFeedScreenState();
}

class _MainFeedScreenState extends State<MainFeedScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isRefreshing = false;
  List<Map<String, dynamic>> _missingPersons = [];
  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMissingPersons();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }

  void _setupRealtimeSubscription() {
    try {
      _realtimeChannel = MissingPersonService.subscribeToReports(
        onInsert: (newReport) {
          if (mounted && newReport['status'] == 'active') {
            setState(() {
              _missingPersons.insert(0, newReport);
            });

            // Show notification for new report
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'New missing person report: ${newReport['person_name']}'),
                backgroundColor: AppTheme.getWarningColor(true),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'View',
                  onPressed: () {
                    // Scroll to top to show the new report
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            );
          }
        },
        onUpdate: (updatedReport) {
          if (mounted) {
            setState(() {
              final index = _missingPersons
                  .indexWhere((r) => r['id'] == updatedReport['id']);
              if (index != -1) {
                if (updatedReport['status'] == 'active') {
                  _missingPersons[index] = updatedReport;
                } else {
                  // Remove if no longer active
                  _missingPersons.removeAt(index);
                }
              }
            });
          }
        },
        onDelete: (deletedReport) {
          if (mounted) {
            setState(() {
              _missingPersons
                  .removeWhere((r) => r['id'] == deletedReport['id']);
            });
          }
        },
      );
    } catch (e) {
      debugPrint('Failed to setup realtime subscription: $e');
    }
  }

  void _loadMissingPersons() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reports = await MissingPersonService.getActiveReports(limit: 50);
      if (mounted) {
        setState(() {
          _missingPersons = reports;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load reports: $e'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _refreshFeed() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final reports = await MissingPersonService.getActiveReports(limit: 50);
      if (mounted) {
        setState(() {
          _missingPersons = reports;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh feed: $e'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _getTimeAgo(String timestamp) {
    final now = DateTime.now();
    final reportTime = DateTime.parse(timestamp);
    final difference = now.difference(reportTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  void _navigateToCreatePost() {
    // Check if user is authenticated
    if (!AuthService.isAuthenticated()) {
      Navigator.pushNamed(context, '/login-screen');
      return;
    }
    Navigator.pushNamed(context, '/create-post-screen');
  }

  void _navigateToProfile() {
    // Check if user is authenticated
    if (!AuthService.isAuthenticated()) {
      Navigator.pushNamed(context, '/login-screen');
      return;
    }
    Navigator.pushNamed(context, '/profile-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        title: Text(
          'HopeHub',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            onPressed: _refreshFeed,
            icon: _isRefreshing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  )
                : CustomIconWidget(
                    iconName: 'refresh',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
          ),
          // Auth status indicator
          IconButton(
            onPressed: () {
              if (AuthService.isAuthenticated()) {
                _navigateToProfile();
              } else {
                Navigator.pushNamed(context, '/login-screen');
              }
            },
            icon: CustomIconWidget(
              iconName:
                  AuthService.isAuthenticated() ? 'account_circle' : 'login',
              color: AuthService.isAuthenticated()
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          SizedBox(width: 2.w),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.lightTheme.tabBarTheme.labelColor,
          unselectedLabelColor:
              AppTheme.lightTheme.tabBarTheme.unselectedLabelColor,
          indicatorColor: AppTheme.lightTheme.tabBarTheme.indicatorColor,
          labelStyle: AppTheme.lightTheme.tabBarTheme.labelStyle,
          unselectedLabelStyle:
              AppTheme.lightTheme.tabBarTheme.unselectedLabelStyle,
          onTap: (index) {
            if (index == 1) {
              _navigateToCreatePost();
            } else if (index == 2) {
              _navigateToProfile();
            }
          },
          tabs: const [
            Tab(text: 'Feed'),
            Tab(text: 'Create Post'),
            Tab(text: 'Profile'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildFeedTab(),
            Container(), // Placeholder for Create Post tab
            Container(), // Placeholder for Profile tab
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePost,
        backgroundColor:
            AppTheme.lightTheme.floatingActionButtonTheme.backgroundColor,
        foregroundColor:
            AppTheme.lightTheme.floatingActionButtonTheme.foregroundColor,
        elevation: AppTheme.lightTheme.floatingActionButtonTheme.elevation,
        shape: AppTheme.lightTheme.floatingActionButtonTheme.shape,
        child: CustomIconWidget(
          iconName: 'add',
          color: AppTheme.lightTheme.colorScheme.onPrimary,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildFeedTab() {
    if (_isLoading) {
      return _buildSkeletonLoader();
    }

    if (_missingPersons.isEmpty) {
      return EmptyStateWidget(
        onCreateReport: _navigateToCreatePost,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshFeed,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.all(4.w),
        itemCount: _missingPersons.length,
        separatorBuilder: (context, index) => SizedBox(height: 4.w),
        itemBuilder: (context, index) {
          final person = _missingPersons[index];
          final reporterName =
              person['user_profiles']?['full_name'] ?? 'Unknown Reporter';

          return MissingPersonCardWidget(
            name: person['person_name'] as String,
            age: person['person_age'] as int,
            lastSeenLocation: person['last_seen_location'] as String,
            description: person['description'] as String,
            imageUrl: person['image_url'] as String? ?? '',
            timeAgo: _getTimeAgo(person['created_at'] as String),
            reportedBy: reporterName,
            contactPhone: person['contact_phone'] as String? ?? '',
            caseId: person['case_id'] as String,
            onTap: () {
              // Navigate to detailed view
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Viewing details for ${person['person_name']}'),
                  backgroundColor:
                      AppTheme.lightTheme.snackBarTheme.backgroundColor,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.separated(
      padding: EdgeInsets.all(4.w),
      itemCount: 5,
      separatorBuilder: (context, index) => SizedBox(height: 4.w),
      itemBuilder: (context, index) {
        return Card(
          elevation: AppTheme.lightTheme.cardTheme.elevation,
          shape: AppTheme.lightTheme.cardTheme.shape,
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 15.w,
                      height: 15.w,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40.w,
                            height: 2.h,
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(1.w),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Container(
                            width: 60.w,
                            height: 1.5.h,
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(1.w),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Container(
                  width: double.infinity,
                  height: 1.5.h,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(1.w),
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  width: 70.w,
                  height: 1.5.h,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(1.w),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
