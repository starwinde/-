// Role-based wizard UI — 새 위저드 진입점 (UC2).
//
// 2026-05-12. 기존 /schedule/wizard 라우트는 그대로 두고 별 라우트
// /schedule/wizard-v3 로 추가. 본 페이지는 RoleAnswerDraft 를 모은 뒤
// RoleAnswerProjector 로 기존 WizardAnswers 형태로 투영 → 기존
// preview/save 흐름과 호환.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routinemon/features/schedule/domain/role_wizard.dart';

class RoleWizardPage extends ConsumerStatefulWidget {
  const RoleWizardPage({super.key});

  @override
  ConsumerState<RoleWizardPage> createState() => _RoleWizardPageState();
}

class _RoleWizardPageState extends ConsumerState<RoleWizardPage> {
  /// step 0 = role selection. step n (1..N) = question n-1.
  int _step = 0;
  RoleAnswerDraft? _draft;

  void _selectRole(Role role) {
    setState(() {
      _draft = RoleAnswerDraft(role: role);
      _step = 1;
    });
  }

  void _selectOption(WizardQuestion q, WizardOption opt) {
    final next = _draft!.setAnswer(q.id, opt.id);
    final total = questionsFor(_draft!.role).length;
    setState(() {
      _draft = next;
      _step += 1;
    });
    if (_step > total) {
      // 완료 — 미리보기 라우트로 (기존 /schedule/wizard/preview 가 WizardState 의존이라
      // 본 단계에서는 단순 다이얼로그로 결과 표시. 사용자 결정 후 wire 변경 가능).
      _showCompletion();
    }
  }

  void _goBack() {
    if (_step > 0) {
      setState(() => _step -= 1);
      if (_step == 0) {
        // 역할 선택으로 복귀 시 draft 폐기 (role-switch wipe 패턴과 일관).
        setState(() => _draft = null);
      }
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _showCompletion() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('위저드 완료'),
        content: Text(
          '${_draft?.role.displayLabel ?? "-"} 답변 ${_draft?.answers.length ?? 0}개 '
          '수집됨. 미리보기 wire-in 은 사용자 결정 후 진행.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 0) {
      return _RoleSelectionStep(onSelect: _selectRole);
    }
    final qs = questionsFor(_draft!.role);
    final qIndex = _step - 1;
    if (qIndex >= qs.length) {
      // 안전망: 완료 후 step 이 초과되면 0 으로 리셋.
      return _RoleSelectionStep(onSelect: _selectRole);
    }
    final q = qs[qIndex];
    return _RoleQuestionStep(
      stepIndex: qIndex,
      totalSteps: qs.length,
      role: _draft!.role,
      question: q,
      onSelect: (opt) => _selectOption(q, opt),
      onBack: _goBack,
    );
  }
}

class _RoleSelectionStep extends StatelessWidget {
  const _RoleSelectionStep({required this.onSelect});
  final void Function(Role role) onSelect;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('당신의 주된 역할은?')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              '당신을 가장 잘 설명하는 역할을 골라주세요. 역할별로 7가지 후속 질문이 이어집니다.',
              style: TextStyle(fontSize: 14),
            ),
          ),
          for (final role in Role.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: Text(role.displayLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => onSelect(role),
              ),
            ),
        ],
      ),
    );
  }
}

class _RoleQuestionStep extends StatelessWidget {
  const _RoleQuestionStep({
    required this.stepIndex,
    required this.totalSteps,
    required this.role,
    required this.question,
    required this.onSelect,
    required this.onBack,
  });

  final int stepIndex;
  final int totalSteps;
  final Role role;
  final WizardQuestion question;
  final void Function(WizardOption opt) onSelect;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final progress = (stepIndex + 1) / totalSteps;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: Text('${role.displayLabel} · ${stepIndex + 1}/$totalSteps'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(value: progress),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              question.label,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final opt in question.options)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () => onSelect(opt),
                      child: Text(opt.label,
                          style: const TextStyle(fontSize: 16)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
