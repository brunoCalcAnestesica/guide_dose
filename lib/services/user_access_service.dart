import 'package:supabase_flutter/supabase_flutter.dart';

class UserAccessService {
  static Future<void> registerAccess() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;

    try {
      await client.rpc('register_access', params: {'p_user_id': user.id});
    } catch (e) {
      // silently ignore
    }
  }
}
