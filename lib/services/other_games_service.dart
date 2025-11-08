import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/other_game.dart';

class OtherGamesService {
  const OtherGamesService();

  static const String _endpoint = 'https://api.freegametoplay.com/apps';

  Future<List<OtherGame>> fetchOtherGames({String? excludeTitle}) async {
    final uri = Uri.parse(_endpoint);
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load FGTP games (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected FGTP games response format');
    }

    final success = decoded['success'] == true;
    if (!success) {
      throw Exception('FGTP games request not successful');
    }

    final data = decoded['data'];
    if (data is! List) {
      throw Exception('Unexpected FGTP games payload');
    }

    final games = data
        .whereType<Map<String, dynamic>>()
        .map(OtherGame.fromJson)
        .where(
          (game) =>
              excludeTitle == null || !game.matchesTitle(excludeTitle),
        )
        .toList()
      ..sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

    return games;
  }
}

