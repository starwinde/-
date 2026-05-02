import 'package:freezed_annotation/freezed_annotation.dart';

part 'pet.freezed.dart';

enum PetSpecies { bird, dragon, dolphin }

@freezed
sealed class Pet with _$Pet {
  const factory Pet({
    required PetSpecies species,
    required String name,
    @Default(1) int level,
    @Default(0) int xp,
    @Default(100) int hp,
    @Default(true) bool isAlive,
    DateTime? createdAt,
    DateTime? diedAt,
    String? deathCause,
  }) = _Pet;
}
