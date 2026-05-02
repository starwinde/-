import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:routinemon/core/native/api_client.dart';
import 'package:routinemon/features/schedule/data/auto_schedule_models.dart';
import 'package:routinemon/features/schedule/domain/schedule_category.dart';

part 'auto_schedule_service.g.dart';

/// Calls the n8n `routinemon-auto-schedule` webhook to convert free-form text
/// into a structured schedule via the local LLM (llama-server-8600-v2).
///
/// On any failure (network, non-2xx, parse error) it returns a preset fallback
/// so the UI can still offer the user an "edit manually" path.
class AutoScheduleService {
  /// Creates a service backed by [client].
  AutoScheduleService(this._client);

  static const _path = '/webhook/routinemon/auto-schedule';

  final ApiClient _client;

  /// Infers a [AutoScheduleResponse] from [text] written in [userLocale].
  Future<AutoScheduleResponse> infer({
    required String text,
    required String userLocale,
  }) async {
    try {
      final response = await _client.post(
        _path,
        body: {'text': text, 'user_locale': userLocale},
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _preset();
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return AutoScheduleResponse.fromJson(json);
    } on Exception {
      return _preset();
    }
  }

  AutoScheduleResponse _preset() => const AutoScheduleResponse(
        title: '',
        startTime: null,
        endTime: null,
        category: ScheduleCategory.etc,
        tags: [],
        confidence: 0,
        source: AutoScheduleSource.preset,
      );
}

/// Provides [AutoScheduleService] wired to the global [ApiClient].
@riverpod
AutoScheduleService autoScheduleService(Ref ref) {
  return AutoScheduleService(ref.watch(apiClientProvider));
}
