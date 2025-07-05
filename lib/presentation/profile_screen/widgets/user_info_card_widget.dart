import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class UserInfoCardWidget extends StatelessWidget {
  final Map<String, dynamic>? userProfile;
  final VoidCallback onEditProfile;

  const UserInfoCardWidget({
    super.key,
    required this.userProfile,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final profile = userProfile;

    if (profile == null) {
      return _buildErrorCard(context);
    }

    final fullName = profile['full_name'] as String? ?? 'Unknown User';
    final email = profile['email'] as String? ?? '';
    final phoneNumber = profile['phone_number'] as String? ?? '';
    final location = profile['location'] as String? ?? '';
    final role = profile['role'] as String? ?? 'user';
    final isVerified = profile['is_verified'] as bool? ?? false;
    final avatarUrl = profile['avatar_url'] as String?;
    final memberSince = profile['created_at'] as String?;

    String formattedMemberSince = '';
    if (memberSince != null) {
      try {
        final date = DateTime.parse(memberSince);
        formattedMemberSince = 'Member since ${date.year}';
      } catch (e) {
        formattedMemberSince = 'Member since 2024';
      }
    }

    return Card(
        elevation: AppTheme.lightTheme.cardTheme.elevation,
        shape: AppTheme.lightTheme.cardTheme.shape,
        child: Padding(
            padding: EdgeInsets.all(4.w),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Header with avatar and basic info
              Row(children: [
                // Avatar
                Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.lightTheme.colorScheme.primaryContainer,
                        border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            width: 2)),
                    child: avatarUrl?.isNotEmpty == true
                        ? ClipOval(
                            child: CustomImageWidget(
                                imageUrl: avatarUrl,
                                width: 20.w,
                                height: 20.w,
                                fit: BoxFit.cover))
                        : Icon(Icons.person,
                            size: 10.w,
                            color: AppTheme.lightTheme.colorScheme.primary)),
                SizedBox(width: 4.w),

                // Name and verification status
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Row(children: [
                        Expanded(
                            child: Text(fullName,
                                style: AppTheme.lightTheme.textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis)),
                        if (isVerified) ...[
                          SizedBox(width: 2.w),
                          CustomIconWidget(
                              iconName: 'verified',
                              color: AppTheme.getSuccessColor(true),
                              size: 5.w),
                        ],
                      ]),
                      SizedBox(height: 0.5.h),

                      // Role badge
                      Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                              color: _getRoleColor(role).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: _getRoleColor(role), width: 1)),
                          child: Text(_getRoleDisplayName(role),
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                      color: _getRoleColor(role),
                                      fontWeight: FontWeight.w500))),

                      SizedBox(height: 1.h),

                      // Member since
                      if (formattedMemberSince.isNotEmpty)
                        Text(formattedMemberSince,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.6))),
                    ])),

                // Edit button
                IconButton(
                    onPressed: onEditProfile,
                    icon: CustomIconWidget(
                        iconName: 'edit',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 6.w)),
              ]),

              SizedBox(height: 3.h),

              // Contact information
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Contact Information',
                    style: AppTheme.lightTheme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                SizedBox(height: 2.h),

                // Email
                _buildInfoRow(context,
                    icon: 'email', label: 'Email', value: email),

                SizedBox(height: 1.5.h),

                // Phone
                if (phoneNumber.isNotEmpty)
                  _buildInfoRow(context,
                      icon: 'phone', label: 'Phone', value: phoneNumber),

                if (phoneNumber.isNotEmpty) SizedBox(height: 1.5.h),

                // Location
                if (location.isNotEmpty)
                  _buildInfoRow(context,
                      icon: 'location_on', label: 'Location', value: location),
              ]),
            ])));
  }

  Widget _buildErrorCard(BuildContext context) {
    return Card(
        elevation: AppTheme.lightTheme.cardTheme.elevation,
        shape: AppTheme.lightTheme.cardTheme.shape,
        child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(children: [
              CustomIconWidget(
                  iconName: 'error',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 12.w),
              SizedBox(height: 2.h),
              Text('Failed to load profile',
                  style: AppTheme.lightTheme.textTheme.titleMedium
                      ?.copyWith(color: AppTheme.lightTheme.colorScheme.error)),
              SizedBox(height: 1.h),
              Text('Please try refreshing the page',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6))),
            ])));
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
  }) {
    return Row(children: [
      CustomIconWidget(
          iconName: icon,
          color:
              AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
          size: 5.w),
      SizedBox(width: 3.w),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6))),
        Text(value,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
      ])),
    ]);
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppTheme.lightTheme.colorScheme.error;
      case 'moderator':
        return AppTheme.getWarningColor(true);
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'moderator':
        return 'Moderator';
      default:
        return 'Community Member';
    }
  }
}