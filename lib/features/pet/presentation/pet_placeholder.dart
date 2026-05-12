import 'package:flutter/material.dart';

import 'package:routinemon/features/pet/domain/pet.dart';

/// 다마고치 이미지 위젯 — 모든 펫 시각 표현의 단일 진실 원천(SoT).
///
/// 자산 경로 규칙: `assets/pet/<species>/<slot>.png` 의 4 슬롯
/// (egg, baby, growth, adult). [_resolveAssetPath] 가 [kind]/[stage] 로부터
/// 슬롯을 결정한다. 자산 부재 시 [errorBuilder] 가 텍스트 박스 fallback.
class PetPlaceholder extends StatelessWidget {
  const PetPlaceholder({
    super.key,
    required this.species,
    required this.kind,
    this.stage = 1,
    this.size = 80,
  });

  final PetSpecies species;
  final PetPlaceholderKind kind;

  /// 진화 단계 (1-base). [PetPlaceholderKind.stage] 일 때만 의미가 있다.
  final int stage;

  /// 한 변의 크기 (정사각).
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        _resolveAssetPath(),
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) => _fallback(),
      ),
    );
  }

  String _resolveAssetPath() {
    final speciesDir = switch (species) {
      PetSpecies.bird => 'bird',
      PetSpecies.dragon => 'dragon',
      PetSpecies.dolphin => 'dolphin',
    };
    final slot = switch (kind) {
      // cracking 별 자산 부재 — egg 재사용 (v0.1.0 인벤토리 차이 흡수).
      PetPlaceholderKind.egg || PetPlaceholderKind.eggCracking => 'egg',
      PetPlaceholderKind.stage => switch (stage) {
          <= 1 => 'baby',
          2 => 'growth',
          _ => 'adult',
        },
    };
    return 'assets/pet/$speciesDir/$slot.png';
  }

  Widget _fallback() {
    final color = _baseColor();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(size / 6),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Text(
          _captionFor(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: size / 8,
            fontWeight: FontWeight.w600,
            color: color,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  Color _baseColor() => switch (species) {
        PetSpecies.bird => const Color(0xFFE6A700),
        PetSpecies.dragon => const Color(0xFFC62828),
        PetSpecies.dolphin => const Color(0xFF1565C0),
      };

  String _captionFor() {
    final s = switch (species) {
      PetSpecies.bird => '새',
      PetSpecies.dragon => '드래곤',
      PetSpecies.dolphin => '돌고래',
    };
    return switch (kind) {
      PetPlaceholderKind.egg => '$s 알',
      PetPlaceholderKind.eggCracking => '$s 부화 직전',
      PetPlaceholderKind.stage => '$s Lv$stage',
    };
  }
}

/// 펫 시각 슬롯 종류.
enum PetPlaceholderKind {
  /// 알.
  egg,

  /// 부화 직전 (갈라지는 알).
  eggCracking,

  /// 진화 단계 (Lv1+).
  stage,
}
