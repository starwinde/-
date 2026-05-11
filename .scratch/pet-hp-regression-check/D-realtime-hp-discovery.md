# Plan 3 §D — Real-time HP Decay: Discovery Finding

> 2026-05-12. UC3 decision: discovery only, no implementation in this cycle.
> Followup: separate PRD if user decides to add real-time decay.

## Finding

**Real-time HP decay wiring does NOT exist in the current codebase.**

Searched the entire `lib/` tree for keywords: `realtime`, `real.time`, `realTime`, `hpPerMinute`, `hpDecay`, `hpTick`, `hpReducer`, `continuous.hp`, `periodic.*hp`, `hp.*periodic`, `hp.*timer`, `timer.*hp` — **0 matches**.

## Current architecture (settlement-based, not real-time)

The HP-related data path is:

```
Per-minute (foreground only, ScheduleSessionTrigger._tick @ 60s):
   schedule active?
       ↓ yes
   queryUsageStats(lastPoll, now)
       ↓
   blacklistMs ≥ 5000ms ? → phoneInUse=true
       ↓
   sessionRepo.appendUsage(
       focusedMinDelta: phoneInUse ? 0 : 1,
       blacklistMinDelta: phoneInUse ? 1 : 0)
   [HP UNCHANGED — only session counters incremented]

Once per day (DailySettlementScheduler → SettlementOrchestrator.runForDate):
   for each session today:
       grade = XpRules.calculateFocusRatio(focusedMin, plannedMin)
   aggregate grade → consecutive D counter → hpDeduction()
   applyHpChange(currentHp, hpChange)  ← HP CHANGES HERE
   shouldDie(newHp) → isAlive
   petRepo.applySettlement(...)
```

So HP only changes:
1. **Daily settlement** (focus grade based on session totals)
2. **Feed interaction** (positive HP via `applyHpChange(pet.hp, feedHpReward)` in `pet_interaction_service.dart:136`)
3. **Manual dev settlement button** (`pet_detail_page.dart:33` calls `settlementOrchestratorProvider.runForDate`)

Phone usage in real time has **NO** immediate HP effect. A user using blacklisted apps for 10 minutes sees `blacklistUsageMin` increase in the session row but pet HP unchanged until daily settlement.

## Key code references

- `lib/features/focus_tracking/application/schedule_session_trigger.dart:149-154` — where the 60s tick computes `phoneInUse` and calls `appendUsage` (no HP touched)
- `lib/features/focus_tracking/application/daily_settlement.dart:51` — `applyHpChange(currentHp, hpChange)` — only place HP decreases
- `lib/features/focus_tracking/data/session_repository.dart:62-75` — `appendUsage` only updates `actualFocusMin` and `blacklistUsageMin` counters

## If real-time HP decay is desired (deferred — new PRD required)

Eng review (P1) recommends NOT adding a 4th foreground service. Existing tick at `schedule_session_trigger.dart:149` is the natural hook point:

```dart
// Proposed inline insertion at line 154 (post-appendUsage):
if (phoneInUse) {
  final petRepo = ref.read(petRepositoryProvider);
  final pet = await petRepo.getActivePet(userId);
  if (pet != null && pet.isAlive) {
    final result = hp_curve.applyHpChange(pet.hp, hpPerMinuteOnBlacklist);
    final newAlive = !level_curve.shouldDie(result.newHp);
    await petRepo.applySettlement(
      petId: pet.id,
      newXp: pet.xp,
      newHp: result.newHp,
      isAlive: newAlive,
    );
  }
}
```

Open questions for new PRD if user decides to proceed:

1. **Decay rate** — `hpPerMinuteOnBlacklist` value? (-1? -2?)
2. **Diminishing returns** — same blacklist app for 30 min should hit floor, not -30 HP straight
3. **Recovery** — focused minutes restore HP, or only feed?
4. **Foreground vs background** — current trigger is foreground-only (rules.md §3.5). Background sampling done by `FocusForegroundService.kt` Kotlin side; needs Dart bridge for HP feedback. Battery cost analysis required.
5. **UX feedback** — should pet show distress animation in real time? Sticky notification updates HP?
6. **Daily settlement reconciliation** — if real-time decreases HP, daily settlement should NOT double-deduct
7. **Pet death timing** — real-time death possible? Animation? Recovery time?

## Recommendation

**Do not implement real-time HP decay until product-side question UC3 is resolved.**

Behavioral psychology question (per Codex CEO review): is real-time HP loss perceived as motivating or punitive? This is NOT an engineering decision. Pet HP changes that feel arbitrary (user can't tell what caused them) can drive churn. The current settlement model gives users one daily moment of feedback, which may be the right design choice.

If user decides yes after wake: create `.scratch/realtime-hp-decay/PRD.md` with the 7 open questions above + battery test plan + behavioral A/B design.
