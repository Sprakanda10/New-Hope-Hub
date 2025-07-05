import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MyReportsSectionWidget extends StatelessWidget {
  final List<Map<String, dynamic>> userReports;
  final bool isLoading;
  final VoidCallback onViewAllReports;
  final Function(Map<String, dynamic>) onReportTap;

  const MyReportsSectionWidget({
    super.key,
    required this.userReports,
    required this.isLoading,
    required this.onViewAllReports,
    required this.onReportTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Section header
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('My Reports',
            style: AppTheme.lightTheme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w600)),
        if (userReports.isNotEmpty)
          TextButton(
              onPressed: onViewAllReports,
              child: Text('View All',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500))),
      ]),

      SizedBox(height: 2.h),

      // Reports content
      if (isLoading)
        _buildLoadingState()
      else if (userReports.isEmpty)
        _buildEmptyState()
      else
        _buildReportsList(),
    ]);
  }

  Widget _buildLoadingState() {
    return SizedBox(
        height: 20.h,
        child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.lightTheme.colorScheme.primary)),
          SizedBox(height: 2.h),
          Text('Loading your reports...',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6))),
        ])));
  }

  Widget _buildEmptyState() {
    return Card(
        elevation: AppTheme.lightTheme.cardTheme.elevation,
        shape: AppTheme.lightTheme.cardTheme.shape,
        child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(6.w),
            child: Column(children: [
              CustomIconWidget(
                  iconName: 'article',
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.4),
                  size: 15.w),
              SizedBox(height: 2.h),
              Text('No Reports Yet',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6))),
              SizedBox(height: 1.h),
              Text(
                  'You haven\'t created any missing person reports yet. Tap the + button to create your first report.',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.5)),
                  textAlign: TextAlign.center),
            ])));
  }

  Widget _buildReportsList() {
    final displayReports =
        userReports.take(3).toList(); // Show only first 3 reports

    return Column(children: [
      // Statistics row
      Card(
          elevation: AppTheme.lightTheme.cardTheme.elevation,
          shape: AppTheme.lightTheme.cardTheme.shape,
          child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(children: [
                Expanded(
                    child: _buildStatItem(
                        'Total Reports',
                        userReports.length.toString(),
                        AppTheme.lightTheme.colorScheme.primary)),
                Container(
                    width: 1,
                    height: 6.h,
                    color: AppTheme.lightTheme.colorScheme.outline),
                Expanded(
                    child: _buildStatItem(
                        'Active',
                        userReports
                            .where((r) => r['status'] == 'active')
                            .length
                            .toString(),
                        AppTheme.getWarningColor(true))),
                Container(
                    width: 1,
                    height: 6.h,
                    color: AppTheme.lightTheme.colorScheme.outline),
                Expanded(
                    child: _buildStatItem(
                        'Found',
                        userReports
                            .where((r) => r['status'] == 'found')
                            .length
                            .toString(),
                        AppTheme.getSuccessColor(true))),
              ]))),

      SizedBox(height: 2.h),

      // Recent reports list
      Column(
          children: displayReports
              .map((report) => _buildReportCard(report))
              .toList()),
    ]);
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(children: [
      Text(value,
          style: AppTheme.lightTheme.textTheme.headlineSmall
              ?.copyWith(color: color, fontWeight: FontWeight.w700)),
      SizedBox(height: 0.5.h),
      Text(label,
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6)),
          textAlign: TextAlign.center),
    ]);
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final personName = report['person_name'] as String? ?? 'Unknown';
    final caseId = report['case_id'] as String? ?? 'N/A';
    final status = report['status'] as String? ?? 'unknown';
    final createdAt = report['created_at'] as String?;
    final imageUrl = report['image_url'] as String?;

    String timeAgo = '';
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        final now = DateTime.now();
        final difference = now.difference(date);

        if (difference.inDays > 0) {
          timeAgo = '${difference.inDays}d ago';
        } else if (difference.inHours > 0) {
          timeAgo = '${difference.inHours}h ago';
        } else {
          timeAgo = '${difference.inMinutes}m ago';
        }
      } catch (e) {
        timeAgo = 'Unknown';
      }
    }

    return Container(
        margin: EdgeInsets.only(bottom: 2.h),
        child: Card(
            elevation: AppTheme.lightTheme.cardTheme.elevation,
            shape: AppTheme.lightTheme.cardTheme.shape,
            child: InkWell(
                onTap: () => onReportTap(report),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: Row(children: [
                      // Report image or placeholder
                      Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppTheme.lightTheme.colorScheme
                                  .surfaceContainerHighest),
                          child: imageUrl?.isNotEmpty == true
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CustomImageWidget(
                                      imageUrl: imageUrl,
                                      width: 12.w,
                                      height: 12.w,
                                      fit: BoxFit.cover))
                              : Icon(Icons.person,
                                  size: 6.w,
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.4))),

                      SizedBox(width: 3.w),

                      // Report details
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(personName,
                                style: AppTheme.lightTheme.textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            SizedBox(height: 0.5.h),
                            Text('Case ID: $caseId',
                                style: AppTheme.getMonospaceStyle(
                                    isLight: true, fontSize: 12)),
                            SizedBox(height: 0.5.h),
                            Text(timeAgo,
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSurface
                                            .withValues(alpha: 0.6))),
                          ])),

                      // Status badge
                      Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                              color: _getStatusColor(status)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: _getStatusColor(status), width: 1)),
                          child: Text(_getStatusDisplayName(status),
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                      color: _getStatusColor(status),
                                      fontWeight: FontWeight.w500))),
                    ])))));
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppTheme.getWarningColor(true);
      case 'found':
        return AppTheme.getSuccessColor(true);
      case 'closed':
        return AppTheme.lightTheme.colorScheme.outline;
      case 'investigating':
        return AppTheme.lightTheme.colorScheme.primary;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'found':
        return 'Found';
      case 'closed':
        return 'Closed';
      case 'investigating':
        return 'Investigating';
      default:
        return 'Unknown';
    }
  }
}