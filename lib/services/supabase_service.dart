import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_models;

class SupabaseService {
  static final client = Supabase.instance.client;

  static Future<app_models.User?> getCurrentUserProfile() async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    final data = await client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return app_models.User.fromJson(data);
  }

  static Future<void> createUserProfile(app_models.User user) async {
    await client.from('profiles').insert(user.toJson());
  }

  static Future<void> updateUserProfile(app_models.User user) async {
    await client
        .from('profiles')
        .update(user.toJson())
        .eq('id', user.id);
  }

  static Future<Map<String, dynamic>?> getProfile(String userId) async {
    final data = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return data;
  }

  static Future<void> updateProfile({
    required String userId,
    required String name,
    required String gym,
    required String goal,
    required String frequency,
  }) async {
    await client.from('profiles').upsert({
      'id': userId,
      'name': name,
      'gym': gym,
      'goal': goal,
      'frequency': frequency,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getOtherProfiles(String currentUserId) async {
    final data = await client
        .from('profiles')
        .select()
        .neq('id', currentUserId);
    return List<Map<String, dynamic>>.from(data);
  }
}
