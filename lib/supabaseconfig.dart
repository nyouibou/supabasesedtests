import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://xthqnqsgreccuzlmblzg.supabase.co';
  static const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh0aHFucXNncmVjY3V6bG1ibHpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE3MzQyNDksImV4cCI6MjA0NzMxMDI0OX0.aElpPfvQNJ_T896gaP6vbokrgQdIIXXr_bDDqxa9uKA';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
  }
}
