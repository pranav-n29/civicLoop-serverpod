import 'dart:convert';

import '../generated/protocol.dart';
import 'ai_triage_provider.dart';

/// Exception thrown when AI provider output fails validation or parsing.
class AiValidationException implements Exception {
  final String message;

  AiValidationException(this.message);

  @override
  String toString() => 'AiValidationException: $message';
}

/// Service that coordinates AI-driven civic issue triage.
class AiTriageService {
  final AiTriageProvider provider;

  static const Set<String> allowedPriorities = {
    'low',
    'medium',
    'high',
    'critical',
  };

  static const int maxDescriptionLength = 10000;
  static const int minDescriptionLength = 5;

  AiTriageService({required this.provider});

  /// Validates [description], requests triage analysis from [provider],
  /// parses and strictly validates the structured response, and returns [IssueTriageResult].
  Future<IssueTriageResult> triage(String description) async {
    final trimmedDescription = description.trim();

    if (trimmedDescription.isEmpty) {
      throw ArgumentError.value(
        description,
        'description',
        'Description cannot be empty.',
      );
    }

    if (trimmedDescription.length < minDescriptionLength) {
      throw ArgumentError.value(
        description,
        'description',
        'Description is too short to triage (minimum $minDescriptionLength characters).',
      );
    }

    if (trimmedDescription.length > maxDescriptionLength) {
      throw ArgumentError.value(
        description,
        'description',
        'Description is too long (maximum $maxDescriptionLength characters).',
      );
    }

    // Call the AI provider
    final rawResponse = await provider.generateTriageJson(trimmedDescription);

    return parseAndValidate(rawResponse);
  }

  /// Parses raw JSON string and constrains the output to a validated [IssueTriageResult].
  IssueTriageResult parseAndValidate(String rawOutput) {
    var cleaned = rawOutput.trim();

    // Strip markdown code fences if present (e.g. ```json ... ```)
    if (cleaned.startsWith('```')) {
      final lines = cleaned.split('\n');
      if (lines.first.startsWith('```')) {
        lines.removeAt(0);
      }
      if (lines.isNotEmpty && lines.last.trim() == '```') {
        lines.removeLast();
      }
      cleaned = lines.join('\n').trim();
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(cleaned);
    } on FormatException catch (e) {
      throw AiValidationException(
        'AI provider returned malformed JSON: ${e.message}',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw AiValidationException(
        'AI provider response must be a JSON object.',
      );
    }

    // Validate suggestedTitle
    final rawTitle = decoded['suggestedTitle'];
    if (rawTitle is! String || rawTitle.trim().isEmpty) {
      throw AiValidationException(
        'Missing or invalid "suggestedTitle" in AI response.',
      );
    }
    var title = rawTitle.trim();
    if (title.length > 120) {
      title = title.substring(0, 120).trim();
    }

    // Validate category
    final rawCategory = decoded['category'];
    if (rawCategory is! String || rawCategory.trim().isEmpty) {
      throw AiValidationException(
        'Missing or invalid "category" in AI response.',
      );
    }
    var category = rawCategory.trim();
    if (category.length > 80) {
      category = category.substring(0, 80).trim();
    }

    // Validate priority
    final rawPriority = decoded['priority'];
    if (rawPriority is! String || rawPriority.trim().isEmpty) {
      throw AiValidationException(
        'Missing or invalid "priority" in AI response.',
      );
    }
    final normalizedPriority = rawPriority.trim().toLowerCase();
    if (!allowedPriorities.contains(normalizedPriority)) {
      throw AiValidationException(
        'Invalid priority "$rawPriority". Must be one of: ${allowedPriorities.join(', ')}.',
      );
    }

    // Validate department
    final rawDepartment = decoded['department'];
    if (rawDepartment is! String || rawDepartment.trim().isEmpty) {
      throw AiValidationException(
        'Missing or invalid "department" in AI response.',
      );
    }
    var department = rawDepartment.trim();
    if (department.length > 100) {
      department = department.substring(0, 100).trim();
    }

    // Validate summary
    final rawSummary = decoded['summary'];
    if (rawSummary is! String || rawSummary.trim().isEmpty) {
      throw AiValidationException(
        'Missing or invalid "summary" in AI response.',
      );
    }
    var summary = rawSummary.trim();
    if (summary.length > 1000) {
      summary = summary.substring(0, 1000).trim();
    }

    return IssueTriageResult(
      suggestedTitle: title,
      category: category,
      priority: normalizedPriority,
      department: department,
      summary: summary,
    );
  }
}
