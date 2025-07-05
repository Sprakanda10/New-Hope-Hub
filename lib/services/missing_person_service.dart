import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import './auth_service.dart';
import './supabase_service.dart';

class MissingPersonService {
  static final SupabaseService _supabaseService = SupabaseService();

  /// Creates a new missing person report
  static Future<Map<String, dynamic>> createReport({
    required String personName,
    required int personAge,
    required String lastSeenLocation,
    required String description,
    String? contactPhone,
    String? imagePath,
  }) async {
    try {
      final user = AuthService.getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      final client = await _supabaseService.client;

      String? imageUrl;

      // Upload image if provided
      if (imagePath != null) {
        imageUrl = await uploadReportImage(imagePath);
      }

      final reportData = {
        'reporter_id': user.id,
        'person_name': personName,
        'person_age': personAge,
        'last_seen_location': lastSeenLocation,
        'description': description,
        'contact_phone': contactPhone ?? user.phone,
        'image_url': imageUrl,
        'status': 'active',
        'priority': _determinePriority(personAge),
      };

      final response = await client
          .from('missing_person_reports')
          .insert(reportData)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to create report: $error');
    }
  }

  /// Gets all active missing person reports
  static Future<List<Map<String, dynamic>>> getActiveReports({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final client = await _supabaseService.client;
      final response = await client
          .from('missing_person_reports')
          .select('''
            *,
            user_profiles!reporter_id (
              full_name,
              avatar_url
            )
          ''')
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get reports: $error');
    }
  }

  /// Gets reports by specific user
  static Future<List<Map<String, dynamic>>> getUserReports({
    String? userId,
    int limit = 50,
  }) async {
    try {
      final user = AuthService.getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      final targetUserId = userId ?? user.id;
      final client = await _supabaseService.client;

      final response = await client
          .from('missing_person_reports')
          .select('''
            *,
            user_profiles!reporter_id (
              full_name,
              avatar_url
            )
          ''')
          .eq('reporter_id', targetUserId)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get user reports: $error');
    }
  }

  /// Updates a missing person report
  static Future<Map<String, dynamic>> updateReport({
    required String reportId,
    String? status,
    String? description,
    String? priority,
  }) async {
    try {
      final user = AuthService.getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      final client = await _supabaseService.client;
      final updates = <String, dynamic>{};

      if (status != null) updates['status'] = status;
      if (description != null) updates['description'] = description;
      if (priority != null) updates['priority'] = priority;

      if (updates.isNotEmpty) {
        updates['updated_at'] = DateTime.now().toIso8601String();
      }

      final response = await client
          .from('missing_person_reports')
          .update(updates)
          .eq('id', reportId)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to update report: $error');
    }
  }

  /// Deletes a missing person report
  static Future<void> deleteReport(String reportId) async {
    try {
      final user = AuthService.getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      final client = await _supabaseService.client;
      await client.from('missing_person_reports').delete().eq('id', reportId);
    } catch (error) {
      throw Exception('Failed to delete report: $error');
    }
  }

  /// Uploads report image to Supabase storage
  static Future<String> uploadReportImage(String imagePath) async {
    try {
      final user = AuthService.getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      final client = await _supabaseService.client;
      final file = File(imagePath);
      final fileExt = imagePath.split('.').last.toLowerCase();
      final fileName =
          'report_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '${user.id}/$fileName';

      await client.storage.from('missing-person-images').upload(filePath, file);

      final publicUrl =
          client.storage.from('missing-person-images').getPublicUrl(filePath);

      return publicUrl;
    } catch (error) {
      throw Exception('Failed to upload image: $error');
    }
  }

  /// Gets report comments
  static Future<List<Map<String, dynamic>>> getReportComments(
      String reportId) async {
    try {
      final client = await _supabaseService.client;
      final response = await client.from('report_comments').select('''
            *,
            user_profiles!commenter_id (
              full_name,
              avatar_url,
              role
            )
          ''').eq('report_id', reportId).order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get comments: $error');
    }
  }

  /// Adds a comment to a report
  static Future<Map<String, dynamic>> addComment({
    required String reportId,
    required String commentText,
    bool isOfficial = false,
  }) async {
    try {
      final user = AuthService.getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      final client = await _supabaseService.client;
      final response = await client.from('report_comments').insert({
        'report_id': reportId,
        'commenter_id': user.id,
        'comment_text': commentText,
        'is_official': isOfficial,
      }).select('''
            *,
            user_profiles!commenter_id (
              full_name,
              avatar_url,
              role
            )
          ''').single();

      return response;
    } catch (error) {
      throw Exception('Failed to add comment: $error');
    }
  }

  /// Subscribe to real-time report updates
  static RealtimeChannel subscribeToReports({
    required Function(Map<String, dynamic>) onInsert,
    required Function(Map<String, dynamic>) onUpdate,
    required Function(Map<String, dynamic>) onDelete,
  }) {
    final client = _supabaseService.syncClient;

    return client
        .channel('missing_person_reports')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'missing_person_reports',
          callback: (payload) => onInsert(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'missing_person_reports',
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'missing_person_reports',
          callback: (payload) => onDelete(payload.oldRecord),
        )
        .subscribe();
  }

  /// Determines priority based on age (children get higher priority)
  static String _determinePriority(int age) {
    if (age <= 12) return 'high';
    if (age <= 17) return 'medium';
    return 'medium';
  }

  /// Search reports by text
  static Future<List<Map<String, dynamic>>> searchReports(
      String searchQuery) async {
    try {
      final client = await _supabaseService.client;
      final response = await client
          .from('missing_person_reports')
          .select('''
            *,
            user_profiles!reporter_id (
              full_name,
              avatar_url
            )
          ''')
          .eq('status', 'active')
          .or('person_name.ilike.%$searchQuery%,last_seen_location.ilike.%$searchQuery%,description.ilike.%$searchQuery%')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to search reports: $error');
    }
  }
}
