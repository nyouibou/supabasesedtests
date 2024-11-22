import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserDashboard extends StatelessWidget {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> _fetchProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('No user logged in.');

    final response = await supabase
        .from('profiles')
        .select('email, full_name, role')
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) throw Exception('Failed to fetch profile.');

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Dashboard')),
      body: FutureBuilder(
        future: _fetchProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final profile = snapshot.data as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${profile['email']}'),
                Text('Full Name: ${profile['full_name']}'),
                Text('Role: ${profile['role']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
