import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/schedule/application/wizard_analytics_service.dart';

void main() {
  group('NoOpWizardAnalyticsService (test recording mode)', () {
    test('records stepViewed events for assertion', () {
      final svc = NoOpWizardAnalyticsService(record: true);
      svc.stepViewed(stepId: 'status', stepIndex: 0, totalSteps: 15,
          status: null);
      svc.stepViewed(stepId: 'wake_time', stepIndex: 1, totalSteps: 15,
          status: 'worker');
      expect(svc.recorded.length, 2);
      expect(svc.recorded[0]['event'], 'wizard_step_viewed');
      expect(svc.recorded[0]['step_id'], 'status');
      expect(svc.recorded[0]['status'], isNull);
      expect(svc.recorded[1]['status'], 'worker');
    });

    test('records stepCompleted with time_to_complete_ms', () {
      final svc = NoOpWizardAnalyticsService(record: true);
      svc.stepCompleted(
          stepId: 'wake_time', stepIndex: 1, timeToCompleteMs: 4200);
      expect(svc.recorded.single['event'], 'wizard_step_completed');
      expect(svc.recorded.single['time_to_complete_ms'], 4200);
    });

    test('records stepBack with from/to step ids', () {
      final svc = NoOpWizardAnalyticsService(record: true);
      svc.stepBack(fromStepId: 'sleep_time', toStepId: 'wake_time');
      expect(svc.recorded.single['event'], 'wizard_step_back');
      expect(svc.recorded.single['from_step_id'], 'sleep_time');
      expect(svc.recorded.single['to_step_id'], 'wake_time');
    });

    test('records abandoned with last step', () {
      final svc = NoOpWizardAnalyticsService(record: true);
      svc.abandoned(lastStepId: 'meal_pattern', stepIndex: 7, totalSteps: 15);
      expect(svc.recorded.single['event'], 'wizard_abandoned');
      expect(svc.recorded.single['last_step_id'], 'meal_pattern');
      expect(svc.recorded.single['step_index'], 7);
    });

    test('record=false swallows events (production mode)', () {
      final svc = NoOpWizardAnalyticsService(record: false);
      svc.stepViewed(stepId: 'status', stepIndex: 0, totalSteps: 15,
          status: null);
      expect(svc.recorded, isEmpty);
    });
  });
}
