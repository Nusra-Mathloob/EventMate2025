import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticketmaster_event.dart';

class TicketmasterService {
  static const String apiKey = 'wynPnWpASrRAwdiH3IT2FWF3p7WADnxO';
  static const String baseUrl = 'https://app.ticketmaster.com/discovery/v2';

  Future<List<TicketmasterEvent>> searchEvents({
    String keyword = '',
    String city = '',
    int size = 20,
  }) async {
    try {
      final queryParams = {
        'apikey': apiKey,
        'size': size.toString(),
        if (keyword.isNotEmpty) 'keyword': keyword,
        if (city.isNotEmpty) 'city': city,
      };

      final uri = Uri.parse('$baseUrl/events.json').replace(queryParameters: queryParams);
      
      print('Requesting URL: $uri'); 
      final response = await http.get(uri);
      
      print('Response status: ${response.statusCode}'); 
      print('Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}'); // Debug log

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['_embedded']?['events'] != null) {
          final events = data['_embedded']['events'] as List;
          return events.map((e) => TicketmasterEvent.fromJson(e)).toList();
        }
        return [];
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API Key. Please check your Ticketmaster API key.');
      } else if (response.statusCode == 429) {
        throw Exception('Too many requests. Please wait a moment and try again.');
      } else {
        throw Exception('API Error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('Error in searchEvents: $e'); 
      rethrow;
    }
  }
}
