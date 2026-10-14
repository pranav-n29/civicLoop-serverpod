// ignore_for_file: avoid_print
import 'dart:io';

import 'package:civicloop_server/src/ai/ai_triage_provider.dart';
import 'package:civicloop_server/src/ai/ai_triage_service.dart';
import 'package:test/test.dart';

void main() {
  final isLiveEnabled = Platform.environment['RUN_LIVE_GEMINI_TEST'] == 'true';

  group('Live Gemini API Verification (Opt-In)', () {
    test(
      'executes exactly one live request to verify Gemini API model and triage parsing',
      () async {
        final apiKey = Platform.environment['GEMINI_API_KEY'];
        if (apiKey == null || apiKey.trim().isEmpty) {
          fail(
            'FAIL: GEMINI_API_KEY environment variable is not set. '
            'To run this live test, provide a valid API key in GEMINI_API_KEY.',
          );
        }

        final modelName =
            Platform.environment['GEMINI_MODEL'] ??
            GeminiTriageProvider.defaultModel;

        final provider = GeminiTriageProvider(
          apiKey: apiKey.trim(),
          modelName: modelName.trim(),
          useHeaderAuth: true,
        );

        final service = AiTriageService(provider: provider);

        const sampleDescription =
            'A large pothole is causing traffic problems on the main road.';

        try {
          // Exactly one live request
          final result = await service.triage(sampleDescription);

          expect(result.suggestedTitle.trim(), isNotEmpty);
          expect(result.category.trim(), isNotEmpty);
          expect(
            result.priority,
            isIn(['low', 'medium', 'high', 'critical']),
          );
          expect(result.department.trim(), isNotEmpty);
          expect(result.summary.trim(), isNotEmpty);

          // Output ONLY pass status and non-sensitive triage metadata
          print('========================================');
          print('LIVE GEMINI API VERIFICATION: PASS');
          print('Model: $modelName');
          print('Category: ${result.category}');
          print('Priority: ${result.priority}');
          print('Department: ${result.department}');
          print('Suggested Title: ${result.suggestedTitle}');
          print('========================================');
        } on AiProviderException catch (e) {
          // Sensitive details (e.g. API keys) are already redacted by provider
          fail(
            'FAIL: Gemini API rejected the request.\n'
            'Status Code: ${e.statusCode ?? 'unknown'}\n'
            'Message: ${e.message}\n'
            'Verify that model "$modelName" is available and your API key is valid.',
          );
        } catch (e) {
          fail('FAIL: Unexpected error during live triage verification: $e');
        }
      },
      skip: !isLiveEnabled
          ? 'Skipped: Opt-in live test requires RUN_LIVE_GEMINI_TEST=true and GEMINI_API_KEY.'
          : false,
    );
  });
}
