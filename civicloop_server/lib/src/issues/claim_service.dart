import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'issue_endpoint.dart';

/// Service managing secure claim tokens for anonymous citizen reports.
class ClaimService {
  const ClaimService();

  /// Generates a cryptographically random claim token and its SHA-256 hash.
  ///
  /// Returns a record with `(token: rawToken, hash: sha256HexHash)`.
  /// The raw token is returned only to the reporter; the hash is stored in PostgreSQL.
  (String token, String hash) generateClaimToken(int issueId) {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    final randomHex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    final rawToken = 'clm_${issueId}_$randomHex';
    final tokenHash = sha256.convert(utf8.encode(rawToken)).toString();
    return (rawToken, tokenHash);
  }

  /// Verifies whether [claimToken] grants private access to [issue].
  ///
  /// 1. Checks if the SHA-256 hash of [claimToken] matches [issue.claimHash].
  /// 2. Falls back to validating HMAC upload token for backwards compatibility.
  bool verifyClaim(Session session, Issue issue, String? claimToken) {
    if (claimToken == null || claimToken.trim().isEmpty) {
      return false;
    }
    final trimmed = claimToken.trim();

    // 1. Direct hash verification
    if (issue.claimHash != null && issue.claimHash!.isNotEmpty) {
      final inputHash = sha256.convert(utf8.encode(trimmed)).toString();
      final expectedBytes = utf8.encode(issue.claimHash!);
      final actualBytes = utf8.encode(inputHash);
      if (_constantTimeEquals(expectedBytes, actualBytes)) {
        return true;
      }
    }

    // 2. Fallback to HMAC upload token verification if token matches upload token format
    if (issue.id != null) {
      try {
        if (IssueEndpoint.verifyUploadToken(session, issue.id!, trimmed)) {
          return true;
        }
      } catch (_) {}
    }

    return false;
  }
}

bool _constantTimeEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var result = 0;
  for (var i = 0; i < a.length; i++) {
    result |= a[i] ^ b[i];
  }
  return result == 0;
}
