/// Reason why content was blocked by the n8n content filter.
///
/// Mirrors `n8n/shared/content_filter.js` — any new reason must be added
/// in both places.
enum ContentFilterReason {
  /// Self-harm or suicidal ideation keyword detected.
  selfHarm('self_harm'),

  /// Profanity keyword (ko or en) detected.
  profanity('profanity'),

  /// Empty or malformed input.
  emptyText('empty_text');

  const ContentFilterReason(this.wireValue);

  /// Wire value used by n8n workflows.
  final String wireValue;

  /// Parse from wire value, falling back to [profanity] for unknown values.
  static ContentFilterReason fromWire(String value) {
    return ContentFilterReason.values.firstWhere(
      (r) => r.wireValue == value,
      orElse: () => ContentFilterReason.profanity,
    );
  }
}
