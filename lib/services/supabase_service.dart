import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/university.dart';
import '../models/program.dart';
import 'config_service.dart';

class SupabaseService {
  static SupabaseClient? _client;

  static SupabaseClient get client {
    _client ??= Supabase.instance.client;
    return _client!;
  }

  static Future<void> initialize() async {
    await ConfigService.load();
    await Supabase.initialize(
      url: ConfigService.supabaseUrl,
      anonKey: ConfigService.supabaseAnonKey,
    );
  }

  // Fetch all universities
  static Future<List<University>> getUniversities() async {
    try {
      final response = await client
          .from('universities')
          .select()
          .order('name');

      final universities = (response as List)
          .map((json) => University.fromJson(json as Map<String, dynamic>))
          .toList();
      return universities;
    } catch (e) {
      throw Exception('Failed to fetch universities: $e');
    }
  }

  // Fetch a single university by ID
  static Future<University> getUniversityById(String id) async {
    try {
      final response = await client
          .from('universities')
          .select()
          .eq('id', id)
          .single();

      return University.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch university: $e');
    }
  }

  // Fetch programs for a specific university
  static Future<List<Program>> getProgramsByUniversity(String universityId) async {
    try {
      final response = await client
          .from('programs')
          .select()
          .eq('university_id', universityId)
          .eq('status', 'approved')
          .order('name');

      final programs = (response as List)
          .map((json) => Program.fromJson(json as Map<String, dynamic>))
          .toList();
      return programs;
    } catch (e) {
      throw Exception('Failed to fetch programs: $e');
    }
  }

  // Search universities with filters
  static Future<List<University>> searchUniversities({
    String? city,
    String? programName,
    double? minFee,
    double? maxFee,
  }) async {
    try {
      var query = client.from('universities').select();

      if (city != null && city.isNotEmpty) {
        query = query.ilike('city', '%$city%');
      }

      // If program name filter is provided, we need to join with programs
      if (programName != null && programName.isNotEmpty) {
        final programIds = await client
            .from('programs')
            .select('university_id')
            .ilike('name', '%$programName%')
            .eq('status', 'approved');

        final ids = (programIds as List)
            .map((p) => p['university_id'] as String)
            .toList();

        if (ids.isNotEmpty) {
          query = query.inFilter('id', ids);
        } else {
          return []; // No matching programs found
        }
      }

      // Fee filtering requires joining with programs
      if (minFee != null || maxFee != null) {
        var programQuery = client.from('programs').select('university_id');

        if (minFee != null) {
          programQuery = programQuery.gte('tuition_fee', minFee);
        }
        if (maxFee != null) {
          programQuery = programQuery.lte('tuition_fee', maxFee);
        }

        programQuery = programQuery.eq('status', 'approved');

        final programIds = await programQuery;
        final ids = (programIds as List)
            .map((p) => p['university_id'] as String)
            .toSet()
            .toList();

        if (ids.isNotEmpty) {
          query = query.inFilter('id', ids);
        } else {
          return []; // No programs in fee range
        }
      }

      final response = await query.order('name');
      final universities = (response as List)
          .map((json) => University.fromJson(json as Map<String, dynamic>))
          .toList();
      return universities;
    } catch (e) {
      throw Exception('Failed to search universities: $e');
    }
  }
}
