/// In-memory and session claim token manager for anonymous civic reports.
class ClaimStorage {
  static final Map<int, String> _memoryCache = {};

  /// Saves a secret claim token returned by the server for an issue report.
  static void saveClaimToken(int issueId, String token) {
    if (token.isNotEmpty) {
      _memoryCache[issueId] = token;
    }
  }

  /// Retrieves the saved claim token for an issue, if any.
  static String? getClaimToken(int issueId) {
    return _memoryCache[issueId];
  }

  /// Checks if a claim token exists for the specified issue ID.
  static bool hasClaimToken(int issueId) {
    return _memoryCache.containsKey(issueId);
  }

  /// Returns all stored issue IDs and their tokens.
  static Map<int, String> getAllTokens() {
    return Map.unmodifiable(_memoryCache);
  }

  /// Clears stored tokens (e.g. for testing).
  static void clear() {
    _memoryCache.clear();
  }
}
