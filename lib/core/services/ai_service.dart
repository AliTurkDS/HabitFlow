import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

/// A single AI-suggested habit.
class HabitSuggestion {
  final String title;
  final String emoji;
  final String reason;

  HabitSuggestion({
    required this.title,
    required this.emoji,
    required this.reason,
  });
}

/// Talks to the Claude API to generate habit suggestions.
///
/// Dart has no official Anthropic SDK, so this uses raw HTTP against the
/// Messages API (`POST /v1/messages`) with model `claude-opus-4-8`. If no API
/// key is configured, [suggestHabits] falls back to a curated offline list so
/// the feature still works out of the box.
class AiService {
  /// [apiKey] is the user-supplied Claude key (from settings). When null/empty,
  /// it falls back to the compile-time `--dart-define=CLAUDE_API_KEY` value, and
  /// finally to the offline suggestion list.
  AiService({String? apiKey, http.Client? client})
      : _client = client ?? http.Client(),
        _apiKey = (apiKey != null && apiKey.trim().isNotEmpty)
            ? apiKey.trim()
            : AppConstants.claudeApiKey;

  final http.Client _client;
  final String _apiKey;

  bool get hasApiKey => _apiKey.isNotEmpty;

  /// Suggests habits for the user's stated [goal].
  Future<List<HabitSuggestion>> suggestHabits(String goal) async {
    if (!hasApiKey) {
      return _offlineFallback(goal);
    }

    final prompt =
        'The user wants to build habits around this goal: "$goal".\n'
        'Suggest 5 specific, actionable daily habits. Respond ONLY with a JSON '
        'array; each item has "title" (max 4 words), "emoji" (a single emoji), '
        'and "reason" (one short sentence). No prose outside the JSON.';

    try {
      final response = await _client.post(
        Uri.parse(AppConstants.claudeApiUrl),
        headers: {
          'content-type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': AppConstants.claudeModel,
          'max_tokens': 1024,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode != 200) {
        return _offlineFallback(goal);
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final content = (body['content'] as List<dynamic>)
          .firstWhere((b) => b['type'] == 'text', orElse: () => null);
      if (content == null) return _offlineFallback(goal);

      return _parseSuggestions(content['text'] as String);
    } catch (_) {
      return _offlineFallback(goal);
    }
  }

  List<HabitSuggestion> _parseSuggestions(String text) {
    // Extract the JSON array even if the model wrapped it in markdown fences.
    final start = text.indexOf('[');
    final end = text.lastIndexOf(']');
    if (start == -1 || end == -1) return [];

    final json = jsonDecode(text.substring(start, end + 1)) as List<dynamic>;
    return json
        .map((e) => HabitSuggestion(
              title: e['title'] as String? ?? 'Habit',
              emoji: e['emoji'] as String? ?? '🎯',
              reason: e['reason'] as String? ?? '',
            ))
        .toList();
  }

  List<HabitSuggestion> _offlineFallback(String goal) {
    return [
      HabitSuggestion(
        title: 'Drink water',
        emoji: '💧',
        reason: 'Hydration boosts focus and energy all day.',
      ),
      HabitSuggestion(
        title: 'Walk 20 minutes',
        emoji: '🏃',
        reason: 'A short daily walk supports almost any goal.',
      ),
      HabitSuggestion(
        title: 'Read 10 pages',
        emoji: '📚',
        reason: 'Small, consistent reading compounds over time.',
      ),
      HabitSuggestion(
        title: 'Plan tomorrow',
        emoji: '✍️',
        reason: 'A 5-minute plan makes the next day intentional.',
      ),
      HabitSuggestion(
        title: 'Sleep by 11pm',
        emoji: '😴',
        reason: 'Consistent sleep is the foundation of every habit.',
      ),
    ];
  }
}
