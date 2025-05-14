// lib/app/utils/supabase_client.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClient {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://rbxqxuuefpvwkirwyxez.supabase.co', // Ganti dengan URL Supabase Anda
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJieHF4dXVlZnB2d2tpcnd5eGV6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYwODAxMjUsImV4cCI6MjA2MTY1NjEyNX0.4nU2V_uMLBdJXrjFdasT9Jx064IT7iEjhusHbWkm4pI', // Ganti dengan Anon Key Supabase Anda
    );
  }

  static get client => Supabase.instance.client;
}