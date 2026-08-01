import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TipCard {
  final String id;
  final String category; // hydration, nutrition, running, recovery
  final String title;
  final String summary;
  final String body;

  TipCard({
    required this.id,
    required this.category,
    required this.title,
    required this.summary,
    required this.body,
  });

  factory TipCard.fromJson(Map<String, dynamic> j) => TipCard(
        id: j['id'] as String,
        category: j['category'] as String,
        title: j['title'] as String,
        summary: j['summary'] as String,
        body: j['body'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'title': title,
        'summary': summary,
        'body': body,
      };
}

/// "Dead backend" content model:
/// - The app ships with a bundled asset JSON so it's fully usable offline
///   from the very first launch, with zero server dependency.
/// - If a network is available, it opportunistically checks a static JSON
///   URL (e.g. a raw GitHub Gist/file, S3 bucket, or any static host) for a
///   newer card set and caches it locally.
/// - There is no live API, no auth, no server logic to maintain — a
///   developer just replaces the JSON file at that URL to push new content.
class ContentService extends ChangeNotifier {
  static const _cacheKey = 'cached_tip_cards_v1';
  static const _versionKey = 'cached_tip_cards_version';

  /// Point this at any static JSON file you control, e.g.:
  /// https://raw.githubusercontent.com/<you>/<repo>/main/content/tips.json
  static const String remoteContentUrl =
      'https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/fitpulse-content/main/tips.json';

  List<TipCard> _cards = [];
  List<TipCard> get cards => _cards;

  Future<void> loadInitial() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached != null) {
      _cards = _parse(cached);
    } else {
      final bundled = await rootBundle.loadString('assets/content/tips.json');
      _cards = _parse(bundled);
      await prefs.setString(_cacheKey, bundled);
    }
    notifyListeners();
    // Fire-and-forget: try to refresh from the network without blocking UI.
    unawaited(refreshFromServer());
  }

  List<TipCard> _parse(String jsonStr) {
    final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
    final list = decoded['cards'] as List<dynamic>;
    return list.map((e) => TipCard.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Returns true if new content was found and applied.
  Future<bool> refreshFromServer() async {
    try {
      final resp = await http
          .get(Uri.parse(remoteContentUrl))
          .timeout(const Duration(seconds: 6));
      if (resp.statusCode != 200) return false;

      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final remoteVersion = decoded['version']?.toString() ?? '0';

      final prefs = await SharedPreferences.getInstance();
      final localVersion = prefs.getString(_versionKey) ?? '0';

      if (remoteVersion == localVersion) return false;

      _cards = _parse(resp.body);
      await prefs.setString(_cacheKey, resp.body);
      await prefs.setString(_versionKey, remoteVersion);
      notifyListeners();
      return true;
    } catch (_) {
      // Fully offline-safe: any failure just keeps using cached/bundled data.
      return false;
    }
  }

  /// Deterministic "daily rotating tip" — same tip all day, changes at
  /// midnight, cycles through whatever card set is currently loaded.
  TipCard? get todaysTip {
    if (_cards.isEmpty) return null;
    final dayOfYear = _dayOfYear(DateTime.now());
    return _cards[dayOfYear % _cards.length];
  }

  int _dayOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    return date.difference(startOfYear).inDays;
  }

  List<TipCard> byCategory(String category) =>
      _cards.where((c) => c.category == category).toList();
}
