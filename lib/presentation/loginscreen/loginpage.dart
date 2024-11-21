import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signIn() async {
  final email = _emailController.text;
  final password = _passwordController.text;

  try {
    // Perform the sign-in request
    final AuthResponse response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    // Check if the user is successfully logged in
    if (response.session != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Handle unexpected cases (this might not occur often)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: No session found')),
      );
    }
  } on AuthException catch (e) {
    // Handle authentication-specific errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login failed: ${e.message}')),
    );
  } catch (e) {
    // Handle other unexpected errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unexpected error: ${e.toString()}')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signIn,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
