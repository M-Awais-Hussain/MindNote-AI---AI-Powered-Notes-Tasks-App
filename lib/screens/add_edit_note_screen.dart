import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../models/note.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../services/ai_assistant_service.dart';

import '../services/voice_service.dart';
import '../services/notification_service.dart';
import 'dart:convert';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();

  List<String> _tags = [];
  bool _isLoading = false;
  bool _isAILoading = false;
  bool _isListening = false;
  String? _aiSummary;
  final VoiceService _voiceService = VoiceService();

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_onContentChanged);
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _tags = List.from(widget.note!.tags);
      _aiSummary = widget.note!.aiSummary;
      _contentController.text = _parseContent(widget.note!.content);
    }
  }

  void _onContentChanged() {
    setState(() {});
  }

  String _parseContent(String content) {
    // Attempt to parse existing JSON content (migration from Quill)
    try {
      final json = jsonDecode(content);
      if (json is List) {
        // It's likely a Quill Delta, extract plain text relative approximation
        // Since we removed Quill, we can't use Document.fromJson.
        // We'll just try to pull 'insert' keys if possible or just return raw string if not feasible.
        // For simplicity in this removal task, we might fall back to the raw string if parsing fails or return empty.
        // Or if we want to be nicer, we could try to extract text manually.
        final buffer = StringBuffer();
        for (var item in json) {
          if (item is Map && item.containsKey('insert')) {
            buffer.write(item['insert']);
          }
        }
        return buffer.toString();
      }
      return content;
    } catch (e) {
      // Not JSON, assume plain text
      return content;
    }
  }

  @override
  void dispose() {
    _contentController.removeListener(_onContentChanged);
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
        actions: [
          _buildVoiceButton(),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleField(),
              const SizedBox(height: AppConstants.paddingLarge),
              _buildContentField(),
              const SizedBox(height: AppConstants.paddingMedium),
              _buildAIActions(),
              if (_aiSummary != null) ...[
                const SizedBox(height: AppConstants.paddingMedium),
                _buildAISummarySection(),
              ],
              const SizedBox(height: AppConstants.paddingLarge),
              _buildTagsSection(),
              const SizedBox(height: AppConstants.paddingXLarge),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Note Title',
        hintText: 'Enter note title',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a note title';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildContentField() {
    return TextFormField(
      controller: _contentController,
      maxLines: null,
      minLines: 10,
      decoration: const InputDecoration(
        labelText: 'Note Content',
        hintText: 'Start typing your note...',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      onChanged: (value) {
        // Force rebuild to update AI button states
        print(
            'Content changed: isEmpty=${value.isEmpty}, length=${value.length}');
        setState(() {});
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter note content';
        }
        return null;
      },
    );
  }

  Widget _buildAIActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Assistant',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _summarizeNote,
                icon: const Icon(Icons.summarize, size: 18),
                label: const Text('Summarize'),
              ),
            ),
            const SizedBox(width: AppConstants.paddingSmall),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _enhanceNote,
                icon: const Icon(Icons.auto_fix_high, size: 18),
                label: const Text('Enhance'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _checkAndSetReminder,
                icon: const Icon(Icons.notifications_active, size: 18),
                label: const Text('Set Reminder'),
              ),
            ),
            const SizedBox(width: AppConstants.paddingSmall),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _formatVoiceNote,
                icon: const Icon(Icons.graphic_eq, size: 18),
                label: const Text('Format Voice'),
              ),
            ),
          ],
        ),
        if (_isAILoading)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: LinearProgressIndicator(),
          ),
        if (_isListening)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Icon(Icons.mic, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text('Listening...', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildVoiceButton() {
    return IconButton(
      icon: _isListening
          ? const Icon(Icons.stop_circle, color: Colors.red)
          : const Icon(Icons.mic),
      onPressed: _toggleListening,
      tooltip: _isListening ? 'Stop Recording' : 'Start Voice Note',
    );
  }

  String _contentBeforeVoice = '';

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _voiceService.stopListening((isListening) {
        setState(() => _isListening = isListening);
        // Automatically offer to format after stopping
        if (!isListening && _contentController.text.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Recording stopped. Format with AI?'),
              action: SnackBarAction(
                label: 'Format',
                onPressed: _formatVoiceNote,
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      });
    } else {
      // Store the content before voice recording starts
      _contentBeforeVoice = _contentController.text;

      // Show loading indicator while initializing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Initializing voice recognition...'),
          duration: Duration(seconds: 1),
        ),
      );

      await _voiceService.startListening(
        onResult: (text) {
          if (text.isNotEmpty) {
            setState(() {
              // Replace with pre-voice content plus the latest recognized words
              // This prevents duplicate appending of partial results
              _contentController.text = _contentBeforeVoice.isEmpty
                  ? text
                  : '$_contentBeforeVoice $text';
              // Move cursor to end
              _contentController.selection = TextSelection.fromPosition(
                TextPosition(offset: _contentController.text.length),
              );
            });
          }
        },
        onListeningStateChanged: (isListening) {
          setState(() => _isListening = isListening);
          if (!isListening && _voiceService.lastRecognizedWords.isEmpty) {
            // Voice service failed to start - likely permission denied or not available
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Voice recognition not available. Please grant microphone permission in Settings.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
      );

      // Check if listening actually started
      if (!_voiceService.isListening && !_isListening) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Could not start voice recognition. Check microphone permissions.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildAISummarySection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI Summary',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () => setState(() => _aiSummary = null),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(_aiSummary!, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  hintText: 'Add a tag',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: _addTag,
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(width: AppConstants.paddingSmall),
            ElevatedButton(
              onPressed: () => _addTag(_tagController.text),
              child: const Text('Add'),
            ),
            const SizedBox(width: AppConstants.paddingSmall),
            IconButton(
              onPressed: _isAILoading ? null : _autoTag,
              icon: const Icon(
                Icons.auto_awesome,
                color: AppConstants.accentColor,
              ),
              tooltip: 'Auto Tag',
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: AppConstants.paddingMedium),
          Wrap(
            spacing: AppConstants.paddingSmall,
            runSpacing: AppConstants.paddingSmall,
            children: _tags.map((tag) {
              return Chip(
                label: Text(tag),
                onDeleted: () => _removeTag(tag),
                deleteIcon: const Icon(Icons.close, size: 18),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveNote,
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(widget.note == null ? 'Add Note' : 'Update Note'),
      ),
    );
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !_tags.contains(trimmedTag)) {
      setState(() {
        _tags.add(trimmedTag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _summarizeNote() async {
    setState(() {
      _isAILoading = true;
    });

    try {
      if (widget.note != null) {
        await context.read<NoteProvider>().summarizeNote(widget.note!.id);
        final updatedNote = context.read<NoteProvider>().allNotes.firstWhere(
              (n) => n.id == widget.note!.id,
            );
        setState(() {
          _aiSummary = updatedNote.aiSummary;
        });
      } else {
        final aiService = AIAssistantService();
        final text = _contentController.text;
        final summary = await aiService.summarizeNote(text);
        setState(() {
          _aiSummary = summary;
        });
      }
    } catch (e) {
      AppHelpers.showSnackBar(
        context,
        'AI Error: $e',
        backgroundColor: AppConstants.errorColor,
      );
    } finally {
      setState(() {
        _isAILoading = false;
      });
    }
  }

  Future<void> _enhanceNote() async {
    setState(() {
      _isAILoading = true;
    });

    try {
      final aiService = AIAssistantService();
      final text = _contentController.text;
      final enhanced = await aiService.enhanceNote(text);
      setState(() {
        _contentController.text = enhanced;
        AppHelpers.showSnackBar(
          context,
          'Note enhanced by AI',
          backgroundColor: AppConstants.successColor,
        );
      });
    } catch (e) {
      AppHelpers.showSnackBar(
        context,
        'AI Error: $e',
        backgroundColor: AppConstants.errorColor,
      );
    } finally {
      setState(() {
        _isAILoading = false;
      });
    }
  }

  Future<void> _autoTag() async {
    setState(() {
      _isAILoading = true;
    });

    try {
      final noteProvider = context.read<NoteProvider>();
      final text = _contentController.text;
      final tags = await noteProvider.suggestTags(text);

      setState(() {
        for (final tag in tags) {
          if (!_tags.contains(tag)) {
            _tags.add(tag);
          }
        }
        AppHelpers.showSnackBar(
          context,
          'AI suggested ${tags.length} tags',
          backgroundColor: AppConstants.successColor,
        );
      });
    } catch (e) {
      AppHelpers.showSnackBar(
        context,
        'AI Error: $e',
        backgroundColor: AppConstants.errorColor,
      );
    } finally {
      setState(() {
        _isAILoading = false;
      });
    }
  }

  Future<void> _checkAndSetReminder() async {
    setState(() {
      _isAILoading = true;
    });

    try {
      final aiService = AIAssistantService();
      final text = _contentController.text;
      final reminderTime = await aiService.parseReminderDateTime(text);

      if (reminderTime != null) {
        if (reminderTime.isBefore(DateTime.now())) {
          AppHelpers.showSnackBar(
            context,
            'Found date, but it\'s in the past: ${AppHelpers.formatDate(reminderTime)}',
            backgroundColor: Colors.orange,
          );
          return;
        }

        final notificationService = NotificationService();
        // Use a simple hash code for ID for now, in a real app use a proper ID system
        final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final previewText =
            text.length > 50 ? '${text.substring(0, 47)}...' : text;

        await notificationService.scheduleNotification(
          id: id,
          title:
              'Reminder: ${_titleController.text.isNotEmpty ? _titleController.text : "Note Reminder"}',
          body: previewText,
          scheduledDate: reminderTime,
        );

        AppHelpers.showSnackBar(
          context,
          'Reminder set for ${AppHelpers.formatDate(reminderTime)}',
          backgroundColor: AppConstants.successColor,
        );
      } else {
        AppHelpers.showSnackBar(
          context,
          'No date/time found in note content',
          backgroundColor: Colors.orange,
        );
      }
    } catch (e) {
      AppHelpers.showSnackBar(
        context,
        'Error setting reminder: $e',
        backgroundColor: AppConstants.errorColor,
      );
    } finally {
      setState(() {
        _isAILoading = false;
      });
    }
  }

  Future<void> _formatVoiceNote() async {
    setState(() {
      _isAILoading = true;
    });

    try {
      final aiService = AIAssistantService();
      final text = _contentController.text;
      final formatted = await aiService.formatVoiceNote(text);

      setState(() {
        _contentController.text = formatted;
      });
      if (mounted) {
        AppHelpers.showSnackBar(
          context,
          'Voice note formatted by AI',
          backgroundColor: AppConstants.successColor,
        );
      }
    } catch (e) {
      AppHelpers.showSnackBar(
        context,
        'AI Error: $e',
        backgroundColor: AppConstants.errorColor,
      );
    } finally {
      setState(() {
        _isAILoading = false;
      });
    }
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final noteProvider = context.read<NoteProvider>();
      final now = DateTime.now();
      final content = _contentController.text;

      if (widget.note == null) {
        // Add new note
        final newNote = Note(
          id: AppHelpers.generateId(),
          title: _titleController.text.trim(),
          content: content,
          tags: _tags,
          createdAt: now,
          updatedAt: now,
          aiSummary: _aiSummary,
        );

        noteProvider.addNote(newNote);
        AppHelpers.showSnackBar(
          context,
          'Note added successfully',
          backgroundColor: AppConstants.successColor,
        );
      } else {
        // Update existing note
        final updatedNote = widget.note!.copyWith(
          title: _titleController.text.trim(),
          content: content,
          tags: _tags,
          updatedAt: now,
          aiSummary: _aiSummary,
        );

        noteProvider.updateNote(updatedNote);
        AppHelpers.showSnackBar(
          context,
          'Note updated successfully',
          backgroundColor: AppConstants.successColor,
        );
      }

      Navigator.of(context).pop();
    } catch (e) {
      AppHelpers.showSnackBar(
        context,
        'Error saving note: $e',
        backgroundColor: AppConstants.errorColor,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
