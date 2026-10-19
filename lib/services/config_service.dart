import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigService {
  static String? _supabaseUrl;
  static String? _supabaseAnonKey;

  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
      _supabaseUrl = dotenv.env['SUPABASE_URL'];
      _supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
    } catch (e) {
      throw Exception('.env file not found or invalid. Please create it using .env.example as a template.');
    }
  }

  static String get supabaseUrl {
    if (_supabaseUrl == null || _supabaseUrl!.isEmpty) {
      throw Exception('SUPABASE_URL not found in .env file');
    }
    return _supabaseUrl!;
  }

  static String get supabaseAnonKey {
    if (_supabaseAnonKey == null || _supabaseAnonKey!.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY not found in .env file');
    }
    return _supabaseAnonKey!;
  }
}
