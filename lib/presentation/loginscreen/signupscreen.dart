import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabasesedtest/supabaseconfig.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
 final String supabaseUrl = 'https://xthqnqsgreccuzlmblzg.supabase.co';
  final String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh0aHFucXNncmVjY3V6bG1ibHpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE3MzQyNDksImV4cCI6MjA0NzMxMDI0OX0.aElpPfvQNJ_T896gaP6vbokrgQdIIXXr_bDDqxa9uKA';

  
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpSent = false;


  Future<void> _sendOtp() async {
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    try {
      // Send OTP using Supabase's built-in method
      await Supabase.instance.client.auth.signInWithOtp(
        phone: phoneNumber,
      );

      setState(() {
        _isOtpSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent to $phoneNumber')),
      );
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: ${e.toString()}')),
      );
    }
  }

  // Future<void> _verifyOtpAndSignup() async {
  //   final phoneNumber = _phoneController.text.trim();
  //   final otp = _otpController.text.trim();

  //   if (otp.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Please enter the OTP')),
  //     );
  //     return;
  //   }

  //   try {
  //     // Verify OTP via Supabase's REST API
  //     final url = '${SupabaseConfig.supabaseUrl}/auth/v1/verify';
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer ${SupabaseConfig.supabaseKey}',
  //       },
  //       body: jsonEncode({
  //         'phone': phoneNumber,
  //         'token': otp,
  //         'type': 'sms', // Type of OTP (sms in this case)
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);

  //       // Check if the user is authenticated
  //       final user = Supabase.instance.client.auth.currentUser;
  //       if (user != null) {
  //         Navigator.pushReplacementNamed(context, '/home');
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Signup failed: Invalid user session')),
  //         );
  //       }
  //     } else {
  //       final error = jsonDecode(response.body);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error: ${error['error_description'] ?? 'Failed to verify OTP'}')),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Unexpected error: ${e.toString()}')),
  //     );
  //   }
  // }


Future<void> _verifyOtpAndSignup() async {
  final phoneNumber = _phoneController.text.trim();
  final otp = _otpController.text.trim();

  if (otp.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please enter the OTP')),
    );
    return;
  }

  try {
    // Verify OTP via Supabase's REST API
    final url = '$supabaseUrl/auth/v1/verify';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $supabaseKey',
      },
      body: jsonEncode({
        'phone': phoneNumber,
        'token': otp,
        'type': 'sms', // Type of OTP (sms in this case)
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Check if a session exists
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Explicitly fetch the session
        await Supabase.instance.client.auth.refreshSession();

        final refreshedUser = Supabase.instance.client.auth.currentUser;
        if (refreshedUser != null) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Signup failed: No valid session')),
          );
        }
      }
    } else {
      final error = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error['error_description'] ?? 'Failed to verify OTP'}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unexpected error: ${e.toString()}')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            if (_isOtpSent) ...[
              TextField(
                controller: _otpController,
                decoration: InputDecoration(labelText: 'OTP'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyOtpAndSignup,
                child: Text('Verify OTP and Signup'),
              ),
            ] else ...[
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendOtp,
                child: Text('Send OTP'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}