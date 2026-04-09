import 'package:supabase_flutter/supabase_flutter.dart';

class SensorHistoryRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchHistoricalData(DateTime startTime) async {
    final response = await _supabase
        .from('pond_data')
        .select()
        .gte('created_at', startTime.toIso8601String())
        .order('created_at', ascending: true);
    
    return List<Map<String, dynamic>>.from(response as List);
  }
}
