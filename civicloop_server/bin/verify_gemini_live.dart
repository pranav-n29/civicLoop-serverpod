import 'dart:io';

import 'package:civicloop_server/src/ai/ai_triage_provider.dart';
import 'package:civicloop_server/src/ai/ai_triage_service.dart';

/// Standalone script for executing exactly one opt-in live Gemini API verification.
///
/// Requires:
/// - Environment variable `RUN_LIVE_GEMINI_TEST=true`
/// - Environment variable `GEMINI_API_KEY=<your-key>`
/// Optional:
/// - Environment variable `GEMINI_MODEL=<model-name>` (defaults to `GeminiTriageProvider.defaultModel`)
Future<void> main() async {
  if (Platform.environment['RUN_LIVE_GEMINI_TEST'] != 'true') {
    stderr.writeln(
      'Live Gemini test is disabled.\n'
      'To enable, set RUN_LIVE_GEMINI_TEST=true and supply GEMINI_API_KEY.',
    );
    exitCode = 1;
    return;
  }

  final apiKey = Platform.environment['GEMINI_API_KEY'];
  if (apiKey == null || apiKey.trim().isEmpty) {
    stderr.writeln(
      'FAIL: GEMINI_API_KEY environment variable is not set or empty.',
    );
    exitCode = 1;
    return;
  }

  final modelName =
      Platform.environment['GEMINI_MODEL'] ?? GeminiTriageProvider.defaultModel;

  final provider = GeminiTriageProvider(
    apiKey: apiKey.trim(),
    modelName: modelName.trim(),
    useHeaderAuth: true,
  );

  final service = AiTriageService(provider: provider);

  const sampleDescription =
      'A large pothole is causing traffic problems on the main road.';

  stdout.writeln('Executing single live Gemini request...');
  stdout.writeln('Model configured: $modelName');

  try {
    final result = await service.triage(sampleDescription);

    stdout.writeln('========================================');
    stdout.writeln('LIVE GEMINI API VERIFICATION: PASS');
    stdout.writeln('Model: $modelName');
    stdout.writeln('Category: ${result.category}');
    stdout.writeln('Priority: ${result.priority}');
    stdout.writeln('Department: ${result.department}');
    stdout.writeln('Suggested Title: ${result.suggestedTitle}');
    stdout.writeln('Summary: ${result.summary}');
    stdout.writeln('========================================');
  } on AiProviderException catch (e) {
    stderr.writeln('FAIL: Gemini API rejected the request.');
    if (e.statusCode != null) {
      stderr.writeln('Status Code: ${e.statusCode}');
    }
    stderr.writeln('Message: ${e.message}');
    exitCode = 2;
  } catch (e) {
    stderr.writeln(
      'FAIL: Unexpected error during live triage verification: $e',
    );
    exitCode = 3;
  }
}
