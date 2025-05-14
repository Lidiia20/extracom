// lib/app/modules/asset_data/providers/dropdown_options_provider.dart
import 'package:get/get.dart';
import '../../../utils/supabase_client.dart' as app_supabase;

class DropdownOptionsProvider extends GetxController {
  final _client = app_supabase.SupabaseClient.client;
  final _table = 'dropdown_options'; 
  
  Future<Map<String, dynamic>> getOptionsByType(String type) async {
    try {
      print('Fetching $type options from Supabase');
      final response = await _client
          .from(_table)
          .select()
          .eq('type', type)
          .order('value', ascending: true);
      
      if (response != null) {
        return {
          'status': 'success',
          'options': response,
        };
      } else {
        return {
          'status': 'error',
          'message': 'No options found for type: $type',
        };
      }
    } catch (e) {
      print('Error getting options: $e');
      return {
        'status': 'error',
        'message': 'Error getting options: $e',
      };
    }
  }
  
  Future<Map<String, dynamic>> getAllOptions() async {
    try {
      print('Fetching all dropdown options from Supabase');
      final response = await _client
          .from(_table)
          .select()
          .order('type', ascending: true);
      
      if (response != null) {
        return {
          'status': 'success',
          'options': response,
        };
      } else {
        return {
          'status': 'error',
          'message': 'No options found',
        };
      }
    } catch (e) {
      print('Error getting options: $e');
      return {
        'status': 'error',
        'message': 'Error getting options: $e',
      };
    }
  }
}