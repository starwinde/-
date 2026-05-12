// Role-based wizard domain — UC2 절충 구현.
//
// 사용자 명시 2026-05-11: "각 첫 질문 (역할/직업) 기준 7-branch 분기. 마지막에
// LLM 을 통한 추가 질의나 명칭 변경 — LLM 이 필요할때만 호출."
//
// autoplan UC2 권고 (양 모델 critical): 7-role taxonomy 가 culturally brittle.
// 본 구현은 학생 1개 role 만 7-question 채움. 나머지 6개 role 은 enum + stub.
// 사용자 wake 후 결정에 따라 채우거나 role 수 축소.

import 'package:meta/meta.dart';

/// 위저드 첫 질문 — 사용자 주된 역할/직업.
enum Role {
  student,
  worker,
  freelancer,
  homemaker,
  selfEmployed,
  soldier,
  other;

  /// 한국어 디스플레이 라벨.
  String get displayLabel => switch (this) {
        Role.student => '학생',
        Role.worker => '직장인',
        Role.freelancer => '프리랜서',
        Role.homemaker => '주부',
        Role.selfEmployed => '자영업',
        Role.soldier => '군인',
        Role.other => '기타',
      };
}

/// 위저드 단일 선택지.
@immutable
class WizardOption {
  const WizardOption({required this.id, required this.label});
  final String id;
  final String label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WizardOption && other.id == id && other.label == label);

  @override
  int get hashCode => Object.hash(id, label);
}

/// 위저드 단일 질문 (단일 선택형).
@immutable
class WizardQuestion {
  const WizardQuestion({
    required this.id,
    required this.label,
    required this.options,
  });
  final String id;
  final String label;
  final List<WizardOption> options;
}

/// 학생 role 의 7개 질문 — UC2 시드 구현.
///
/// Q1 `school_level`: 학교 단계(초/중/고/대) × 학원 여부 8옵션 단일 질문.
/// id 규칙 `<stage>_<academy>` — stage ∈ {elem, mid, high, uni},
/// academy ∈ {no, yes}. RoleAnswerProjector 에서 stage/academy 로 분해.
const _studentQuestions = <WizardQuestion>[
  WizardQuestion(
    id: 'school_level',
    label: '학교 단계와 학원 여부를 골라주세요',
    options: [
      WizardOption(id: 'elem_no', label: '초등학생 · 학원 안 다님'),
      WizardOption(id: 'elem_yes', label: '초등학생 · 학원 다님'),
      WizardOption(id: 'mid_no', label: '중학생 · 학원 안 다님'),
      WizardOption(id: 'mid_yes', label: '중학생 · 학원 다님'),
      WizardOption(id: 'high_no', label: '고등학생 · 학원 안 다님'),
      WizardOption(id: 'high_yes', label: '고등학생 · 학원 다님'),
      WizardOption(id: 'uni_no', label: '대학(원)생 · 학원 안 다님'),
      WizardOption(id: 'uni_yes', label: '대학(원)생 · 학원 다님'),
    ],
  ),
  WizardQuestion(
    id: 'class_window',
    label: '평일 수업이 주로 언제 있나요?',
    options: [
      WizardOption(id: 'morning', label: '오전 (09-12시)'),
      WizardOption(id: 'afternoon', label: '오후 (13-17시)'),
      WizardOption(id: 'evening', label: '저녁 (18시 이후)'),
      WizardOption(id: 'mixed', label: '혼합'),
    ],
  ),
  WizardQuestion(
    id: 'exam_period',
    label: '현재 시험기간 인가요?',
    options: [
      WizardOption(id: 'yes', label: '예, 진행 중'),
      WizardOption(id: 'soon', label: '곧 (2주 내)'),
      WizardOption(id: 'no', label: '아니오'),
    ],
  ),
  WizardQuestion(
    id: 'commute',
    label: '통학 시간이 얼마나 걸리나요?',
    options: [
      WizardOption(id: 'live_in', label: '기숙사/자취 (0분)'),
      WizardOption(id: 'short', label: '30분 이내'),
      WizardOption(id: 'medium', label: '30분~1시간'),
      WizardOption(id: 'long', label: '1시간 이상'),
    ],
  ),
  WizardQuestion(
    id: 'part_time',
    label: '알바를 하고 있나요?',
    options: [
      WizardOption(id: 'none', label: '없음'),
      WizardOption(id: 'weekend', label: '주말만'),
      WizardOption(id: 'weeknight', label: '평일 저녁'),
      WizardOption(id: 'frequent', label: '거의 매일'),
    ],
  ),
  WizardQuestion(
    id: 'self_study',
    label: '하루 자율학습 목표 시간은?',
    options: [
      WizardOption(id: 'lt2', label: '2시간 미만'),
      WizardOption(id: 'two_four', label: '2-4시간'),
      WizardOption(id: 'four_six', label: '4-6시간'),
      WizardOption(id: 'gt6', label: '6시간 이상'),
    ],
  ),
  WizardQuestion(
    id: 'exercise',
    label: '운동/활동 주간 빈도는?',
    options: [
      WizardOption(id: 'none', label: '거의 안 함'),
      WizardOption(id: 'occasional', label: '주 1-2회'),
      WizardOption(id: 'regular', label: '주 3-5회'),
      WizardOption(id: 'daily', label: '거의 매일'),
    ],
  ),
];

const _workerQuestions = <WizardQuestion>[
  WizardQuestion(
    id: 'work_form',
    label: '근무 형태가 어떻게 되시나요?',
    options: [
      WizardOption(id: 'office_9_6', label: '사무직 9-6'),
      WizardOption(id: 'shift', label: '교대제'),
      WizardOption(id: 'flex', label: '유연근무/재택'),
      WizardOption(id: 'field', label: '현장직'),
    ],
  ),
  WizardQuestion(
    id: 'commute_time',
    label: '출퇴근 시간이 얼마나 걸리나요?',
    options: [
      WizardOption(id: 'remote', label: '재택 (0분)'),
      WizardOption(id: 'short', label: '30분 이내'),
      WizardOption(id: 'medium', label: '30분~1시간'),
      WizardOption(id: 'long', label: '1시간 이상'),
    ],
  ),
  WizardQuestion(
    id: 'overtime',
    label: '야근/초과근무 빈도는?',
    options: [
      WizardOption(id: 'rare', label: '거의 없음'),
      WizardOption(id: 'weekly', label: '주 1-2회'),
      WizardOption(id: 'frequent', label: '주 3회 이상'),
      WizardOption(id: 'daily', label: '거의 매일'),
    ],
  ),
  WizardQuestion(
    id: 'after_work_meeting',
    label: '회식/저녁 약속 빈도는?',
    options: [
      WizardOption(id: 'rare', label: '월 1회 미만'),
      WizardOption(id: 'monthly', label: '월 1-2회'),
      WizardOption(id: 'weekly', label: '주 1회'),
      WizardOption(id: 'frequent', label: '주 2회 이상'),
    ],
  ),
  WizardQuestion(
    id: 'exercise',
    label: '운동 주간 빈도는?',
    options: [
      WizardOption(id: 'none', label: '거의 안 함'),
      WizardOption(id: 'occasional', label: '주 1-2회'),
      WizardOption(id: 'regular', label: '주 3-5회'),
      WizardOption(id: 'daily', label: '거의 매일'),
    ],
  ),
  WizardQuestion(
    id: 'children',
    label: '자녀가 있나요?',
    options: [
      WizardOption(id: 'none', label: '없음'),
      WizardOption(id: 'infant', label: '영아 (0-2세)'),
      WizardOption(id: 'preschool', label: '유아 (3-6세)'),
      WizardOption(id: 'school', label: '학령기 이상'),
    ],
  ),
  WizardQuestion(
    id: 'hobby_preference',
    label: '주말 우선 활동은?',
    options: [
      WizardOption(id: 'rest', label: '휴식 위주'),
      WizardOption(id: 'social', label: '사람 만나기'),
      WizardOption(id: 'hobby', label: '취미 몰입'),
      WizardOption(id: 'errand', label: '집안일/잡무'),
    ],
  ),
];

const _freelancerQuestions = <WizardQuestion>[
  WizardQuestion(
    id: 'focus_window',
    label: '집중이 가장 잘 되는 시간대는?',
    options: [
      WizardOption(id: 'early_morning', label: '새벽 (05-09시)'),
      WizardOption(id: 'morning', label: '오전 (09-12시)'),
      WizardOption(id: 'afternoon', label: '오후 (13-18시)'),
      WizardOption(id: 'night', label: '밤 (21시 이후)'),
    ],
  ),
  WizardQuestion(
    id: 'client_meetings',
    label: '클라이언트 미팅 빈도는?',
    options: [
      WizardOption(id: 'rare', label: '거의 없음'),
      WizardOption(id: 'weekly', label: '주 1-2회'),
      WizardOption(id: 'frequent', label: '주 3회 이상'),
      WizardOption(id: 'daily', label: '거의 매일'),
    ],
  ),
  WizardQuestion(
    id: 'rest_pattern',
    label: '주간 휴무 패턴은?',
    options: [
      WizardOption(id: 'weekend', label: '주말 고정'),
      WizardOption(id: 'midweek', label: '주중 평일 휴식'),
      WizardOption(id: 'flexible', label: '유동적'),
      WizardOption(id: 'rare_off', label: '거의 항상 일함'),
    ],
  ),
  WizardQuestion(
    id: 'night_work',
    label: '야간 작업 빈도는?',
    options: [
      WizardOption(id: 'never', label: '안 함'),
      WizardOption(id: 'occasional', label: '가끔 (마감 임박 시)'),
      WizardOption(id: 'frequent', label: '자주'),
      WizardOption(id: 'always', label: '주로 야간 작업'),
    ],
  ),
  WizardQuestion(
    id: 'exercise',
    label: '운동 주간 빈도는?',
    options: [
      WizardOption(id: 'none', label: '거의 안 함'),
      WizardOption(id: 'occasional', label: '주 1-2회'),
      WizardOption(id: 'regular', label: '주 3-5회'),
      WizardOption(id: 'daily', label: '거의 매일'),
    ],
  ),
  WizardQuestion(
    id: 'workspace',
    label: '주된 작업 공간은?',
    options: [
      WizardOption(id: 'home', label: '집'),
      WizardOption(id: 'cafe', label: '카페'),
      WizardOption(id: 'coworking', label: '코워킹'),
      WizardOption(id: 'mixed', label: '혼합'),
    ],
  ),
  WizardQuestion(
    id: 'income_pattern',
    label: '수입 패턴은?',
    options: [
      WizardOption(id: 'stable', label: '안정적 (월 정기)'),
      WizardOption(id: 'project', label: '프로젝트 단위'),
      WizardOption(id: 'irregular', label: '불규칙'),
    ],
  ),
];

const _homemakerQuestions = <WizardQuestion>[
  WizardQuestion(
    id: 'care_load',
    label: '주된 돌봄 부담은?',
    options: [
      WizardOption(id: 'infant', label: '영아 (0-2세)'),
      WizardOption(id: 'preschool', label: '유아 (3-6세)'),
      WizardOption(id: 'school', label: '학령기 자녀'),
      WizardOption(id: 'elderly', label: '노부모/장기 돌봄'),
      WizardOption(id: 'partner_only', label: '배우자만'),
    ],
  ),
  WizardQuestion(
    id: 'family_size',
    label: '가족 구성원 수는?',
    options: [
      WizardOption(id: 'one_two', label: '1-2인'),
      WizardOption(id: 'three', label: '3인'),
      WizardOption(id: 'four', label: '4인'),
      WizardOption(id: 'five_plus', label: '5인 이상'),
    ],
  ),
  WizardQuestion(
    id: 'side_work',
    label: '재택 부업/파트타임은?',
    options: [
      WizardOption(id: 'none', label: '없음'),
      WizardOption(id: 'occasional', label: '간헐적'),
      WizardOption(id: 'regular', label: '정기적'),
    ],
  ),
  WizardQuestion(
    id: 'me_time',
    label: '하루 자기 시간 확보 정도는?',
    options: [
      WizardOption(id: 'minimal', label: '30분 미만'),
      WizardOption(id: 'short', label: '30분~1시간'),
      WizardOption(id: 'medium', label: '1-2시간'),
      WizardOption(id: 'plenty', label: '2시간 이상'),
    ],
  ),
  WizardQuestion(
    id: 'exercise',
    label: '운동 빈도는?',
    options: [
      WizardOption(id: 'none', label: '거의 안 함'),
      WizardOption(id: 'occasional', label: '주 1-2회'),
      WizardOption(id: 'regular', label: '주 3-5회'),
    ],
  ),
  WizardQuestion(
    id: 'sleep_pattern',
    label: '수면 패턴은?',
    options: [
      WizardOption(id: 'fragmented', label: '자주 깸 (영유아 케어)'),
      WizardOption(id: 'short', label: '6시간 미만'),
      WizardOption(id: 'normal', label: '6-8시간'),
      WizardOption(id: 'plenty', label: '8시간 이상'),
    ],
  ),
  WizardQuestion(
    id: 'meal_prep',
    label: '식사 준비 시간 평균은?',
    options: [
      WizardOption(id: 'short', label: '30분 미만/회'),
      WizardOption(id: 'medium', label: '30분~1시간'),
      WizardOption(id: 'long', label: '1시간 이상'),
    ],
  ),
];

const _selfEmployedQuestions = <WizardQuestion>[
  WizardQuestion(
    id: 'business_hours',
    label: '영업 시간대는?',
    options: [
      WizardOption(id: 'standard', label: '주간 (09-18시)'),
      WizardOption(id: 'evening', label: '저녁 (15-22시)'),
      WizardOption(id: 'late_night', label: '야간 (18시-새벽)'),
      WizardOption(id: 'irregular', label: '불규칙'),
    ],
  ),
  WizardQuestion(
    id: 'staff',
    label: '직원이 있나요?',
    options: [
      WizardOption(id: 'solo', label: '혼자'),
      WizardOption(id: 'one_two', label: '1-2명'),
      WizardOption(id: 'small_team', label: '3-5명'),
      WizardOption(id: 'larger', label: '6명 이상'),
    ],
  ),
  WizardQuestion(
    id: 'off_days',
    label: '주간 휴무는?',
    options: [
      WizardOption(id: 'none', label: '연중무휴'),
      WizardOption(id: 'one_weekday', label: '주중 1일'),
      WizardOption(id: 'weekend', label: '주말'),
      WizardOption(id: 'flexible', label: '유동적'),
    ],
  ),
  WizardQuestion(
    id: 'peak_load',
    label: '바쁜 요일/시간대는?',
    options: [
      WizardOption(id: 'weekend', label: '주말 위주'),
      WizardOption(id: 'weekday_lunch', label: '평일 점심'),
      WizardOption(id: 'weekday_evening', label: '평일 저녁'),
      WizardOption(id: 'all_day', label: '하루 종일'),
    ],
  ),
  WizardQuestion(
    id: 'admin_work',
    label: '서류/회계 정리 시점은?',
    options: [
      WizardOption(id: 'daily_morning', label: '매일 오픈 전'),
      WizardOption(id: 'daily_close', label: '매일 마감 후'),
      WizardOption(id: 'weekly', label: '주 1회 몰아서'),
      WizardOption(id: 'outsourced', label: '외주/세무사'),
    ],
  ),
  WizardQuestion(
    id: 'exercise',
    label: '운동 빈도는?',
    options: [
      WizardOption(id: 'none', label: '거의 안 함'),
      WizardOption(id: 'occasional', label: '주 1-2회'),
      WizardOption(id: 'regular', label: '주 3회 이상'),
    ],
  ),
  WizardQuestion(
    id: 'family_overlap',
    label: '가족과 함께하는 시간은?',
    options: [
      WizardOption(id: 'morning', label: '오전 (영업 전)'),
      WizardOption(id: 'midday', label: '낮 (영업 중 사이)'),
      WizardOption(id: 'evening', label: '저녁 (영업 종료 후)'),
      WizardOption(id: 'minimal', label: '거의 없음'),
    ],
  ),
];

const _soldierQuestions = <WizardQuestion>[
  WizardQuestion(
    id: 'service_type',
    label: '복무 형태는?',
    options: [
      WizardOption(id: 'mandatory', label: '의무복무 (현역)'),
      WizardOption(id: 'volunteer', label: '직업군인'),
      WizardOption(id: 'reserve', label: '예비역 훈련'),
      WizardOption(id: 'public', label: '공익/사회복무'),
    ],
  ),
  WizardQuestion(
    id: 'duty_pattern',
    label: '근무 패턴은?',
    options: [
      WizardOption(id: 'day', label: '주간 고정'),
      WizardOption(id: 'shift', label: '교대 (24/48)'),
      WizardOption(id: 'field', label: '훈련/야전 위주'),
      WizardOption(id: 'desk', label: '사무 행정'),
    ],
  ),
  WizardQuestion(
    id: 'leave_pattern',
    label: '외출/휴가 빈도는?',
    options: [
      WizardOption(id: 'monthly', label: '월 1-2회'),
      WizardOption(id: 'weekly', label: '주 1회 외출'),
      WizardOption(id: 'commuting', label: '출퇴근 가능'),
      WizardOption(id: 'rare', label: '드묾 (특수 부대)'),
    ],
  ),
  WizardQuestion(
    id: 'pt_intensity',
    label: '체력단련 강도는?',
    options: [
      WizardOption(id: 'standard', label: '기본 일과'),
      WizardOption(id: 'high', label: '강한 PT'),
      WizardOption(id: 'mission', label: '임무 의존'),
    ],
  ),
  WizardQuestion(
    id: 'study_time',
    label: '개인 시간 활용은?',
    options: [
      WizardOption(id: 'study', label: '자격증/공부'),
      WizardOption(id: 'fitness', label: '체력 단련'),
      WizardOption(id: 'rest', label: '휴식'),
      WizardOption(id: 'social', label: '동료/가족 연락'),
    ],
  ),
  WizardQuestion(
    id: 'lights_out',
    label: '취침 시각은?',
    options: [
      WizardOption(id: 'early', label: '22시 이전'),
      WizardOption(id: 'standard', label: '22-24시'),
      WizardOption(id: 'late', label: '0시 이후'),
      WizardOption(id: 'irregular', label: '근무 의존'),
    ],
  ),
  WizardQuestion(
    id: 'goal',
    label: '주된 목표는?',
    options: [
      WizardOption(id: 'transition', label: '전역 후 진로 준비'),
      WizardOption(id: 'promotion', label: '진급/경력'),
      WizardOption(id: 'survive', label: '복무 무사 종료'),
      WizardOption(id: 'fitness', label: '체력/건강'),
    ],
  ),
];

const _otherQuestions = <WizardQuestion>[
  WizardQuestion(
    id: 'daily_rhythm',
    label: '하루 리듬을 가장 잘 표현하는 것은?',
    options: [
      WizardOption(id: 'early_bird', label: '아침형'),
      WizardOption(id: 'evening', label: '저녁형'),
      WizardOption(id: 'night_owl', label: '야행성'),
      WizardOption(id: 'shifting', label: '주기적 변동'),
    ],
  ),
  WizardQuestion(
    id: 'occupation_status',
    label: '현재 상태는?',
    options: [
      WizardOption(id: 'between_jobs', label: '구직/이직 준비'),
      WizardOption(id: 'studying', label: '시험/자격 준비'),
      WizardOption(id: 'recovery', label: '회복/요양'),
      WizardOption(id: 'project', label: '개인 프로젝트'),
      WizardOption(id: 'travel', label: '여행/장기 휴식'),
    ],
  ),
  WizardQuestion(
    id: 'fixed_commitments',
    label: '주간 고정 일정 수는?',
    options: [
      WizardOption(id: 'none', label: '없음'),
      WizardOption(id: 'few', label: '주 1-3개'),
      WizardOption(id: 'medium', label: '주 4-7개'),
      WizardOption(id: 'many', label: '주 8개 이상'),
    ],
  ),
  WizardQuestion(
    id: 'self_focus',
    label: '하루 자기 시간 확보 정도는?',
    options: [
      WizardOption(id: 'short', label: '1시간 미만'),
      WizardOption(id: 'medium', label: '1-3시간'),
      WizardOption(id: 'long', label: '3시간 이상'),
      WizardOption(id: 'mostly', label: '거의 자유로움'),
    ],
  ),
  WizardQuestion(
    id: 'exercise',
    label: '운동 빈도는?',
    options: [
      WizardOption(id: 'none', label: '거의 안 함'),
      WizardOption(id: 'occasional', label: '주 1-2회'),
      WizardOption(id: 'regular', label: '주 3-5회'),
      WizardOption(id: 'daily', label: '거의 매일'),
    ],
  ),
  WizardQuestion(
    id: 'social_demand',
    label: '사람 만남 빈도는?',
    options: [
      WizardOption(id: 'solo', label: '혼자가 편함'),
      WizardOption(id: 'occasional', label: '간헐적'),
      WizardOption(id: 'regular', label: '주간 정기'),
      WizardOption(id: 'frequent', label: '거의 매일'),
    ],
  ),
  WizardQuestion(
    id: 'main_goal',
    label: '주된 목표는?',
    options: [
      WizardOption(id: 'health', label: '건강/회복'),
      WizardOption(id: 'skill', label: '실력/자격'),
      WizardOption(id: 'rest', label: '쉼/재충전'),
      WizardOption(id: 'reset', label: '리셋/새 출발'),
    ],
  ),
];

/// 주어진 role 의 후속 질문 목록. 모든 role 이 7개 질문을 가진다.
List<WizardQuestion> questionsFor(Role role) {
  return switch (role) {
    Role.student => _studentQuestions,
    Role.worker => _workerQuestions,
    Role.freelancer => _freelancerQuestions,
    Role.homemaker => _homemakerQuestions,
    Role.selfEmployed => _selfEmployedQuestions,
    Role.soldier => _soldierQuestions,
    Role.other => _otherQuestions,
  };
}

/// 위저드 진행 중 답변 상태. Immutable.
///
/// 사용자가 role 을 바꾸면 [switchRole] 로 새 draft 를 만든다 — 이전 답변은
/// 폐기 (E1 fix: role-switch wipe).
@immutable
class RoleAnswerDraft {
  const RoleAnswerDraft({
    required this.role,
    this.answers = const <String, String>{},
  });

  final Role role;
  final Map<String, String> answers;

  RoleAnswerDraft setAnswer(String questionId, String optionId) {
    return RoleAnswerDraft(
      role: role,
      answers: {...answers, questionId: optionId},
    );
  }

  RoleAnswerDraft switchRole(Role newRole) {
    if (newRole == role) return this;
    return RoleAnswerDraft(role: newRole);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoleAnswerDraft &&
          other.role == role &&
          _mapEquals(other.answers, answers));

  @override
  int get hashCode => Object.hash(role, Object.hashAllUnordered(answers.entries));

  static bool _mapEquals(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (final e in a.entries) {
      if (b[e.key] != e.value) return false;
    }
    return true;
  }
}
