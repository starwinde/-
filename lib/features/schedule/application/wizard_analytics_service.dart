import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wizard_analytics_service.g.dart';

/// Step-level wizard analytics interface.
///
/// PR1 ships only the data path. Real PostHog/Firebase wiring lands in
/// `.scratch/weekly-wizard-v2/issues/08-analytics-and-adr.md` (deferred per
/// that issue's "analytics service 미구현" note).
///
/// Event spec: see `docs/analytics_events.md` §wizard_step_*.
abstract class WizardAnalyticsService {
  void stepViewed({
    required String stepId,
    required int stepIndex,
    required int totalSteps,
    required String? status,
  });

  void stepCompleted({
    required String stepId,
    required int stepIndex,
    required int timeToCompleteMs,
  });

  void stepBack({
    required String fromStepId,
    required String toStepId,
  });

  void abandoned({
    required String lastStepId,
    required int stepIndex,
    required int totalSteps,
  });
}

/// Default implementation. In production it is silent. In tests, pass
/// `record: true` to capture events for assertion.
class NoOpWizardAnalyticsService implements WizardAnalyticsService {
  NoOpWizardAnalyticsService({this.record = false});

  final bool record;
  final List<Map<String, Object?>> recorded = <Map<String, Object?>>[];

  void _capture(Map<String, Object?> event) {
    if (record) {
      recorded.add(event);
    } else if (kDebugMode) {
      debugPrint('[wizard-analytics] ${event['event']}: $event');
    }
  }

  @override
  void stepViewed({
    required String stepId,
    required int stepIndex,
    required int totalSteps,
    required String? status,
  }) {
    _capture({
      'event': 'wizard_step_viewed',
      'step_id': stepId,
      'step_index': stepIndex,
      'total_steps': totalSteps,
      'status': status,
    });
  }

  @override
  void stepCompleted({
    required String stepId,
    required int stepIndex,
    required int timeToCompleteMs,
  }) {
    _capture({
      'event': 'wizard_step_completed',
      'step_id': stepId,
      'step_index': stepIndex,
      'time_to_complete_ms': timeToCompleteMs,
    });
  }

  @override
  void stepBack({
    required String fromStepId,
    required String toStepId,
  }) {
    _capture({
      'event': 'wizard_step_back',
      'from_step_id': fromStepId,
      'to_step_id': toStepId,
    });
  }

  @override
  void abandoned({
    required String lastStepId,
    required int stepIndex,
    required int totalSteps,
  }) {
    _capture({
      'event': 'wizard_abandoned',
      'last_step_id': lastStepId,
      'step_index': stepIndex,
      'total_steps': totalSteps,
    });
  }
}

/// Riverpod provider — overridden in tests with a recording NoOp.
@riverpod
WizardAnalyticsService wizardAnalyticsService(Ref ref) =>
    NoOpWizardAnalyticsService();
