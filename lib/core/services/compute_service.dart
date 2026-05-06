import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Servicio de concurrencia usando compute() / Isolates para tareas intensivas
class ComputeService {
  /// Busca texto en paralelo usando compute (Isolate)
  static Future<List<Map<String, dynamic>>> searchInParallel(
    List<Map<String, dynamic>> data,
    String query,
  ) async {
    return await compute(_searchItems, {'data': data, 'query': query.toLowerCase()});
  }

  static List<Map<String, dynamic>> _searchItems(Map<String, dynamic> args) {
    final data = args['data'] as List<Map<String, dynamic>>;
    final query = args['query'] as String;

    return data.where((item) {
      final title = item['title']?.toString().toLowerCase() ?? '';
      final desc = item['description']?.toString().toLowerCase() ?? '';
      return title.contains(query) || desc.contains(query);
    }).toList();
  }

  /// Calcula estadísticas de ratings en paralelo (promedio, suma, etc.)
  static Future<Map<String, double>> calculateRatingStats(List<double> scores) async {
    return await compute(_calculateStats, scores);
  }

  static Map<String, double> _calculateStats(List<double> values) {
    if (values.isEmpty) return {'avg': 0, 'sum': 0, 'max': 0, 'min': 0, 'count': 0};

    double sum = 0;
    double max = values.first;
    double min = values.first;

    for (final v in values) {
      sum += v;
      if (v > max) max = v;
      if (v < min) min = v;
    }

    return {
      'avg': sum / values.length,
      'sum': sum,
      'max': max,
      'min': min,
      'count': values.length.toDouble(),
    };
  }

  /// Parsea respuestas JSON grandes de la API de geocoding en un Isolate
  static Future<List<GeocodingResult>> parseGeocodingResults(String jsonBody) async {
    return await compute(_parseGeocoding, jsonBody);
  }

  static List<GeocodingResult> _parseGeocoding(String jsonBody) {
    final data = jsonDecode(jsonBody) as Map<String, dynamic>;
    final features = data['features'] as List<dynamic>? ?? [];
    return features.map((f) => GeocodingResult.fromGeoJson(f as Map<String, dynamic>)).toList();
  }
}

/// Servicio de OpenFreeMap - API gratuita de mapas y geocoding
/// https://openfreemap.org - No requiere API key
class OpenFreeMapService {
  static const String _geocodeUrl = 'https://nominatim.openstreetmap.org';
  static const String _tileUrl = 'https://tiles.openfreemap.org/styles/liberty/{z}/{x}/{y}.png';

  /// Obtiene la URL del tile de mapa para una posición y zoom dados
  static String getTileUrl(double lat, double lng, {int zoom = 14}) {
    final x = _lngToTileX(lng, zoom);
    final y = _latToTileY(lat, zoom);
    return _tileUrl
        .replaceAll('{z}', zoom.toString())
        .replaceAll('{x}', x.toString())
        .replaceAll('{y}', y.toString());
  }

  /// Geocodificación directa: texto → coordenadas
  static Future<List<GeocodingResult>> searchAddress(String query) async {
    final response = await http.get(
      Uri.parse('$_geocodeUrl/search?q=${Uri.encodeComponent(query)}&format=geojson&limit=5'),
      headers: {'User-Agent': 'RentMyStuff/1.0'},
    );

    if (response.statusCode == 200) {
      return ComputeService.parseGeocodingResults(response.body);
    } else {
      throw Exception('Geocoding failed: ${response.statusCode}');
    }
  }

  /// Geocodificación inversa: coordenadas → dirección
  static Future<GeocodingResult> reverseGeocode(double lat, double lng) async {
    final response = await http.get(
      Uri.parse('$_geocodeUrl/reverse?lat=$lat&lon=$lng&format=geojson'),
      headers: {'User-Agent': 'RentMyStuff/1.0'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>? ?? [];
      if (features.isNotEmpty) {
        return GeocodingResult.fromGeoJson(features.first as Map<String, dynamic>);
      }
      throw Exception('No results found');
    } else {
      throw Exception('Reverse geocoding failed: ${response.statusCode}');
    }
  }

  /// Genera una URL estática de mapa (imagen) para mostrar en un widget
  static String getStaticMapUrl(double lat, double lng, {int zoom = 15, int width = 600, int height = 300}) {
    return 'https://staticmap.openfreemap.org/staticmap?center=$lat,$lng&zoom=$zoom&size=${width}x$height';
  }

  static int _lngToTileX(double lng, int zoom) {
    return ((lng + 180.0) / 360.0 * (1 << zoom)).floor();
  }

  static int _latToTileY(double lat, int zoom) {
    final latRad = lat * math.pi / 180.0;
    final n = 1 << zoom;
    return ((1.0 - math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) / 2.0 * n).floor();
  }
}

/// Resultado de geocodificación
class GeocodingResult {
  final double lat;
  final double lng;
  final String displayName;
  final String type;

  GeocodingResult({
    required this.lat,
    required this.lng,
    required this.displayName,
    this.type = '',
  });

  factory GeocodingResult.fromGeoJson(Map<String, dynamic> feature) {
    final geometry = feature['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;
    final properties = feature['properties'] as Map<String, dynamic>? ?? {};

    return GeocodingResult(
      lng: (coordinates[0] as num).toDouble(),
      lat: (coordinates[1] as num).toDouble(),
      displayName: properties['display_name'] as String? ?? properties['name'] as String? ?? '',
      type: properties['type'] as String? ?? '',
    );
  }
}
