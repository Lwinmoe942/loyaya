import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// Stable per-install device id used to bind one account to one phone.
class DeviceIdService {
  static const _key = 'lotaya_device_id';

  Future<String> getOrCreate() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key)?.trim() ?? '';
    if (existing.length >= 8) return existing;

    final id = _generate();
    await prefs.setString(_key, id);
    return id;
  }

  String _generate() {
    final r = Random.secure();
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
