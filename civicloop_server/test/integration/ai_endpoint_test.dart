import 'dart:convert';

import 'package:civicloop_server/src/ai/ai_endpoint.dart';
import 'package:civicloop_server/src/ai/ai_triage_provider.dart';
import 'package:civicloop_server/src/ai/ai_triage_service.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given Ai endpoint', (sessionBuilder, endpoints) {
    tearDown(() {
      AiEndpoint.serviceForTesting = null;
    });

    test(
      'when no API key is configured then throws AiConfigurationException',
      () async {
        AiEndpoint.serviceForTesting = null;

        expect(
          () => endpoints.ai.triageIssue(
            sessionBuilder,
            'Major water leak on 4th street.',
          ),
          throwsA(
            isA<AiConfigurationException>().having(
              (e) => e.message,
              'message',
              contains('live AI inference is not enabled'),
            ),
          ),
        );
      },
    );

    test(
      'when test mock provider is injected then returns valid structured triage result',
      () async {
        final mockProvider = MockAiTriageProvider(
          cannedResponse: jsonEncode({
            'suggestedTitle': 'Dangerous Sinkhole on Market St',
            'category': 'Roads & Infrastructure',
            'priority': 'critical',
            'department': 'Department of Public Works',
            'summary':
                'A 5-foot sinkhole opened up in the middle of Market Street.',
          }),
        );
        AiEndpoint.serviceForTesting = AiTriageService(provider: mockProvider);

        final result = await endpoints.ai.triageIssue(
          sessionBuilder,
          'A massive sinkhole has appeared in the middle lane of Market Street.',
        );

        expect(
          result.suggestedTitle,
          equals('Dangerous Sinkhole on Market St'),
        );
        expect(result.category, equals('Roads & Infrastructure'));
        expect(result.priority, equals('critical'));
        expect(result.department, equals('Department of Public Works'));
        expect(
          result.summary,
          equals('A 5-foot sinkhole opened up in the middle of Market Street.'),
        );
      },
    );

    test(
      'when description is empty then throws ArgumentError',
      () async {
        AiEndpoint.serviceForTesting = AiTriageService(
          provider: MockAiTriageProvider(),
        );

        expect(
          () => endpoints.ai.triageIssue(
            sessionBuilder,
            '   ',
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'Description cannot be empty.',
            ),
          ),
        );
      },
    );

    test(
      'when provider fails then throws AiProviderException',
      () async {
        AiEndpoint.serviceForTesting = AiTriageService(
          provider: MockAiTriageProvider(
            errorToThrow: AiProviderException(
              'Remote API timed out',
              statusCode: 504,
            ),
          ),
        );

        expect(
          () => endpoints.ai.triageIssue(
            sessionBuilder,
            'Fallen tree branch blocking traffic.',
          ),
          throwsA(
            isA<AiProviderException>().having(
              (e) => e.message,
              'message',
              contains('timed out'),
            ),
          ),
        );
      },
    );

    test(
      'when provider returns invalid priority then throws AiValidationException',
      () async {
        AiEndpoint.serviceForTesting = AiTriageService(
          provider: MockAiTriageProvider(
            cannedResponse: jsonEncode({
              'suggestedTitle': 'Broken Streetlight',
              'category': 'Lighting',
              'priority': 'super_urgent_now',
              'department': 'Electrical',
              'summary': 'Light out.',
            }),
          ),
        );

        expect(
          () => endpoints.ai.triageIssue(
            sessionBuilder,
            'Streetlight is dead.',
          ),
          throwsA(
            isA<AiValidationException>().having(
              (e) => e.message,
              'message',
              contains('Invalid priority'),
            ),
          ),
        );
      },
    );
  });
}
