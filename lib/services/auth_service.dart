import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class AuthService {
  static final SupabaseService _supabaseService = SupabaseService();

  /// Signs up a new user with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      final client = await _supabaseService.client;
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone_number': phoneNumber,
          'role': 'user',
        },
      );
      return response;
    } catch (error) {
      throw Exception('Sign-up failed: $error');
    }
  }

  /// Signs in a user with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final client = await _supabaseService.client;
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception('Sign-in failed: $error');
    }
  }

  /// Signs out the current user
  static Future<void> signOut() async {
    try {
      final client = await _supabaseService.client;
      await client.auth.signOut();
    } catch (error) {
      throw Exception('Sign-out failed: $error');
    }
  }

  /// Gets the current user
  static User? getCurrentUser() {
    return _supabaseService.currentUser;
  }

  /// Gets the current user's profile
  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final user = getCurrentUser();
      if (user == null) return null;

      final client = await _supabaseService.client;
      final response = await client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to get user profile: $error');
    }
  }

  /// Updates the current user's profile
  static Future<Map<String, dynamic>> updateUserProfile({
    String? fullName,
    String? phoneNumber,
    String? location,
    String? avatarUrl,
  }) async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      final client = await _supabaseService.client;
      final updates = <String, dynamic>{};

      if (fullName != null) updates['full_name'] = fullName;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (location != null) updates['location'] = location;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      if (updates.isNotEmpty) {
        updates['updated_at'] = DateTime.now().toIso8601String();
      }

      final response = await client
          .from('user_profiles')
          .update(updates)
          .eq('id', user.id)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to update profile: $error');
    }
  }

  /// Checks if user is authenticated
  static bool isAuthenticated() {
    return getCurrentUser() != null;
  }

  /// Gets auth state stream
  static Stream<AuthState> get authStateStream {
    return _supabaseService.authStateStream;
  }

  /// Reset password
  static Future<void> resetPassword(String email) async {
    try {
      final client = await _supabaseService.client;
      await client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Password reset failed: $error');
    }
  }
}
