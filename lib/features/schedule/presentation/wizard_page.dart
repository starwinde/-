import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:routinemon/features/schedule/application/wizard_state.dart';
import 'package:routinemon/features/schedule/data/wizard_models.dart';

/// 15-step wizard (with 2 conditionally-skippable steps) to collect user
/// lifestyle answers for weekly schedule generation. On completion,
/// navigates to the preview page.
class WizardPage extends ConsumerStatefulWidget {
  const WizardPage({super.key});

  @override
  ConsumerState<WizardPage> createState() => _WizardPageState();
}

enum _WizardStep {
  status,
  wakeTime,
  sleepTime,
  chronotype,
  workDays,
  workHours,
  commuteTime,
  mealPattern,
  focusTime,
  exercise,
  exercisePreferredTime,
  hobby,
  goalFocus,
  freeTime,
  fixedSchedules,
}

class _Option<T> {
  const _Option(this.value, this.label);
  final T value;
  final String label;
}

class _WizardPageState extends ConsumerState<WizardPage> {
  final _pageController = PageController();
  final _fixedController = TextEditingController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _fixedController.dispose();
    super.dispose();
  }

  List<_WizardStep> _visibleSteps(WizardDraft d) {
    return _WizardStep.values.where((step) {
      switch (step) {
        case _WizardStep.commuteTime:
          return d.status != LifestyleStatus.homemaker &&
              d.status != LifestyleStatus.retired;
        case _WizardStep.exercisePreferredTime:
          return d.exercise != null &&
              d.exercise != ExerciseFrequency.none;
        default:
          return true;
      }
    }).toList();
  }

  void _goNext(List<_WizardStep> steps) {
    if (_currentIndex >= steps.length - 1) {
      _submit();
      return;
    }
    unawaited(
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      ),
    );
  }

  void _goPrev() {
    if (_currentIndex > 0) {
      unawaited(
        _pageController.previousPage(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        ),
      );
    }
  }

  void _submit() {
    ref.read(wizardStateProvider.notifier).setFixed(_fixedController.text);
    context.push('/schedule/wizard/preview');
  }

  bool _isCurrentAnswered(_WizardStep step, WizardDraft d) {
    switch (step) {
      case _WizardStep.status:
        return d.status != null;
      case _WizardStep.wakeTime:
        return d.wakeTime != null;
      case _WizardStep.sleepTime:
        return d.sleepTime != null;
      case _WizardStep.chronotype:
        return d.chronotype != null;
      case _WizardStep.workDays:
        return d.workDays != null;
      case _WizardStep.workHours:
        return d.workHours != null;
      case _WizardStep.commuteTime:
        return d.commuteTime != null;
      case _WizardStep.mealPattern:
        return d.mealPattern != null;
      case _WizardStep.focusTime:
        return d.focusTime != null;
      case _WizardStep.exercise:
        return d.exercise != null;
      case _WizardStep.exercisePreferredTime:
        return d.exercisePreferredTime != null;
      case _WizardStep.hobby:
        return d.hobby != null;
      case _WizardStep.goalFocus:
        return d.goalFocus != null;
      case _WizardStep.freeTime:
        return d.freeTime != null;
      case _WizardStep.fixedSchedules:
        return true;
    }
  }

  Widget _pageFor(_WizardStep step, WizardDraft draft, WizardState notifier) {
    switch (step) {
      case _WizardStep.status:
        return _buildQuestionPage<LifestyleStatus>(
          title: '현재 직업/학업 상태는?',
          options: const [
            _Option(LifestyleStatus.worker, '직장인'),
            _Option(LifestyleStatus.student, '학생'),
            _Option(LifestyleStatus.freelancer, '프리랜서'),
            _Option(LifestyleStatus.homemaker, '주부'),
            _Option(LifestyleStatus.retired, '은퇴'),
            _Option(LifestyleStatus.other, '기타'),
          ],
          selected: draft.status,
          onSelected: notifier.setStatus,
        );
      case _WizardStep.wakeTime:
        return _buildQuestionPage<WakeTime>(
          title: '몇 시쯤 기상하세요?',
          options: const [
            _Option(WakeTime.early57, '5~7시'),
            _Option(WakeTime.morning79, '7~9시'),
            _Option(WakeTime.late911, '9~11시'),
            _Option(WakeTime.variable, '유동'),
          ],
          selected: draft.wakeTime,
          onSelected: notifier.setWakeTime,
        );
      case _WizardStep.sleepTime:
        return _buildQuestionPage<SleepTime>(
          title: '몇 시쯤 취침하세요?',
          options: const [
            _Option(SleepTime.early2123, '21~23시'),
            _Option(SleepTime.midnight231, '23~1시'),
            _Option(SleepTime.late13, '1~3시'),
            _Option(SleepTime.variable, '유동'),
          ],
          selected: draft.sleepTime,
          onSelected: notifier.setSleepTime,
        );
      case _WizardStep.chronotype:
        return _buildQuestionPage<Chronotype>(
          title: '아침형·저녁형 어느 쪽이세요?',
          options: const [
            _Option(Chronotype.morning, '아침형'),
            _Option(Chronotype.middle, '중간'),
            _Option(Chronotype.evening, '저녁형'),
          ],
          selected: draft.chronotype,
          onSelected: notifier.setChronotype,
        );
      case _WizardStep.workDays:
        return _buildQuestionPage<WorkDays>(
          title: '주 몇 일 근무/등교하세요?',
          options: const [
            _Option(WorkDays.d5, '5일'),
            _Option(WorkDays.d6, '6일'),
            _Option(WorkDays.d3to4, '3~4일'),
            _Option(WorkDays.remote, '재택'),
            _Option(WorkDays.irregular, '불규칙'),
          ],
          selected: draft.workDays,
          onSelected: notifier.setWorkDays,
        );
      case _WizardStep.workHours:
        return _buildQuestionPage<WorkHours>(
          title: '주로 언제 일/공부하세요?',
          options: const [
            _Option(WorkHours.nineToSix, '9~18 고정'),
            _Option(WorkHours.flexible, '유연 근무'),
            _Option(WorkHours.nightOrShift, '야간·교대'),
            _Option(WorkHours.remote, '원격 재택'),
            _Option(WorkHours.other, '기타'),
          ],
          selected: draft.workHours,
          onSelected: notifier.setWorkHours,
        );
      case _WizardStep.commuteTime:
        return _buildQuestionPage<CommuteTime>(
          title: '출퇴근·통학에 얼마나 걸리세요?',
          options: const [
            _Option(CommuteTime.under30, '30분 이내'),
            _Option(CommuteTime.about1h, '약 1시간'),
            _Option(CommuteTime.oneToTwoH, '1~2시간'),
            _Option(CommuteTime.noCommute, '재택·이동 없음'),
          ],
          selected: draft.commuteTime,
          onSelected: notifier.setCommuteTime,
        );
      case _WizardStep.mealPattern:
        return _buildQuestionPage<MealPattern>(
          title: '식사는 어떻게 드세요?',
          options: const [
            _Option(MealPattern.regular3, '규칙적 3끼'),
            _Option(MealPattern.irregular, '불규칙'),
            _Option(MealPattern.twoMeals, '하루 2끼'),
            _Option(MealPattern.intermittentFasting, '간헐적 단식'),
            _Option(MealPattern.other, '기타'),
          ],
          selected: draft.mealPattern,
          onSelected: notifier.setMealPattern,
        );
      case _WizardStep.focusTime:
        return _buildQuestionPage<FocusTimeWindow>(
          title: '집중이 잘 되는 시간대는?',
          options: const [
            _Option(FocusTimeWindow.earlyMorning, '새벽 (6~9)'),
            _Option(FocusTimeWindow.morning, '오전 (9~12)'),
            _Option(FocusTimeWindow.afternoon, '오후 (12~15)'),
            _Option(FocusTimeWindow.evening, '저녁 (15~18)'),
            _Option(FocusTimeWindow.night, '야간 (18~24)'),
          ],
          selected: draft.focusTime,
          onSelected: notifier.setFocusTime,
        );
      case _WizardStep.exercise:
        return _buildQuestionPage<ExerciseFrequency>(
          title: '운동은 얼마나 하세요?',
          options: const [
            _Option(ExerciseFrequency.none, '안 함'),
            _Option(ExerciseFrequency.light, '주 1~2회'),
            _Option(ExerciseFrequency.moderate, '주 3~5회'),
            _Option(ExerciseFrequency.daily, '매일'),
          ],
          selected: draft.exercise,
          onSelected: notifier.setExercise,
        );
      case _WizardStep.exercisePreferredTime:
        return _buildQuestionPage<ExercisePreferredTime>(
          title: '운동 선호 시간대는?',
          options: const [
            _Option(ExercisePreferredTime.morning, '아침'),
            _Option(ExercisePreferredTime.lunch, '점심'),
            _Option(ExercisePreferredTime.evening, '저녁'),
            _Option(ExercisePreferredTime.weekend, '주말 집중'),
            _Option(ExercisePreferredTime.flexible, '유연'),
          ],
          selected: draft.exercisePreferredTime,
          onSelected: notifier.setExercisePreferredTime,
        );
      case _WizardStep.hobby:
        return _buildQuestionPage<HobbyPreference>(
          title: '취미·자기계발 시간 선호?',
          options: const [
            _Option(HobbyPreference.weekdayEvening, '평일 저녁'),
            _Option(HobbyPreference.weekend, '주말'),
            _Option(HobbyPreference.none, '선호 안 함'),
          ],
          selected: draft.hobby,
          onSelected: notifier.setHobby,
        );
      case _WizardStep.goalFocus:
        return _buildQuestionPage<GoalFocus>(
          title: '이번 주 중점 목표는?',
          options: const [
            _Option(GoalFocus.workStudy, '업무·학업'),
            _Option(GoalFocus.health, '건강'),
            _Option(GoalFocus.hobbyGrowth, '취미·성장'),
            _Option(GoalFocus.relationships, '인간관계'),
            _Option(GoalFocus.rest, '휴식'),
          ],
          selected: draft.goalFocus,
          onSelected: notifier.setGoalFocus,
        );
      case _WizardStep.freeTime:
        return _buildQuestionPage<FreeTimeMin>(
          title: '하루 최소 자유시간 원하는 양?',
          options: const [
            _Option(FreeTimeMin.oneHour, '1시간'),
            _Option(FreeTimeMin.twoHours, '2시간'),
            _Option(FreeTimeMin.threeHoursPlus, '3시간 이상'),
          ],
          selected: draft.freeTime,
          onSelected: notifier.setFreeTime,
        );
      case _WizardStep.fixedSchedules:
        return _FixedSchedulesStep(controller: _fixedController);
    }
  }

  Widget _buildQuestionPage<T>({
    required String title,
    required List<_Option<T>> options,
    required T? selected,
    required ValueChanged<T> onSelected,
  }) {
    return _StepScaffold(
      title: title,
      child: Column(
        children: [
          for (final opt in options)
            RadioListTile<T>(
              title: Text(opt.label),
              value: opt.value,
              groupValue: selected,
              onChanged: (v) {
                if (v != null) onSelected(v);
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(wizardStateProvider);
    final notifier = ref.read(wizardStateProvider.notifier);
    final steps = _visibleSteps(draft);
    // Clamp index if the visible-steps list shrank due to conditional skip.
    final safeIndex = _currentIndex.clamp(0, steps.length - 1);
    final currentStep = steps[safeIndex];
    final canAdvance = _isCurrentAnswered(currentStep, draft);
    final isLast = safeIndex == steps.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('주간 일정 만들기'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (safeIndex + 1) / steps.length,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${safeIndex + 1} / ${steps.length}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: steps.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (_, i) => _pageFor(steps[i], draft, notifier),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (safeIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _goPrev,
                    child: const Text('이전'),
                  ),
                ),
              if (safeIndex > 0) const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: canAdvance ? () => _goNext(steps) : null,
                  child: Text(isLast ? '완료' : '다음'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Step widgets ----------

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Expanded(child: SingleChildScrollView(child: child)),
        ],
      ),
    );
  }
}

class _FixedSchedulesStep extends StatelessWidget {
  const _FixedSchedulesStep({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: '고정된 일정이 있다면 알려주세요 (선택)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '예: 월 9:00 회의, 수 18:00 요가',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '자유롭게 입력하세요',
            ),
          ),
        ],
      ),
    );
  }
}
