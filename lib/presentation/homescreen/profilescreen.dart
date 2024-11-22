import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;

  Future<void> fetchProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('No user logged in');
      }

      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      if (response != null) {
        _nameController.text = response['full_name'] ?? '';
        _emailController.text = response['email'] ?? '';
        _phoneController.text = response['phone_number'] ?? '';
        _addressController.text = response['address'] ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('No user logged in');
      }

      await supabase.from('profiles').upsert({
  'id': user.id, // Required for upserting
  'full_name': _nameController.text,
  'phone_number': _phoneController.text,
  'address': _addressController.text,
});


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Full Name'),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    enabled: false, // Email is not editable
                  ),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                  ),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(labelText: 'Address'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: updateProfile,
                    child: Text('Save Changes'),
                  ),
                ],
              ),
            ),
    );
  }
}
