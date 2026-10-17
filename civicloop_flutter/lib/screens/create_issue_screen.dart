import 'dart:typed_data';

import 'package:civicloop_client/civicloop_client.dart';
import 'package:flutter/material.dart';

import '../client.dart';
import '../utils/claim_storage.dart';
import '../utils/custom_image_picker.dart';
import '../utils/sample_photos.dart';

/// Screen for creating and submitting a new civic issue report.
class CreateIssueScreen extends StatefulWidget {
  final VoidCallback? onIssueCreated;

  const CreateIssueScreen({super.key, this.onIssueCreated});

  @override
  State<CreateIssueScreen> createState() => _CreateIssueScreenState();
}

class _CreateIssueScreenState extends State<CreateIssueScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latController = TextEditingController();
  final _longController = TextEditingController();

  String _selectedCategory = 'Roads & Infrastructure';

  // AI Triage State
  bool _isTriaging = false;
  IssueTriageResult? _triageResult;
  String? _triageError;

  // Photo Attachment State
  SamplePhoto? _selectedSamplePhoto;
  Uint8List? _customPhotoBytes;
  String? _customPhotoFileName;
  String? _photoValidationError;
  bool _isPickingPhoto = false;

  // Submission State
  bool _isSubmitting = false;

  StaffUserInfo? _currentUserProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (client.auth.isAuthenticated) {
      try {
        final profile = await client.issue.getCurrentUserProfile();
        if (mounted) {
          setState(() {
            _currentUserProfile = profile;
          });
        }
      } catch (_) {}
    }
  }

  bool get _isStaffOrAdmin {
    if (!client.auth.isAuthenticated) return false;
    if (_currentUserProfile != null) {
      final role = _currentUserProfile!.role.toLowerCase();
      return role == 'admin' || role == 'employee';
    }
    final scopes = client.auth.authInfo?.scopeNames ?? const <String>{};
    return scopes.contains('admin') || scopes.contains('official');
  }

  static const List<String> _categories = [
    'Roads & Infrastructure',
    'Sanitation',
    'Lighting',
    'Water & Utilities',
    'Parks & Recreation',
    'Public Safety',
    'Traffic & Transit',
    'Code Enforcement',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _latController.dispose();
    _longController.dispose();
    super.dispose();
  }

  Future<void> _runAiTriage() async {
    final text = _descriptionController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter an issue description first to auto-triage.',
          ),
        ),
      );
      return;
    }

    if (text.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Description is too short for AI triage (minimum 5 characters).',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isTriaging = true;
      _triageError = null;
    });

    try {
      final result = await client.ai.triageIssue(text);
      if (mounted) {
        setState(() {
          _triageResult = result;
          _isTriaging = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _triageError = '$e';
          _isTriaging = false;
        });
      }
    }
  }

  void _applyAiSuggestions() {
    if (_triageResult == null) return;

    setState(() {
      _titleController.text = _triageResult!.suggestedTitle;
      // Match category if exists, or append
      final matchedCategory = _categories.firstWhere(
        (c) => c.toLowerCase() == _triageResult!.category.toLowerCase(),
        orElse: () => _categories.firstWhere(
          (c) =>
              c.toLowerCase().contains(_triageResult!.category.toLowerCase()) ||
              _triageResult!.category.toLowerCase().contains(c.toLowerCase()),
          orElse: () => 'Other',
        ),
      );
      _selectedCategory = matchedCategory;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Applied AI suggested title and category!')),
    );
  }

  void _fillDemoCoordinates() {
    setState(() {
      _latController.text = '37.7749';
      _longController.text = '-122.4194';
    });
  }

  Future<void> _pickCustomImage() async {
    setState(() {
      _photoValidationError = null;
      _isPickingPhoto = true;
    });

    try {
      final picked = await CustomImagePicker.pickImage();
      if (!mounted) return;
      if (picked == null) {
        setState(() => _isPickingPhoto = false);
        return;
      }

      final extError = PhotoUtils.validateExtension(picked.fileName);
      if (extError != null) {
        setState(() {
          _photoValidationError = extError;
          _isPickingPhoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(extError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      final bytesError = PhotoUtils.validateBytes(picked.bytes);
      if (bytesError != null) {
        setState(() {
          _photoValidationError = bytesError;
          _isPickingPhoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(bytesError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      setState(() {
        _selectedSamplePhoto = null; // Mutual exclusion: deselect sample
        _customPhotoBytes = picked.bytes;
        _customPhotoFileName = picked.fileName;
        _photoValidationError = null;
        _isPickingPhoto = false;
      });
    } catch (e) {
      if (!mounted) return;
      final errorMsg = 'Failed to load selected photo: $e';
      setState(() {
        _photoValidationError = errorMsg;
        _isPickingPhoto = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _removeCustomPhoto() {
    setState(() {
      _customPhotoBytes = null;
      _customPhotoFileName = null;
      _photoValidationError = null;
    });
  }

  void _removeSamplePhoto() {
    setState(() {
      _selectedSamplePhoto = null;
      _photoValidationError = null;
    });
  }

  Uint8List? get _effectivePhotoBytes {
    if (_selectedSamplePhoto != null) {
      return _selectedSamplePhoto!.bytes;
    }
    return _customPhotoBytes;
  }

  String? get _effectivePhotoFileName {
    if (_selectedSamplePhoto != null) {
      return _selectedSamplePhoto!.fileName;
    }
    return _customPhotoFileName;
  }

  Future<void> _submitIssue() async {
    if (_isStaffOrAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Staff and administrators cannot submit citizen civic reports.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    double? lat;
    double? long;
    if (_latController.text.trim().isNotEmpty) {
      lat = double.tryParse(_latController.text.trim());
      if (lat == null || lat < -90.0 || lat > 90.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Latitude must be between -90 and 90.')),
        );
        return;
      }
    }
    if (_longController.text.trim().isNotEmpty) {
      long = double.tryParse(_longController.text.trim());
      if (long == null || long < -180.0 || long > 180.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Longitude must be between -180 and 180.'),
          ),
        );
        return;
      }
    }

    final photoBytes = _effectivePhotoBytes;
    final photoFileName = _effectivePhotoFileName;

    if (photoBytes != null && photoFileName != null) {
      final extError = PhotoUtils.validateExtension(photoFileName);
      if (extError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(extError)),
        );
        return;
      }
      final bytesError = PhotoUtils.validateBytes(photoBytes);
      if (bytesError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(bytesError)),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final issueToCreate = Issue(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        status: 'open',
        createdAt: DateTime.now(),
        latitude: lat,
        longitude: long,
      );

      final created = await client.issue.createIssue(issueToCreate);

      if (created.id != null && created.claimToken != null) {
        ClaimStorage.saveClaimToken(created.id!, created.claimToken!);
      }

      // Attach photo if provided, with safe failure handling
      bool photoUploaded = false;
      String? photoError;
      if (photoBytes != null && photoFileName != null && created.id != null) {
        try {
          final byteData = PhotoUtils.toByteData(photoBytes);
          await client.issue.attachIssuePhoto(
            created.id!,
            photoFileName,
            byteData,
            uploadToken: created.uploadToken,
          );
          photoUploaded = true;
        } catch (pe) {
          photoUploaded = false;
          photoError = '$pe';
        }
      }

      if (mounted) {
        _showSuccessDialog(
          issueId: created.id ?? 0,
          hadPhoto: photoBytes != null,
          photoUploaded: photoUploaded,
          photoError: photoError,
          claimToken: created.claimToken,
        );
        _resetForm();
        widget.onIssueCreated?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit issue: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _latController.clear();
    _longController.clear();
    setState(() {
      _selectedCategory = 'Roads & Infrastructure';
      _triageResult = null;
      _triageError = null;
      _selectedSamplePhoto = null;
      _customPhotoBytes = null;
      _customPhotoFileName = null;
      _photoValidationError = null;
      _isPickingPhoto = false;
    });
  }

  void _showSuccessDialog({
    required int issueId,
    required bool hadPhoto,
    required bool photoUploaded,
    String? photoError,
    String? claimToken,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Icon(
            photoError != null
                ? Icons.warning_amber_rounded
                : Icons.check_circle,
            color: photoError != null ? Colors.amber.shade800 : Colors.green,
            size: 48,
          ),
          title: Text(
            photoError != null
                ? 'Issue Created (Photo Warning)'
                : 'Issue Submitted!',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your civic report has been persisted with ID #$issueId.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (hadPhoto && photoUploaded)
                const Text('Photo attachment successfully uploaded and linked.')
              else if (hadPhoto && !photoUploaded)
                Text(
                  'Warning: The issue was created, but the photo upload failed: $photoError',
                  style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                )
              else
                const Text('Report submitted without a photo.'),
              const SizedBox(height: 8),
              Text(
                client.auth.isAuthenticated
                    ? 'Associated with your account (${client.auth.authInfo?.authUserId.toString()}).'
                    : 'Submitted anonymously (identity protected).',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              if (claimToken != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.key,
                            size: 16,
                            color: Colors.amber.shade900,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Anonymous Claim Token',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        claimToken,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Saved locally in this session. You can use this token to confirm closure or reopen your report.',
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return Colors.red.shade700;
      case 'high':
        return Colors.deepOrange.shade700;
      case 'medium':
        return Colors.blue.shade700;
      case 'low':
        return Colors.green.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final userIdentifier = client.auth.authInfo?.authUserId.toString();

    if (_isStaffOrAdmin) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              elevation: 0,
              color: colors.errorContainer.withAlpha(40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colors.error.withAlpha(80)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 56,
                      color: colors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Citizen Submission Restricted',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Civic issue reporting is reserved exclusively for citizens and public community members. Municipal staff and administrators must manage assigned issues or oversee operations from their respective task boards.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Return to Dashboard'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Attribution indicator header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(
                    client.auth.isAuthenticated
                        ? Icons.person
                        : Icons.person_outline,
                    color: colors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      client.auth.isAuthenticated
                          ? 'Reporting as: $userIdentifier'
                          : 'Reporting as: Anonymous Citizen (No account required)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Step 1: Description
            Text(
              '1. What is the issue? (Description)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Describe the problem in detail (e.g., "A deep 3-foot pothole on Elm Street in front of the grocery store is damaging car tires and causing traffic swerving").',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter a description.';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),

            // AI Triage Assist Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: _isTriaging
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome, color: Colors.deepPurple),
                label: Text(
                  _isTriaging
                      ? 'Analyzing with Gemini 3.5 Flash Lite...'
                      : '✨ Auto-Triage with Gemini AI',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.deepPurple, width: 1.5),
                ),
                onPressed: _isTriaging ? null : _runAiTriage,
              ),
            ),
            const SizedBox(height: 10),

            // AI Triage Results Card
            if (_triageResult != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.psychology,
                              color: Colors.deepPurple,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Gemini AI Recommendations',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple.shade900,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(
                              _triageResult!.priority,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Priority: ${_triageResult!.priority.toUpperCase()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Text(
                      'Suggested Title: "${_triageResult!.suggestedTitle}"',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Category: ${_triageResult!.category}  •  Dept: ${_triageResult!.department}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.deepPurple.shade800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Summary: ${_triageResult!.summary}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.tonalIcon(
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Apply AI Title & Category'),
                      onPressed: _applyAiSuggestions,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else if (_triageError != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: colors.onErrorContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AI Triage Info: $_triageError\n(You can still fill fields and submit manually)',
                        style: TextStyle(
                          color: colors.onErrorContainer,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Step 2: Title & Category
            Text(
              '2. Issue Title & Category',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Issue Title *',
                hintText: 'e.g. Hazardous Pothole on Elm Street',
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter a title.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: ValueKey(_selectedCategory),
              initialValue: _selectedCategory,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(
                    c,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 20),

            // Step 3: Location Coordinates (Optional)
            Row(
              children: [
                Expanded(
                  child: Text(
                    '3. Location Coordinates (Optional)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.my_location, size: 16),
                  label: const Text('Demo GPS'),
                  onPressed: _fillDemoCoordinates,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Latitude (-90 to 90)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _longController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Longitude (-180 to 180)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Step 4: Photo Attachment
            Text(
              '4. Photo Attachment (Max 5 MB)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Upload your own photo or choose a pre-packaged sample photo (.jpg, .png, .webp).',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // Custom photo picker button
            OutlinedButton.icon(
              key: const Key('upload_photo_button'),
              icon: _isPickingPhoto
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.file_upload_outlined),
              label: Text(
                _isPickingPhoto ? 'Selecting image...' : 'Upload Your Photo',
              ),
              onPressed: _isPickingPhoto ? null : _pickCustomImage,
            ),
            const SizedBox(height: 14),

            Text(
              'Or choose a sample demo photo:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),

            // Sample photos selector
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PhotoUtils.samplePhotos.map((sample) {
                final isSelected = _selectedSamplePhoto?.id == sample.id;
                return ChoiceChip(
                  key: Key('sample_chip_${sample.id}'),
                  avatar: Icon(
                    isSelected ? Icons.check : Icons.photo,
                    size: 16,
                  ),
                  label: Text(sample.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSamplePhoto = sample;
                        _customPhotoBytes = null; // Mutual exclusion
                        _customPhotoFileName = null;
                        _photoValidationError = null;
                      } else {
                        _selectedSamplePhoto = null;
                      }
                    });
                  },
                );
              }).toList(),
            ),

            // Sample photo preview
            if (_selectedSamplePhoto != null) ...[
              const SizedBox(height: 12),
              Container(
                key: const Key('sample_photo_preview'),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.primary.withAlpha(100)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        _selectedSamplePhoto!.bytes,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedSamplePhoto!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${_selectedSamplePhoto!.fileName} (${PhotoUtils.formatBytes(_selectedSamplePhoto!.bytes.lengthInBytes)})',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      key: const Key('remove_sample_photo_button'),
                      icon: const Icon(Icons.close),
                      tooltip: 'Remove photo',
                      onPressed: _removeSamplePhoto,
                    ),
                  ],
                ),
              ),
            ],

            // Custom photo preview
            if (_customPhotoBytes != null) ...[
              const SizedBox(height: 12),
              Container(
                key: const Key('custom_photo_preview'),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.primary.withAlpha(100)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        _customPhotoBytes!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _customPhotoFileName ?? 'Custom Photo',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Custom Upload (${PhotoUtils.formatBytes(_customPhotoBytes!.lengthInBytes)})',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      key: const Key('remove_custom_photo_button'),
                      icon: const Icon(Icons.close),
                      tooltip: 'Remove photo',
                      onPressed: _removeCustomPhoto,
                    ),
                  ],
                ),
              ),
            ],

            if (_photoValidationError != null) ...[
              const SizedBox(height: 8),
              Container(
                key: const Key('photo_validation_error'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 16,
                      color: colors.onErrorContainer,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _photoValidationError!,
                        style: TextStyle(
                          color: colors.onErrorContainer,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  _isSubmitting
                      ? 'Submitting Issue to CivicLoop...'
                      : 'Submit Civic Issue Report',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _isSubmitting ? null : _submitIssue,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
