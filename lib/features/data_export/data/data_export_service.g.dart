// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_export_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a shared [DataExportService] backed by the app database.

@ProviderFor(dataExportService)
final dataExportServiceProvider = DataExportServiceProvider._();

/// Provides a shared [DataExportService] backed by the app database.

final class DataExportServiceProvider
    extends
        $FunctionalProvider<
          DataExportService,
          DataExportService,
          DataExportService
        >
    with $Provider<DataExportService> {
  /// Provides a shared [DataExportService] backed by the app database.
  DataExportServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataExportServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataExportServiceHash();

  @$internal
  @override
  $ProviderElement<DataExportService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DataExportService create(Ref ref) {
    return dataExportService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DataExportService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DataExportService>(value),
    );
  }
}

String _$dataExportServiceHash() => r'd8fe382ce00019241017c56702d837b45efc20bf';
