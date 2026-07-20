import 'dart:convert';

import 'package:http/http.dart' as http;

/// Device-side country check (independent from Laravel).
/// Used so Myanmar users are blocked even if the API edge mis-detects IP.
class DeviceRegionService {
  DeviceRegionService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static const blockedCountries = {'MM'};

  /// Returns ISO country code like `MM`, or null if lookup failed.
  Future<String?> lookupCountryCode() async {
    return await _lookupIpApiCo() ?? await _lookupCountryIs();
  }

  Future<String?> _lookupIpApiCo() async {
    try {
      final res = await _client
          .get(
            Uri.parse('https://ipapi.co/json/'),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 6));

      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body);
      if (data is! Map) return null;

      final code = data['country_code']?.toString().trim().toUpperCase();
      if (code == null || code.length != 2) return null;
      return code;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _lookupCountryIs() async {
    try {
      final res = await _client
          .get(
            Uri.parse('https://api.country.is/'),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 6));

      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body);
      if (data is! Map) return null;

      final code = data['country']?.toString().trim().toUpperCase();
      if (code == null || code.length != 2) return null;
      return code;
    } catch (_) {
      return null;
    }
  }

  bool isBlockedCountry(String? code) {
    if (code == null || code.isEmpty) return false;
    return blockedCountries.contains(code.toUpperCase());
  }
}
