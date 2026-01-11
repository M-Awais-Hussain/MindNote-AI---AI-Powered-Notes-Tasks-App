import 'dart:convert';
import 'groq_service.dart';

class AIAssistantService {
  final GroqService _groqService = GroqService();

  Future<String> summarizeNote(String content) async {
    final prompt =
        'Summarize the following note content in 2-3 concise bullet points:\n\n$content';
    return await _groqService.quickPrompt(prompt);
  }

  Future<String> enhanceNote(String content) async {
    final prompt =
        'Donot include extra words or asking question or giving suggestion, simple Improve the grammar, style, and clarity of the following note content while preserving its original meaning:\n\n$content';
    return await _groqService.quickPrompt(prompt);
  }

  Future<String> formatVoiceNote(String content) async {
    final prompt =
        'The following text is a raw voice transcription. Format it into a clean, structured note. Remove filler words (um, uh), fix punctuation, and organize into paragraphs or bullet points where appropriate:\n\n$content';
    return await _groqService.quickPrompt(prompt);
  }

  Future<List<String>> suggestTags(String content) async {
    final prompt =
        'Identify 3-5 relevant tags (single words) for the following content. Return them as a comma-separated list without numbering or bullet points:\n\n$content';
    final response = await _groqService.quickPrompt(prompt);
    return response
        .split(',')
        .map((tag) => tag.trim().replaceAll(RegExp(r'^#'), ''))
        .toList();
  }

  Future<List<String>> breakdownTask(String title, String description) async {
    final prompt =
        'Break down the following task into 3-5 manageable subtasks. Return them as a bulleted list:\n\nTask: $title\nDescription: $description';
    final response = await _groqService.quickPrompt(prompt);
    return response
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.replaceFirst(RegExp(r'^[-*•\d.]+\s*'), '').trim())
        .toList();
  }

  Future<String> analyzeDailyBriefing(
    List<String> tasks,
    List<String> notes,
  ) async {
    final prompt = '''
    You are a personal productivity assistant. Analyze the following pending tasks and recent notes to generate a concise, 2-3 sentence daily briefing.
    Be encouraging but focused. Use the user's data to suggest priorities.

    Pending Tasks: ${tasks.join(', ')}
    Recent Notes: ${notes.join(', ')}
    Pending Tasks: ${tasks.join(', ')}
    Recent Notes: ${notes.join(', ')}
    ''';
    return await _groqService.quickPrompt(prompt);
  }

  Future<Map<String, dynamic>> analyzeSearchQuery(String query) async {
    final prompt = '''
    Analyze this natural language search query for a notes app. 
    Query: "$query"
    
    Extract:
    1. keywords (list of strings)
    2. priority (high, medium, low, or null)
    3. type (note, task, or both)
    
    Return ONLY a valid JSON object in this format:
    {"keywords": ["keyword1", "keyword2"], "priority": "high", "type": "task"}
    ''';

    final response = await _groqService.quickPrompt(prompt);

    try {
      final startIndex = response.indexOf('{');
      final endIndex = response.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1) {
        final jsonStr = response.substring(startIndex, endIndex + 1);
        return jsonDecode(jsonStr);
      }
    } catch (e) {
      print('Error parsing AI search query: $e');
    }

    // Fallback if parsing fails
    return {
      "keywords": [query],
      "priority": null,
      "type": "both",
    };
  }

  Future<DateTime?> parseReminderDateTime(String content) async {
    final prompt = '''
    Analyze the following text and extract a reminder date and time.
    Return ONLY a valid ISO 8601 string (e.g., "2023-12-25T14:30:00") or "null" if no date/time is found.
    Assume the current date is ${DateTime.now().toIso8601String()}.
    
    Text: $content
    ''';

    final response = await _groqService.quickPrompt(prompt);

    if (response.trim().toLowerCase() == 'null') return null;

    try {
      return DateTime.parse(response.trim());
    } catch (e) {
      print('Error parsing reminder date: $e');
      return null;
    }
  }

  Future<List<String>> findRelatedNotes(
    String currentNoteContent,
    Map<String, String> otherNotes,
  ) async {
    if (otherNotes.isEmpty) return [];

    // Limit context to strictly necessary info (ID and truncated content)
    final notesContext = otherNotes.entries.map((e) {
      final content =
          e.value.length > 50 ? '${e.value.substring(0, 50)}...' : e.value;
      return 'ID: ${e.key}, Content: $content';
    }).join('\n');

    final prompt = '''
    Analyze the following note and identify up to 3 most relevant related notes from the list.
    
    Target Note: $currentNoteContent
    
    Available Notes:
    $notesContext
    
    Return ONLY a comma-separated list of the IDs of the related notes. If none are relevant, return "none".
    ''';

    final response = await _groqService.quickPrompt(prompt);

    if (response.toLowerCase().contains('none')) return [];

    return response.split(',').map((id) => id.trim()).toList();
  }
}
