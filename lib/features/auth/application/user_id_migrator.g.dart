// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_id_migrator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userIdMigrator)
final userIdMigratorProvider = UserIdMigratorProvider._();

final class UserIdMigratorProvider
    extends $FunctionalProvider<UserIdMigrator, UserIdMigrator, UserIdMigrator>
    with $Provider<UserIdMigrator> {
  UserIdMigratorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userIdMigratorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userIdMigratorHash();

  @$internal
  @override
  $ProviderElement<UserIdMigrator> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserIdMigrator create(Ref ref) {
    return userIdMigrator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserIdMigrator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserIdMigrator>(value),
    );
  }
}

String _$userIdMigratorHash() => r'6e68372ba8e129a3ac3886315e3f1fdf9e914574';
