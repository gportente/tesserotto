import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/card_location.dart';

class PlacesService {
  static const _apiKey = String.fromEnvironment('GOOGLE_PLACES_KEY');
  static const _baseUrl =
      'https://maps.googleapis.com/maps/api/place/textsearch/json';

  /// Returns all branches found for [query], fetching up to 3 pages (≤60 results).
  static Future<List<CardLocation>> searchLocations(
      String query, String cardId) async {
    if (_apiKey.isEmpty) {
      throw Exception(
          'GOOGLE_PLACES_KEY non configurata. Compila con --dart-define=GOOGLE_PLACES_KEY=...');
    }

    final locations = <CardLocation>[];
    String? pageToken;
    int page = 0;

    do {
      final params = <String, String>{
        'query': query,
        'key': _apiKey,
        if (pageToken != null) 'pagetoken': pageToken,
      };

      final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Places API error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String;

      if (status == 'ZERO_RESULTS') break;
      if (status != 'OK' && status != 'NEXT_PAGE_TOKEN') {
        throw Exception('Places API: $status');
      }

      for (final r in data['results'] as List<dynamic>) {
        final loc = r['geometry']['location'];
        locations.add(CardLocation(
          cardId: cardId,
          address: r['formatted_address'] as String,
          lat: (loc['lat'] as num).toDouble(),
          lng: (loc['lng'] as num).toDouble(),
        ));
      }

      pageToken = data['next_page_token'] as String?;
      page++;

      // Google requires a short delay before using next_page_token
      if (pageToken != null && page < 3) {
        await Future.delayed(const Duration(seconds: 2));
      } else {
        pageToken = null; // cap at 3 pages
      }
    } while (pageToken != null);

    return locations;
  }
}
