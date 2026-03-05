import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../storage_manager.dart';

/// Serviço que obtém feriados públicos via API Nager.Date (gratuita, sem API key).
/// Suporta 90+ países; o país é informado por código ISO 3166-1 alpha-2 (ex: BR, US).
/// Fallback estático BR (2024-2027) quando a API falha.
/// Dados são salvos em cache no dispositivo e só atualizados quando forem diferentes.
class HolidaysService {
  HolidaysService._();
  static final HolidaysService _instance = HolidaysService._();
  factory HolidaysService() => _instance;

  static const String _baseUrl = 'https://date.nager.at/api/v3';
  static const String _storagePrefix = 'feriados_cache_';

  final Map<String, Map<DateTime, String>> _cache = {};

  /// Feriados nacionais BR para fallback quando a API falha (ano -> data -> nome).
  static Map<int, Map<DateTime, String>> _staticHolidaysBR() {
    final Map<int, Map<DateTime, String>> byYear = {};
    void add(int y, int m, int d, String name) {
      byYear.putIfAbsent(y, () => {});
      byYear[y]![DateTime(y, m, d)] = name;
    }
    for (final year in [2024, 2025, 2026, 2027]) {
      add(year, 1, 1, 'Confraternização Universal');
      add(year, 4, 21, 'Dia de Tiradentes');
      add(year, 5, 1, 'Dia do Trabalhador');
      add(year, 9, 7, 'Dia da Independência');
      add(year, 10, 12, 'Nossa Senhora Aparecida');
      add(year, 11, 2, 'Dia de Finados');
      add(year, 11, 15, 'Proclamação da República');
      add(year, 11, 20, 'Dia da Consciência Negra');
      add(year, 12, 25, 'Natal');
    }
    add(2024, 2, 12, 'Carnaval');
    add(2024, 2, 13, 'Carnaval');
    add(2024, 3, 29, 'Sexta-feira Santa');
    add(2024, 5, 30, 'Corpus Christi');
    add(2025, 2, 17, 'Carnaval');
    add(2025, 2, 18, 'Carnaval');
    add(2025, 4, 18, 'Sexta-feira Santa');
    add(2025, 6, 19, 'Corpus Christi');
    add(2026, 2, 16, 'Carnaval');
    add(2026, 2, 17, 'Carnaval');
    add(2026, 4, 3, 'Sexta-feira Santa');
    add(2026, 6, 4, 'Corpus Christi');
    add(2027, 2, 8, 'Carnaval');
    add(2027, 2, 9, 'Carnaval');
    add(2027, 3, 26, 'Sexta-feira Santa');
    add(2027, 5, 27, 'Corpus Christi');
    return byYear;
  }

  static final Map<int, Map<DateTime, String>> _staticBR = _staticHolidaysBR();

  /// Retorna mapa data -> nome local do feriado para o ano e país informados.
  /// Datas são normalizadas (sem hora) para comparação estável.
  /// Usa cache em memória e em disco; só atualiza quando os dados da API forem diferentes.
  Future<Map<DateTime, String>> getHolidaysForYear(
    int year,
    String countryCode,
  ) async {
    final key = _cacheKey(year, countryCode);

    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    await StorageManager.instance.initialize();
    final fromDisk = _loadFromDisk(key);
    if (fromDisk != null && fromDisk.isNotEmpty) {
      _cache[key] = fromDisk;
      _refreshInBackgroundIfDifferent(year, countryCode, key, fromDisk);
      return fromDisk;
    }

    return _fetchAndCache(year, countryCode, key);
  }

  String _cacheKey(int year, String countryCode) =>
      '$year-${countryCode.toUpperCase()}';

  static String _dateToKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime? _keyToDate(String s) {
    final parts = s.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null || m < 1 || m > 12 || d < 1 || d > 31) return null;
    return DateTime(y, m, d);
  }

  bool _mapsEqual(Map<DateTime, String> a, Map<DateTime, String> b) {
    if (a.length != b.length) return false;
    for (final e in a.entries) {
      if (b[e.key] != e.value) return false;
    }
    return true;
  }

  String _serialize(Map<DateTime, String> map) {
    final list = map.entries
        .map((e) => {'d': _dateToKey(e.key), 'n': e.value})
        .toList();
    return jsonEncode(list);
  }

  Map<DateTime, String>? _deserialize(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>?;
      if (list == null) return null;
      final Map<DateTime, String> result = {};
      for (final item in list) {
        if (item is! Map<String, dynamic>) continue;
        final dStr = item['d'] as String?;
        final name = item['n'] as String? ?? '';
        if (dStr == null) continue;
        final dt = _keyToDate(dStr);
        if (dt != null) result[dt] = name;
      }
      return result;
    } catch (_) {
      return null;
    }
  }

  Map<DateTime, String>? _loadFromDisk(String key) {
    final raw = StorageManager.instance.getString('$_storagePrefix$key', defaultValue: '');
    return _deserialize(raw.isEmpty ? null : raw);
  }

  Future<void> _saveToDisk(String key, Map<DateTime, String> map) async {
    try {
      await StorageManager.instance.setString('$_storagePrefix$key', _serialize(map));
    } catch (_) {}
  }

  void _refreshInBackgroundIfDifferent(
    int year,
    String countryCode,
    String key,
    Map<DateTime, String> current,
  ) {
    Future(() async {
      try {
        final fromApi = await _fetchFromApi(year, countryCode);
        if (fromApi == null) return;
        if (!_mapsEqual(fromApi, current)) {
          _cache[key] = fromApi;
          await _saveToDisk(key, fromApi);
        }
      } catch (_) {}
    });
  }

  /// Busca na API sem usar fallback (retorna null em erro).
  Future<Map<DateTime, String>?> _fetchFromApi(int year, String countryCode) async {
    try {
      final uri = Uri.parse('$_baseUrl/PublicHolidays/$year/${countryCode.toUpperCase()}');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('timeout'),
      );
      if (response.statusCode != 200) return null;
      final list = jsonDecode(response.body) as List<dynamic>?;
      if (list == null || list.isEmpty) return null;
      final Map<DateTime, String> result = {};
      for (final item in list) {
        if (item is! Map<String, dynamic>) continue;
        final dateStr = item['date'] as String?;
        final localName = item['localName'] as String? ?? '';
        if (dateStr == null || dateStr.length != 10) continue;
        try {
          final parts = dateStr.split('-');
          if (parts.length != 3) continue;
          final y = int.tryParse(parts[0]);
          final m = int.tryParse(parts[1]);
          final d = int.tryParse(parts[2]);
          if (y == null || m == null || d == null || m < 1 || m > 12 || d < 1 || d > 31) continue;
          final normalized = DateTime(y, m, d);
          result[normalized] = localName;
        } catch (_) {}
      }
      return result;
    } catch (_) {
      return null;
    }
  }

  Future<Map<DateTime, String>> _fetchAndCache(
    int year,
    String countryCode,
    String key,
  ) async {
    try {
      final fromApi = await _fetchFromApi(year, countryCode);
      if (fromApi != null && fromApi.isNotEmpty) {
        final existing = _loadFromDisk(key);
        if (existing == null || !_mapsEqual(fromApi, existing)) {
          await _saveToDisk(key, fromApi);
        }
        return _cacheAndReturn(key, fromApi);
      }

      if (fromApi != null && fromApi.isEmpty) {
        return _cacheAndReturn(key, fromApi);
      }

      debugPrint('Feriados: API falhou, usando fallback BR se aplicável.');
      return _returnOrFallbackBR(year, countryCode, key, {});
    } catch (e) {
      debugPrint('Feriados: API falhou ($e), usando fallback BR se aplicável.');
      return _returnOrFallbackBR(year, countryCode, key, {});
    }
  }

  Map<DateTime, String> _cacheAndReturn(String key, Map<DateTime, String> value) {
    _cache[key] = value;
    return value;
  }

  Map<DateTime, String> _returnOrFallbackBR(
    int year,
    String countryCode,
    String key,
    Map<DateTime, String> empty,
  ) {
    if (countryCode.toUpperCase() == 'BR' && _staticBR.containsKey(year)) {
      final fallback = Map<DateTime, String>.from(_staticBR[year]!);
      final existing = _loadFromDisk(key);
      if (existing == null || !_mapsEqual(fallback, existing)) {
        _saveToDisk(key, fallback);
      }
      return _cacheAndReturn(key, fallback);
    }
    return _cacheAndReturn(key, empty);
  }
}
