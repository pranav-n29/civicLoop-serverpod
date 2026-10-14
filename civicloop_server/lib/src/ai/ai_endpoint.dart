import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'ai_triage_provider.dart';
import 'ai_triage_service.dart';

/// Endpoint for AI-assisted civic issue triage.
class AiEndpoint extends Endpoint {
  /// Testing override for the triage service.
  static AiTriageService? serviceForTesting;

  /// Injects a custom [service] for testing purposes.
  void setServiceForTesting(AiTriageService? service) {
    serviceForTesting = service;
  }

  /// Analyzes an issue [description] and returns structured triage metadata
  /// including suggested title, category, priority (low, medium, high, critical),
  /// responsible department, and a summary.
  ///
  /// Throws [ArgumentError] if the description is invalid or empty.
  /// Throws [AiConfigurationException] if no AI provider credentials are configured.
  /// Throws [AiProviderException] if the AI provider encounters an error.
  /// Throws [AiValidationException] if the AI output fails validation.
  Future<IssueTriageResult> triageIssue(
    Session session,
    String description,
  ) async {
    final service = serviceForTesting ?? createService(session);
    return await service.triage(description);
  }

  /// Resolves credentials, model configuration, and creates the [AiTriageService].
  AiTriageService createService(
    Session session, {
    HttpClient Function()? clientFactory,
    Uri? customEndpointUri,
  }) {
    String? apiKey;
    try {
      apiKey = session.passwords['geminiApiKey'];
    } catch (_) {}

    if (apiKey == null || apiKey.trim().isEmpty) {
      try {
        apiKey = session.serverpod.getPassword('geminiApiKey');
      } catch (_) {}
    }

    if (apiKey == null || apiKey.trim().isEmpty) {
      apiKey = Platform.environment['GEMINI_API_KEY'];
    }

    if (apiKey == null || apiKey.trim().isEmpty) {
      throw AiConfigurationException(
        'AI triage is not configured: live AI inference is not enabled '
        'because no Gemini API key was found in passwords.yaml (geminiApiKey) '
        'or GEMINI_API_KEY environment variable.',
      );
    }

    String? model;
    try {
      model = session.passwords['geminiModel'];
    } catch (_) {}

    if (model == null || model.trim().isEmpty) {
      try {
        model = session.serverpod.getPassword('geminiModel');
      } catch (_) {}
    }

    if (model == null || model.trim().isEmpty) {
      model = Platform.environment['GEMINI_MODEL'];
    }

    final effectiveModel = (model != null && model.trim().isNotEmpty)
        ? model.trim()
        : GeminiTriageProvider.defaultModel;

    return AiTriageService(
      provider: GeminiTriageProvider(
        apiKey: apiKey.trim(),
        modelName: effectiveModel,
        clientFactory: clientFactory,
        customEndpointUri: customEndpointUri,
      ),
    );
  }
}
