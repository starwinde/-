import 'package:flutter/material.dart';

import 'package:routinemon/features/pet/domain/pet.dart';

/// 다마고치 이미지 자산이 추가되기 전까지 사용하는 텍스트 플레이스홀더.
///
/// 단일 진실 원천(SoT) — 모든 펫 시각 표현은 이 위젯을 거친다.
/// 이미지가 준비되면 [_resolveAssetPath] 가 반환하는 경로에 PNG 를 올리고
/// `Image.asset` 분기를 활성화하기만 하면 된다.
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
    final slot = _slotLabel();
    final caption = _captionFor();
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
          '$slot\n$caption',
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

  /// `그림 A1`, `그림 C3` 등 인벤토리 슬롯 라벨.
  String _slotLabel() {
    switch (kind) {
      case PetPlaceholderKind.egg:
        return '그림 A${species.index + 1}';
      case PetPlaceholderKind.eggCracking:
        return '그림 B${species.index + 1}';
      case PetPlaceholderKind.stage:
        final letter = switch (species) {
          PetSpecies.bird => 'C',
          PetSpecies.dragon => 'D',
          PetSpecies.dolphin => 'E',
        };
        return '그림 $letter$stage';
    }
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
