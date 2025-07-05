import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SettingsListWidget extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onNotificationSettings;
  final VoidCallback onPrivacySettings;
  final VoidCallback onAbout;

  const SettingsListWidget({
    super.key,
    required this.onEditProfile,
    required this.onNotificationSettings,
    required this.onPrivacySettings,
    required this.onAbout,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> settingsItems = [
      {
        "title": "Edit Profile",
        "subtitle": "Update your personal information",
        "icon": "edit",
        "onTap": onEditProfile,
      },
      {
        "title": "Notification Preferences",
        "subtitle": "Manage alert settings and notifications",
        "icon": "notifications",
        "onTap": onNotificationSettings,
      },
      {
        "title": "Privacy Settings",
        "subtitle": "Control your data sharing preferences",
        "icon": "privacy_tip",
        "onTap": onPrivacySettings,
      },
      {
        "title": "About",
        "subtitle": "App information and version details",
        "icon": "info",
        "onTap": onAbout,
      },
    ];

    return Card(
      elevation: AppTheme.lightTheme.cardTheme.elevation,
      shape: AppTheme.lightTheme.cardTheme.shape,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Text(
              'Settings',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: settingsItems.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: AppTheme.lightTheme.dividerColor,
              indent: 4.w,
              endIndent: 4.w,
            ),
            itemBuilder: (context, index) {
              final item = settingsItems[index];
              return _buildSettingsItem(
                title: item["title"] as String,
                subtitle: item["subtitle"] as String,
                iconName: item["icon"] as String,
                onTap: item["onTap"] as VoidCallback,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required String subtitle,
    required String iconName,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            // Icon
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: iconName,
                  size: 5.w,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),

            SizedBox(width: 4.w),

            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Chevron
            CustomIconWidget(
              iconName: 'chevron_right',
              size: 5.w,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
