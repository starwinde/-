// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_bridge.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Pigeon [UsageApi] 인스턴스를 제공하는 provider.

@ProviderFor(usageApi)
final usageApiProvider = UsageApiProvider._();

/// Pigeon [UsageApi] 인스턴스를 제공하는 provider.

final class UsageApiProvider
    extends $FunctionalProvider<UsageApi, UsageApi, UsageApi>
    with $Provider<UsageApi> {
  /// Pigeon [UsageApi] 인스턴스를 제공하는 provider.
  UsageApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usageApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usageApiHash();

  @$internal
  @override
  $ProviderElement<UsageApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UsageApi create(Ref ref) {
    return usageApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UsageApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UsageApi>(value),
    );
  }
}

String _$usageApiHash() => r'b65925d7e4d831d945529df7798df8ec8646c8c4';

/// UsageStats 특수 권한 보유 여부를 반환하는 provider.

@ProviderFor(hasUsagePermission)
final hasUsagePermissionProvider = HasUsagePermissionProvider._();

/// UsageStats 특수 권한 보유 여부를 반환하는 provider.

final class HasUsagePermissionProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// UsageStats 특수 권한 보유 여부를 반환하는 provider.
  HasUsagePermissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasUsagePermissionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasUsagePermissionHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return hasUsagePermission(ref);
  }
}

String _$hasUsagePermissionHash() =>
    r'fff1eea9c0a19162b2ec5e00cd9fba1faf4beb44';

/// 주어진 시간 범위의 앱 사용 통계를 조회하는 provider.

@ProviderFor(queryUsageStats)
final queryUsageStatsProvider = QueryUsageStatsFamily._();

/// 주어진 시간 범위의 앱 사용 통계를 조회하는 provider.

final class QueryUsageStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppUsageInfo>>,
          List<AppUsageInfo>,
          FutureOr<List<AppUsageInfo>>
        >
    with
        $FutureModifier<List<AppUsageInfo>>,
        $FutureProvider<List<AppUsageInfo>> {
  /// 주어진 시간 범위의 앱 사용 통계를 조회하는 provider.
  QueryUsageStatsProvider._({
    required QueryUsageStatsFamily super.from,
    required ({int startTime, int endTime}) super.argument,
  }) : super(
         retry: null,
         name: r'queryUsageStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$queryUsageStatsHash();

  @override
  String toString() {
    return r'queryUsageStatsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<AppUsageInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AppUsageInfo>> create(Ref ref) {
    final argument = this.argument as ({int startTime, int endTime});
    return queryUsageStats(
      ref,
      startTime: argument.startTime,
      endTime: argument.endTime,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is QueryUsageStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$queryUsageStatsHash() => r'05b011025c5692e54e42b230650622c875929ebc';

/// 주어진 시간 범위의 앱 사용 통계를 조회하는 provider.

final class QueryUsageStatsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<AppUsageInfo>>,
          ({int startTime, int endTime})
        > {
  QueryUsageStatsFamily._()
    : super(
        retry: null,
        name: r'queryUsageStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 주어진 시간 범위의 앱 사용 통계를 조회하는 provider.

  QueryUsageStatsProvider call({
    required int startTime,
    required int endTime,
  }) => QueryUsageStatsProvider._(
    argument: (startTime: startTime, endTime: endTime),
    from: this,
  );

  @override
  String toString() => r'queryUsageStatsProvider';
}

/// 설치된 패키지 목록을 반환하는 provider.

@ProviderFor(installedPackages)
final installedPackagesProvider = InstalledPackagesProvider._();

/// 설치된 패키지 목록을 반환하는 provider.

final class InstalledPackagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// 설치된 패키지 목록을 반환하는 provider.
  InstalledPackagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'installedPackagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$installedPackagesHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return installedPackages(ref);
  }
}

String _$installedPackagesHash() => r'0f6ad3f091c54bcbc8143c9224b6118c7c6eace6';

/// 현재 디바이스에서 `Intent.CATEGORY_HOME` 을 처리하는 모든 패키지 (런처).
/// 사용 통계 표시 시 distraction 통계에서 제외하는 데 사용. 결과는
/// keepAlive 캐시 — 사용자가 새 런처를 설치하기 전까지 안정적.

@ProviderFor(launcherPackages)
final launcherPackagesProvider = LauncherPackagesProvider._();

/// 현재 디바이스에서 `Intent.CATEGORY_HOME` 을 처리하는 모든 패키지 (런처).
/// 사용 통계 표시 시 distraction 통계에서 제외하는 데 사용. 결과는
/// keepAlive 캐시 — 사용자가 새 런처를 설치하기 전까지 안정적.

final class LauncherPackagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          FutureOr<Set<String>>
        >
    with $FutureModifier<Set<String>>, $FutureProvider<Set<String>> {
  /// 현재 디바이스에서 `Intent.CATEGORY_HOME` 을 처리하는 모든 패키지 (런처).
  /// 사용 통계 표시 시 distraction 통계에서 제외하는 데 사용. 결과는
  /// keepAlive 캐시 — 사용자가 새 런처를 설치하기 전까지 안정적.
  LauncherPackagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'launcherPackagesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$launcherPackagesHash();

  @$internal
  @override
  $FutureProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<String>> create(Ref ref) {
    return launcherPackages(ref);
  }
}

String _$launcherPackagesHash() => r'40ad28958c6585eee0cec27ec2bd30d4326075a1';

/// 패키지명 → 사람 표시명 캐시. UI 가 batch 로 lookup 후 결과 캐시.

@ProviderFor(AppLabelCache)
final appLabelCacheProvider = AppLabelCacheProvider._();

/// 패키지명 → 사람 표시명 캐시. UI 가 batch 로 lookup 후 결과 캐시.
final class AppLabelCacheProvider
    extends $NotifierProvider<AppLabelCache, Map<String, String>> {
  /// 패키지명 → 사람 표시명 캐시. UI 가 batch 로 lookup 후 결과 캐시.
  AppLabelCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLabelCacheProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLabelCacheHash();

  @$internal
  @override
  AppLabelCache create() => AppLabelCache();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, String>>(value),
    );
  }
}

String _$appLabelCacheHash() => r'4ec999e5376844df043aad61174482faaf4fc2d1';

/// 패키지명 → 사람 표시명 캐시. UI 가 batch 로 lookup 후 결과 캐시.

abstract class _$AppLabelCache extends $Notifier<Map<String, String>> {
  Map<String, String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, String>, Map<String, String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, String>, Map<String, String>>,
              Map<String, String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
