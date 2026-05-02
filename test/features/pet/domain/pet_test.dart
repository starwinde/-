import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/pet/domain/pet.dart';
import 'package:routinemon/features/pet/domain/pet_name_validator.dart';

void main() {
  group('Pet', () {
    test('생성 시 기본값 확인 (hp=100, xp=0, level=1, isAlive=true)', () {
      const pet = Pet(species: PetSpecies.bird, name: '참새');
      expect(pet.hp, 100);
      expect(pet.xp, 0);
      expect(pet.level, 1);
      expect(pet.isAlive, true);
    });

    test('종별 enum 값 검증', () {
      expect(PetSpecies.values.length, 3);
      expect(PetSpecies.values, contains(PetSpecies.bird));
      expect(PetSpecies.values, contains(PetSpecies.dragon));
      expect(PetSpecies.values, contains(PetSpecies.dolphin));
    });
  });

  group('PetNameValidator', () {
    test('이름 1~10자 허용', () {
      expect(PetNameValidator.isValid('참새'), true);
      expect(PetNameValidator.isValid('A'), true);
      expect(PetNameValidator.isValid('1234567890'), true);
    });

    test('빈 이름 거부', () {
      expect(PetNameValidator.isValid(''), false);
    });

    test('11자 이상 거부', () {
      expect(PetNameValidator.isValid('12345678901'), false);
    });

    test('금칙어 거부', () {
      expect(PetNameValidator.isValid('바보'), false);
    });
  });

  group('NicknameValidator', () {
    test('닉네임 2~12자 허용', () {
      expect(NicknameValidator.isValid('유저'), true);
      expect(NicknameValidator.isValid('AB'), true);
    });

    test('1자 거부', () {
      expect(NicknameValidator.isValid('A'), false);
    });

    test('13자 이상 거부', () {
      expect(NicknameValidator.isValid('1234567890123'), false);
    });

    test('금칙어 거부', () {
      expect(NicknameValidator.isValid('바보야'), false);
      expect(NicknameValidator.isValid('fuck'), false);
    });
  });
}
