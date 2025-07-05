import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MissingPersonCardWidget extends StatelessWidget {
  final String name;
  final int age;
  final String lastSeenLocation;
  final String description;
  final String imageUrl;
  final String timeAgo;
  final String reportedBy;
  final String contactPhone;
  final String caseId;
  final VoidCallback onTap;

  const MissingPersonCardWidget({
    super.key,
    required this.name,
    required this.age,
    required this.lastSeenLocation,
    required this.description,
    required this.imageUrl,
    required this.timeAgo,
    required this.reportedBy,
    required this.contactPhone,
    required this.caseId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTheme.lightTheme.cardTheme.elevation,
      shape: AppTheme.lightTheme.cardTheme.shape,
      color: AppTheme.lightTheme.cardTheme.color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(2.w),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 2.h),
              _buildDescription(),
              SizedBox(height: 2.h),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Hero(
          tag: 'person_image_$caseId',
          child: Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2.w),
              child: CustomImageWidget(
                imageUrl: imageUrl,
                width: 15.w,
                height: 15.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  Text(
                    'Age: $age',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Container(
                    width: 1,
                    height: 1.5.h,
                    color: AppTheme.lightTheme.colorScheme.outline,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      timeAgo,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(1.w),
          ),
          child: Text(
            'MISSING',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'location_on',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 16,
            ),
            SizedBox(width: 1.w),
            Expanded(
              child: Text(
                'Last seen: $lastSeenLocation',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Text(
          description,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reported by: $reportedBy',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Case ID: $caseId',
                style: AppTheme.getMonospaceStyle(
                  isLight: true,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ).copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                // Share functionality
              },
              icon: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 20,
              ),
              padding: EdgeInsets.all(1.w),
              constraints: BoxConstraints(
                minWidth: 8.w,
                minHeight: 8.w,
              ),
            ),
            SizedBox(width: 1.w),
            ElevatedButton.icon(
              onPressed: () {
                // Contact functionality
              },
              icon: CustomIconWidget(
                iconName: 'phone',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 16,
              ),
              label: Text(
                'Contact',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: AppTheme.lightTheme.elevatedButtonTheme.style?.copyWith(
                padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                ),
                minimumSize: WidgetStateProperty.all(Size(20.w, 5.h)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
