import 'dart:convert';
import 'dart:io';

import 'package:civicloop_server/src/ai/ai_endpoint.dart';
import 'package:civicloop_server/src/ai/ai_triage_provider.dart';
import 'package:civicloop_server/src/ai/ai_triage_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

class FakeServerpod implements Serverpod {
  final Map<String, String> passwords;

  FakeServerpod({this.passwords = const {}});

  @override
  String? getPassword(String key) => passwords[key];

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeSession implements Session {
  @override
  final AuthenticationInfo? authenticated;

  @override
  final Map<String, String> passwords;

  final Serverpod _serverpod;

  FakeSession({
    this.authenticated,
    this.passwords = const {},
    Serverpod? serverpod,
  }) : _serverpod = serverpod ?? FakeServerpod(passwords: passwords);

  @override
  Serverpod get serverpod => _serverpod;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('AiTriageService Input Validation', () {
    late AiTriageService service;

    setUp(() {
      service = AiTriageService(provider: MockAiTriageProvider());
    });

    test('throws ArgumentError when description is empty', () {
      expect(
        () => service.triage(''),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Description cannot be empty.',
          ),
        ),
      );
    });

    test('throws ArgumentError when description is only whitespace', () {
      expect(
        () => service.triage('   \t\n  '),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Description cannot be empty.',
          ),
        ),
      );
    });

    test('throws ArgumentError when description is shorter than 5 chars', () {
      expect(
        () => service.triage('Pot'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('too short'),
          ),
        ),
      );
    });

    test('throws ArgumentError when description exceeds maximum length', () {
      final oversized = 'a' * 10001;
      expect(
        () => service.triage(oversized),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('too long'),
          ),
        ),
      );
    });
  });

  group('AiTriageService Valid Structured Output', () {
    test('successfully parses valid JSON response', () async {
      final mockProvider = MockAiTriageProvider(
        cannedResponse: jsonEncode({
          'suggestedTitle': 'Deep Pothole on Elm Street',
          'category': 'Roads & Infrastructure',
          'priority': 'high',
          'department': 'Department of Transportation',
          'summary': 'Large pothole causing vehicle damage near Elm and 4th.',
        }),
      );

      final service = AiTriageService(provider: mockProvider);
      final result = await service.triage(
        'There is a massive pothole in front of 402 Elm St causing flat tires.',
      );

      expect(result.suggestedTitle, equals('Deep Pothole on Elm Street'));
      expect(result.category, equals('Roads & Infrastructure'));
      expect(result.priority, equals('high'));
      expect(result.department, equals('Department of Transportation'));
      expect(
        result.summary,
        equals('Large pothole causing vehicle damage near Elm and 4th.'),
      );
    });

    test('strips markdown code blocks around JSON', () async {
      final mockProvider = MockAiTriageProvider(
        cannedResponse: '''
```json
{
  "suggestedTitle": "Broken Water Pipe",
  "category": "Water & Utilities",
  "priority": "critical",
  "department": "Water Authority",
  "summary": "Water shooting into the street."
}
```
''',
      );

      final service = AiTriageService(provider: mockProvider);
      final result = await service.triage(
        'Water main broke and flooding the corner of 5th and Main.',
      );

      expect(result.suggestedTitle, equals('Broken Water Pipe'));
      expect(result.priority, equals('critical'));
    });

    test('normalizes priority case correctly', () async {
      for (final p in ['LOW', 'Low', 'MEDIUM', 'Medium', 'HIGH', 'CRITICAL']) {
        final mockProvider = MockAiTriageProvider(
          cannedResponse: jsonEncode({
            'suggestedTitle': 'Test Issue',
            'category': 'General',
            'priority': p,
            'department': 'Public Works',
            'summary': 'Summary',
          }),
        );

        final service = AiTriageService(provider: mockProvider);
        final result = await service.triage('Testing priority normalization.');
        expect(result.priority, equals(p.toLowerCase()));
      }
    });

    test('constrains overly long fields to safe bounds', () async {
      final longTitle = 'T' * 200;
      final longCategory = 'C' * 150;
      final longDept = 'D' * 200;
      final longSummary = 'S' * 2000;

      final mockProvider = MockAiTriageProvider(
        cannedResponse: jsonEncode({
          'suggestedTitle': longTitle,
          'category': longCategory,
          'priority': 'low',
          'department': longDept,
          'summary': longSummary,
        }),
      );

      final service = AiTriageService(provider: mockProvider);
      final result = await service.triage('A long test input description.');

      expect(result.suggestedTitle.length, lessThanOrEqualTo(120));
      expect(result.category.length, lessThanOrEqualTo(80));
      expect(result.department.length, lessThanOrEqualTo(100));
      expect(result.summary.length, lessThanOrEqualTo(1000));
    });
  });

  group('AiTriageService Malformed Output Handling', () {
    test('throws AiValidationException on unparseable JSON', () {
      final service = AiTriageService(
        provider: MockAiTriageProvider(
          cannedResponse: 'This is not json at all',
        ),
      );

      expect(
        () => service.triage('Pothole on Main St'),
        throwsA(
          isA<AiValidationException>().having(
            (e) => e.message,
            'message',
            contains('malformed JSON'),
          ),
        ),
      );
    });

    test('throws AiValidationException when response is JSON array', () {
      final service = AiTriageService(
        provider: MockAiTriageProvider(cannedResponse: '[]'),
      );

      expect(
        () => service.triage('Pothole on Main St'),
        throwsA(
          isA<AiValidationException>().having(
            (e) => e.message,
            'message',
            contains('must be a JSON object'),
          ),
        ),
      );
    });

    test('throws AiValidationException when missing suggestedTitle', () {
      final service = AiTriageService(
        provider: MockAiTriageProvider(
          cannedResponse: jsonEncode({
            'category': 'Roads',
            'priority': 'medium',
            'department': 'Public Works',
            'summary': 'Summary',
          }),
        ),
      );

      expect(
        () => service.triage('Pothole on Main St'),
        throwsA(
          isA<AiValidationException>().having(
            (e) => e.message,
            'message',
            contains('suggestedTitle'),
          ),
        ),
      );
    });

    test('throws AiValidationException when suggestedTitle is empty', () {
      final service = AiTriageService(
        provider: MockAiTriageProvider(
          cannedResponse: jsonEncode({
            'suggestedTitle': '   ',
            'category': 'Roads',
            'priority': 'medium',
            'department': 'Public Works',
            'summary': 'Summary',
          }),
        ),
      );

      expect(
        () => service.triage('Pothole on Main St'),
        throwsA(
          isA<AiValidationException>().having(
            (e) => e.message,
            'message',
            contains('suggestedTitle'),
          ),
        ),
      );
    });

    test('throws AiValidationException when missing category', () {
      final service = AiTriageService(
        provider: MockAiTriageProvider(
          cannedResponse: jsonEncode({
            'suggestedTitle': 'Title',
            'priority': 'medium',
            'department': 'Public Works',
            'summary': 'Summary',
          }),
        ),
      );

      expect(
        () => service.triage('Pothole on Main St'),
        throwsA(
          isA<AiValidationException>().having(
            (e) => e.message,
            'message',
            contains('category'),
          ),
        ),
      );
    });

    test('throws AiValidationException when missing priority', () {
      final service = AiTriageService(
        provider: MockAiTriageProvider(
          cannedResponse: jsonEncode({
            'suggestedTitle': 'Title',
            'category': 'Roads',
            'department': 'Public Works',
            'summary': 'Summary',
          }),
        ),
      );

      expect(
        () => service.triage('Pothole on Main St'),
        throwsA(
          isA<AiValidationException>().having(
            (e) => e.message,
            'message',
            contains('priority'),
          ),
        ),
      );
    });

    test('throws AiValidationException on invalid priority value', () {
      final service = AiTriageService(
        provider: MockAiTriageProvider(
          cannedResponse: jsonEncode({
            'suggestedTitle': 'Title',
            'category': 'Roads',
            'priority': 'extreme_urgency',
            'department': 'Public Works',
            'summary': 'Summary',
          }),
        ),
      );

      expect(
        () => service.triage('Pothole on Main St'),
        throwsA(
          isA<AiValidationException>().having(
            (e) => e.message,
            'message',
            contains('Invalid priority'),
          ),
        ),
      );
    });

    test('throws AiValidationException when missing department', () {
      final service = AiTriageService(
        provider: MockAiTriageProvider(
          cannedResponse: jsonEncode({
            'suggestedTitle': 'Title',
            'category': 'Roads',
            'priority': 'medium',
            'summary': 'Summary',
          }),
        ),
      );

      expect(
        () => service.triage('Pothole on Main St'),
        throwsA(
          isA<AiValidationException>().having(
            (e) => e.message,
            'message',
            contains('department'),
          ),
        ),
      );
    });

    test('throws AiValidationException when missing summary', () {
      final service = AiTriageService(
        provider: MockAiTriageProvider(
          cannedResponse: jsonEncode({
            'suggestedTitle': 'Title',
            'category': 'Roads',
            'priority': 'medium',
            'department': 'Public Works',
          }),
        ),
      );

      expect(
        () => service.triage('Pothole on Main St'),
        throwsA(
          isA<AiValidationException>().having(
            (e) => e.message,
            'message',
            contains('summary'),
          ),
        ),
      );
    });
  });

  group('AiTriageService Provider Errors', () {
    test('propagates AiProviderException from provider', () {
      final service = AiTriageService(
        provider: MockAiTriageProvider(
          errorToThrow: AiProviderException(
            'Upstream rate limit',
            statusCode: 429,
          ),
        ),
      );

      expect(
        () => service.triage('Pothole on Main St'),
        throwsA(
          isA<AiProviderException>()
              .having((e) => e.message, 'message', contains('rate limit'))
              .having((e) => e.statusCode, 'statusCode', 429),
        ),
      );
    });
  });

  group('GeminiTriageProvider Request Construction', () {
    test('uses gemini-3.5-flash-lite as defaultModel constant', () {
      expect(
        GeminiTriageProvider.defaultModel,
        equals('gemini-3.5-flash-lite'),
      );
    });

    test(
      'buildEndpointUri uses default model gemini-3.5-flash-lite without key in URL by default',
      () {
        final provider = GeminiTriageProvider(apiKey: 'secret_test_key_123');
        final uri = provider.buildEndpointUri();

        expect(uri.scheme, equals('https'));
        expect(uri.host, equals('generativelanguage.googleapis.com'));
        expect(
          uri.path,
          equals('/v1beta/models/gemini-3.5-flash-lite:generateContent'),
        );
        expect(uri.queryParameters.containsKey('key'), isFalse);
      },
    );

    test(
      'buildEndpointUri includes key in query params when useHeaderAuth is false',
      () {
        final provider = GeminiTriageProvider(
          apiKey: 'secret_test_key_123',
          useHeaderAuth: false,
        );
        final uri = provider.buildEndpointUri();

        expect(uri.queryParameters['key'], equals('secret_test_key_123'));
      },
    );

    test('buildEndpointUri respects configurable modelName', () {
      final provider = GeminiTriageProvider(
        apiKey: 'secret_test_key_123',
        modelName: 'custom-model-name',
      );
      final uri = provider.buildEndpointUri();

      expect(
        uri.path,
        equals('/v1beta/models/custom-model-name:generateContent'),
      );
      expect(provider.modelName, equals('custom-model-name'));
    });

    test('buildEndpointUri uses customEndpointUri when supplied', () {
      final customUri = Uri.parse('http://localhost:8080/custom-gemini');
      final provider = GeminiTriageProvider(
        apiKey: 'secret_test_key_123',
        customEndpointUri: customUri,
      );

      expect(provider.buildEndpointUri(), equals(customUri));
    });

    test(
      'buildRequestBody constructs structured prompt with JSON responseMimeType',
      () {
        final provider = GeminiTriageProvider(apiKey: 'secret_test_key_123');
        final body = provider.buildRequestBody(
          'Deep trench dug across 7th street',
        );

        expect(body, contains('contents'));
        final contents = body['contents'] as List;
        expect(contents.length, equals(1));
        final firstContent = contents.first as Map;
        expect(firstContent['role'], equals('user'));

        final parts = firstContent['parts'] as List;
        final partText = (parts.first as Map)['text'] as String;
        expect(partText, contains('Deep trench dug across 7th street'));
        expect(partText, contains('untrusted citizen report data'));
        expect(partText, contains('"suggestedTitle"'));
        expect(partText, contains('"priority"'));

        expect(body, contains('generationConfig'));
        final config = body['generationConfig'] as Map;
        expect(config['responseMimeType'], equals('application/json'));
        expect(config['temperature'], equals(0.2));
      },
    );
  });

  group('GeminiTriageProvider Response Parsing', () {
    final provider = GeminiTriageProvider(apiKey: 'secret_test_key_123');

    test('successfully extracts text from valid candidate JSON', () {
      final validGeminiResponse = jsonEncode({
        'candidates': [
          {
            'content': {
              'parts': [
                {
                  'text': jsonEncode({
                    'suggestedTitle': 'Streetlight Flickering',
                    'category': 'Lighting',
                    'priority': 'low',
                    'department': 'Public Works',
                    'summary': 'Streetlight needs bulb replacement.',
                  }),
                },
              ],
            },
          },
        ],
      });

      final parsedText = provider.parseResponseJson(validGeminiResponse);
      final decoded = jsonDecode(parsedText);
      expect(decoded['suggestedTitle'], equals('Streetlight Flickering'));
      expect(decoded['priority'], equals('low'));
    });

    test(
      'throws AiProviderException on non-200 HTTP status with error message',
      () {
        final errorResponse = jsonEncode({
          'error': {
            'code': 400,
            'message': 'API key not valid. Please pass a valid API key.',
            'status': 'INVALID_ARGUMENT',
          },
        });

        expect(
          () => provider.parseResponseJson(
            errorResponse,
            statusCode: HttpStatus.badRequest,
          ),
          throwsA(
            isA<AiProviderException>()
                .having(
                  (e) => e.statusCode,
                  'statusCode',
                  HttpStatus.badRequest,
                )
                .having(
                  (e) => e.message,
                  'message',
                  contains('API key not valid'),
                ),
          ),
        );
      },
    );

    test('throws AiProviderException when response is not a JSON object', () {
      expect(
        () => provider.parseResponseJson('["not", "a", "map"]'),
        throwsA(
          isA<AiProviderException>().having(
            (e) => e.message,
            'message',
            contains('Invalid response format'),
          ),
        ),
      );
    });

    test('throws AiProviderException when candidates list is empty', () {
      final noCandidatesResponse = jsonEncode({
        'candidates': [],
        'promptFeedback': {'blockReason': 'SAFETY'},
      });

      expect(
        () => provider.parseResponseJson(noCandidatesResponse),
        throwsA(
          isA<AiProviderException>().having(
            (e) => e.message,
            'message',
            contains('Gemini returned no candidates'),
          ),
        ),
      );
    });

    test(
      'throws AiProviderException when candidate content parts are missing',
      () {
        final malformedResponse = jsonEncode({
          'candidates': [
            {
              'content': {'parts': []},
            },
          ],
        });

        expect(
          () => provider.parseResponseJson(malformedResponse),
          throwsA(
            isA<AiProviderException>().having(
              (e) => e.message,
              'message',
              contains('Missing parts'),
            ),
          ),
        );
      },
    );

    test('throws AiProviderException when text in candidate is empty', () {
      final emptyTextResponse = jsonEncode({
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': '   '},
              ],
            },
          },
        ],
      });

      expect(
        () => provider.parseResponseJson(emptyTextResponse),
        throwsA(
          isA<AiProviderException>().having(
            (e) => e.message,
            'message',
            contains('Empty response text'),
          ),
        ),
      );
    });
    test(
      'redacts sensitive API key and key params from exception messages',
      () {
        final keyProvider = GeminiTriageProvider(apiKey: 'secret_abc_12345');
        final errorResponse = jsonEncode({
          'error': {
            'code': 400,
            'message':
                'Failed request with secret_abc_12345 and key=secret_abc_12345',
          },
        });

        expect(
          () => keyProvider.parseResponseJson(
            errorResponse,
            statusCode: HttpStatus.badRequest,
          ),
          throwsA(
            isA<AiProviderException>().having(
              (e) => e.message,
              'message',
              allOf(
                contains('[REDACTED_API_KEY]'),
                isNot(contains('secret_abc_12345')),
              ),
            ),
          ),
        );
      },
    );
  });

  group('GeminiTriageProvider Loopback HTTP Execution', () {
    test(
      'executes request through local HTTP server and parses response without live internet call',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

        server.listen((HttpRequest request) async {
          expect(request.method, equals('POST'));
          expect(
            request.uri.path,
            equals('/v1beta/models/gemini-3.5-flash-lite:generateContent'),
          );
          expect(request.headers.value('x-goog-api-key'), equals('test-key'));
          expect(request.uri.queryParameters.containsKey('key'), isFalse);
          expect(
            request.headers.contentType?.mimeType,
            equals('application/json'),
          );

          final bodyString = await utf8.decodeStream(request);
          final bodyJson = jsonDecode(bodyString) as Map;
          expect(
            bodyJson['generationConfig']['responseMimeType'],
            equals('application/json'),
          );

          request.response.statusCode = HttpStatus.ok;
          request.response.headers.contentType = ContentType.json;
          request.response.write(
            jsonEncode({
              'candidates': [
                {
                  'content': {
                    'parts': [
                      {
                        'text': jsonEncode({
                          'suggestedTitle': 'Broken Water Valve',
                          'category': 'Water & Utilities',
                          'priority': 'high',
                          'department': 'Water Department',
                          'summary': 'Water spraying onto roadway.',
                        }),
                      },
                    ],
                  },
                },
              ],
            }),
          );
          await request.response.close();
        });

        final loopbackUri = Uri.parse(
          'http://${server.address.host}:${server.port}/v1beta/models/gemini-3.5-flash-lite:generateContent',
        );

        final provider = GeminiTriageProvider(
          apiKey: 'test-key',
          customEndpointUri: loopbackUri,
        );

        try {
          final resultJson = await provider.generateTriageJson(
            'Water spraying from street valve',
          );
          final decoded = jsonDecode(resultJson);
          expect(decoded['suggestedTitle'], equals('Broken Water Valve'));
          expect(decoded['priority'], equals('high'));
        } finally {
          await server.close(force: true);
        }
      },
    );
  });

  group('AiEndpoint Credentials & Configuration', () {
    test(
      'throws AiConfigurationException when no API key configured',
      () async {
        final endpoint = AiEndpoint();
        AiEndpoint.serviceForTesting = null;
        final emptySession = FakeSession(passwords: {});

        expect(
          () => endpoint.triageIssue(
            emptySession,
            'Graffiti on the library wall.',
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

    test('uses injected testing service when available', () async {
      final endpoint = AiEndpoint();
      final mockProvider = MockAiTriageProvider(
        cannedResponse: jsonEncode({
          'suggestedTitle': 'Injected Service Title',
          'category': 'Vandalism',
          'priority': 'low',
          'department': 'Facilities',
          'summary': 'Spray paint on public property.',
        }),
      );
      AiEndpoint.setServiceForTesting(AiTriageService(provider: mockProvider));

      final emptySession = FakeSession();
      final result = await endpoint.triageIssue(
        emptySession,
        'Graffiti on the library wall.',
      );

      expect(result.suggestedTitle, equals('Injected Service Title'));
      expect(result.priority, equals('low'));

      // Clean up static test hook
      AiEndpoint.serviceForTesting = null;
    });

    test(
      'resolves configurable modelName from session passwords or defaults to gemini-3.5-flash-lite',
      () {
        // Session with API key and custom model
        final sessionWithCustomModel = FakeSession(
          passwords: {
            'geminiApiKey': 'fake-key',
            'geminiModel': 'gemini-3.5-flash-custom',
          },
        );

        final serviceCustom = AiEndpoint.createService(sessionWithCustomModel);
        expect(
          (serviceCustom.provider as GeminiTriageProvider).modelName,
          equals('gemini-3.5-flash-custom'),
        );

        // Session with API key and default model (no geminiModel specified)
        final sessionWithDefaultModel = FakeSession(
          passwords: {
            'geminiApiKey': 'fake-key',
          },
        );

        final serviceDefault = AiEndpoint.createService(
          sessionWithDefaultModel,
        );
        expect(
          (serviceDefault.provider as GeminiTriageProvider).modelName,
          equals(GeminiTriageProvider.defaultModel),
        );
        expect(
          (serviceDefault.provider as GeminiTriageProvider).modelName,
          equals('gemini-3.5-flash-lite'),
        );
      },
    );
  });
}
