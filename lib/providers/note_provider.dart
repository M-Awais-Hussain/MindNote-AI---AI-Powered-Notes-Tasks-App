import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/database_service.dart';
import '../services/ai_assistant_service.dart';

class NoteProvider with ChangeNotifier {
  final List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  String _searchQuery = '';
  final DatabaseService _dbService = DatabaseService();
  final AIAssistantService _aiService = AIAssistantService();
  bool _isLoading = false;
  List<String> _relatedNoteIds = [];
  bool _isRelatedLoading = false;

  NoteProvider() {
    _loadNotes();
  }

  List<Note> get notes => _filteredNotes;
  List<Note> get allNotes => _notes;
  List<String> get relatedNoteIds => _relatedNoteIds;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isRelatedLoading => _isRelatedLoading;

  Future<void> _loadNotes() async {
    _isLoading = true;
    notifyListeners();
    _notes.clear();
    _notes.addAll(await _dbService.getNotes());
    _applyFilters();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    await _dbService.insertNote(note);
    _notes.add(note);
    _applyFilters();
    notifyListeners();
  }

  Future<void> updateNote(Note updatedNote) async {
    final index = _notes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      await _dbService.updateNote(updatedNote);
      _notes[index] = updatedNote;
      _applyFilters();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String noteId) async {
    await _dbService.deleteNote(noteId);
    _notes.removeWhere((note) => note.id == noteId);
    _applyFilters();
    notifyListeners();
  }

  // AI Features
  Future<void> summarizeNote(String noteId) async {
    final index = _notes.indexWhere((note) => note.id == noteId);
    if (index != -1) {
      _isLoading = true;
      notifyListeners();
      try {
        final summary = await _aiService.summarizeNote(_notes[index].content);
        final updatedNote = _notes[index].copyWith(aiSummary: summary);
        await updateNote(updatedNote);
      } catch (e) {
        debugPrint('AI Error: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> enhanceNote(String noteId) async {
    final index = _notes.indexWhere((note) => note.id == noteId);
    if (index != -1) {
      _isLoading = true;
      notifyListeners();
      try {
        final enhanced = await _aiService.enhanceNote(_notes[index].content);
        final updatedNote = _notes[index].copyWith(
          content: enhanced,
          isAIEnhanced: true,
          updatedAt: DateTime.now(),
        );
        await updateNote(updatedNote);
      } catch (e) {
        debugPrint('AI Error: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<List<String>> suggestTags(String content) async {
    try {
      return await _aiService.suggestTags(content);
    } catch (e) {
      debugPrint('AI Error: $e');
      return [];
    }
  }

  Future<void> performAISearch(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      final resultMap = await _aiService.analyzeSearchQuery(query);
      final keywords = List<String>.from(resultMap['keywords'] ?? []);
      // final priority = resultMap['priority']; // Notes don't have priority yet, but good for future
      // final type = resultMap['type'];

      _filteredNotes = _notes.where((note) {
        final contentLower = note.content.toLowerCase();
        final titleLower = note.title.toLowerCase();

        // Simple heuristic: match any keyword
        return keywords.any((keyword) {
          final k = keyword.toLowerCase();
          return contentLower.contains(k) || titleLower.contains(k);
        });
      }).toList();

      // Fallback: if AI keywords match nothing, try the exact query
      if (_filteredNotes.isEmpty) {
        setSearchQuery(query);
      }
    } catch (e) {
      debugPrint('AI Search Error: $e');
      setSearchQuery(query); // Fallback to normal search
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRelatedNotes(String currentNoteId) async {
    final currentNote = _notes.firstWhere(
      (n) => n.id == currentNoteId,
      orElse: () => Note(
        id: '',
        title: '',
        content: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: [],
      ),
    );
    if (currentNote.id.isEmpty) return;

    _isRelatedLoading = true;
    notifyListeners();

    try {
      final otherNotes = {
        for (var n in _notes.where((n) => n.id != currentNoteId))
          n.id: n.content,
      };

      _relatedNoteIds = await _aiService.findRelatedNotes(
        currentNote.content,
        otherNotes,
      );
    } catch (e) {
      debugPrint('AI Related Notes Error: $e');
      _relatedNoteIds = [];
    } finally {
      _isRelatedLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredNotes = _notes.where((note) {
      return _searchQuery.isEmpty ||
          note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.tags.any(
            (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()),
          );
    }).toList();

    _filteredNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  List<String> getAllTags() {
    final allTags = <String>{};
    for (final note in _notes) {
      allTags.addAll(note.tags);
    }
    return allTags.toList()..sort();
  }
}
