import 'package:supabase_flutter/supabase_flutter.dart';

class UserManager {
  final supabase = Supabase.instance.client;

  Future<String> getUserRole() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('No user is logged in.');
    }

    final response = await supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();

    if (response != null && response['role'] != null) {
      return response['role'];
    } else {
      throw Exception('Failed to fetch user role.');
    }
  }
}
