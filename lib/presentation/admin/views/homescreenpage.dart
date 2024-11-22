import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admindashboard.dart';
import 'userdashboard.dart';
import 'usermanagement.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final userManager = UserManager();
  String? role;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRole();
  }

  Future<void> _fetchRole() async {
    try {
      final fetchedRole = await userManager.getUserRole();
      setState(() {
        role = fetchedRole;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user role: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (role == 'admin') {
      return AdminDashboard();
    } else if (role == 'user') {
      return UserDashboard();
    } else {
      return Scaffold(
        body: Center(child: Text('Unknown role: $role')),
      );
    }
  }
}
