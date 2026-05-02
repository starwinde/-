import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:routinemon/core/config/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'api_client.g.dart';

/// HTTP client that automatically attaches the Supabase JWT as a Bearer token
/// to all requests sent to the self-hosted n8n API (rev 9: Workers → n8n).
///
/// In debug mode the underlying client is replaced with an [IOClient] that
/// accepts self-signed certificates for `localhost`. This is required for
/// local development against the n8n HTTPS server whose cert is not trusted
/// by the Android system store. Release builds use the default client.
class ApiClient {
  /// Creates an [ApiClient] with the given [baseUrl] and a callback to
  /// retrieve the current access token. Optional [innerClient] is injected
  /// for tests; otherwise a debug-aware client is created.
  ApiClient({
    required this.baseUrl,
    required this.getAccessToken,
    http.Client? innerClient,
  }) : _client = innerClient ?? _buildClient();

  /// Base URL of the n8n API.
  final String baseUrl;

  /// Callback that returns the current JWT, or `null` if not authenticated.
  final String? Function() getAccessToken;

  final http.Client _client;

  static http.Client _buildClient() {
    if (!kDebugMode) return http.Client();
    final inner = HttpClient()
      ..badCertificateCallback = (cert, host, port) {
        return host == 'localhost' || host == '127.0.0.1';
      };
    return IOClient(inner);
  }

  Map<String, String> get _headers {
    final token = getAccessToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Sends a GET request to [path].
  Future<http.Response> get(String path) {
    return _client.get(Uri.parse('$baseUrl$path'), headers: _headers);
  }

  /// Sends a POST request to [path] with an optional JSON [body].
  Future<http.Response> post(String path, {Object? body}) {
    return _client.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }
}

/// Provides the [ApiClient] singleton wired to the n8n URL and the current
/// Supabase session token.
@riverpod
ApiClient apiClient(Ref ref) {
  return ApiClient(
    baseUrl: Env.n8nUrl,
    getAccessToken: () =>
        Supabase.instance.client.auth.currentSession?.accessToken,
  );
}
