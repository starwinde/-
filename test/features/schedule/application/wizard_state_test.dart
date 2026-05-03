import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/schedule/application/wizard_state.dart';
import 'package:routinemon/features/schedule/data/wizard_models.dart';
import 'package:routinemon/features/schedule/domain/schedule_category.dart';

RefinementTurn _turn(int n) => RefinementTurn(
      turn: n,
      items: const [
        GeneratedScheduleItem(
          title: 't',
          dayOfWeek: 0,
          startTime: '09:00',
          endTime: '10:00',
          category: ScheduleCategory.work,
        ),
      ],
      timestamp: DateTime(2026, 5, 4, n),
    );

void main() {
  group('RefinementSession 모델', () {
    test('빈 history → turnCount=0, isFull=false, window=[]', () {
      const s = RefinementSession(conversationId: 'c1');
      expect(s.turnCount, 0);
      expect(s.isFull, isFalse);
      expect(s.window, isEmpty);
    });

    test('window: history.length ≤ 2 → 그대로 반환', () {
      final s = RefinementSession(
        conversationId: 'c1',
        history: [_turn(1)],
      );
      expect(s.window.length, 1);
      expect(s.window.first.turn, 1);
    });

    test('window: history.length=4 → 마지막 2턴만', () {
      final s = RefinementSession(
        conversationId: 'c1',
        history: [_turn(1), _turn(2), _turn(3), _turn(4)],
      );
      expect(s.window.length, 2);
      expect(s.window.first.turn, 3);
      expect(s.window.last.turn, 4);
    });

    test('isFull: turnCount = maxTurns(=5)', () {
      final s = RefinementSession(
        conversationId: 'c1',
        history: List.generate(5, (i) => _turn(i + 1)),
      );
      expect(s.isFull, isTrue);
    });

    test('JSON round-trip', () {
      final s = RefinementSession(
        conversationId: 'c1',
        history: [_turn(1)],
      );
      final j = s.toJson();
      final back = RefinementSession.fromJson(j);
      expect(back.conversationId, 'c1');
      expect(back.history.length, 1);
      expect(back.history.first.turn, 1);
    });
  });

  group('RefinementSessionNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('build() 초기 → null', () {
      expect(container.read(refinementSessionProvider), isNull);
    });

    test('start() → state 가 비어있는 session 으로 초기화', () {
      container
          .read(refinementSessionProvider.notifier)
          .start('c-test');
      final s = container.read(refinementSessionProvider);
      expect(s, isNotNull);
      expect(s!.conversationId, 'c-test');
      expect(s.turnCount, 0);
    });

    test('tryAppend: session 부재 → false', () {
      final ok = container
          .read(refinementSessionProvider.notifier)
          .tryAppend(_turn(1));
      expect(ok, isFalse);
    });

    test('tryAppend: 정상 누적', () {
      final notifier =
          container.read(refinementSessionProvider.notifier);
      notifier.start('c1');
      expect(notifier.tryAppend(_turn(1)), isTrue);
      expect(notifier.tryAppend(_turn(2)), isTrue);
      final s = container.read(refinementSessionProvider)!;
      expect(s.turnCount, 2);
    });

    test('tryAppend: 5턴 도달 → 6번째 false', () {
      final notifier =
          container.read(refinementSessionProvider.notifier);
      notifier.start('c1');
      for (var i = 1; i <= 5; i++) {
        expect(notifier.tryAppend(_turn(i)), isTrue);
      }
      final s = container.read(refinementSessionProvider)!;
      expect(s.isFull, isTrue);
      expect(notifier.tryAppend(_turn(6)), isFalse);
    });

    test('reset() → state null', () {
      final notifier =
          container.read(refinementSessionProvider.notifier);
      notifier
        ..start('c1')
        ..tryAppend(_turn(1))
        ..reset();
      expect(container.read(refinementSessionProvider), isNull);
    });
  });
}
