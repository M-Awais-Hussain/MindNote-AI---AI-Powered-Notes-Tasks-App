import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../models/note.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

import 'add_edit_note_screen.dart';
import '../widgets/glass_card.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFECB3),
      appBar: AppBar(
        backgroundColor: Color(0xFF00BCD4),
        title: const Text('Notes'),
        actions: [
          Consumer<NoteProvider>(
            builder: (context, noteProvider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'view_tags':
                      _showTagsDialog(context, noteProvider);
                      break;
                    case 'clear_all':
                      _showClearAllDialog(context, noteProvider);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view_tags',
                    child: Row(
                      children: [
                        Icon(Icons.tag),
                        SizedBox(width: 8),
                        Text('View Tags'),
                      ],
                    ),
                  ),
                  if (noteProvider.allNotes.isNotEmpty)
                    const PopupMenuItem(
                      value: 'clear_all',
                      child: Row(
                        children: [
                          Icon(Icons.clear_all),
                          SizedBox(width: 8),
                          Text('Clear All'),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child: Consumer<NoteProvider>(
              builder: (context, noteProvider, child) {
                if (noteProvider.notes.isEmpty) {
                  return _buildEmptyState(context);
                }
                return _buildNotesList(context, noteProvider);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddNote(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search notes (try "important work stuff")...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: noteProvider.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                noteProvider.performAISearch(
                  value,
                ); // Trigger AI search on submit
              }
            },
            onChanged: (value) {
              // Update local state, but maybe don't trigger filtering immediately if we want to rely on AI?
              // Actually, let's keep simple filtering for immediate feedback, AI for deeper search
              // noteProvider.setSearchQuery(value);
              if (value.isEmpty) {
                noteProvider.setSearchQuery('');
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note, size: 80, color: Colors.grey[400]),
          const SizedBox(height: AppConstants.paddingLarge),
          Text(
            'No notes found',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            'Create your first note to get started!',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddNote(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Note'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(BuildContext context, NoteProvider noteProvider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
      ),
      itemCount: noteProvider.notes.length,
      itemBuilder: (context, index) {
        final note = noteProvider.notes[index];
        return _buildNoteCard(context, note, noteProvider);
      },
    );
  }

  Widget _buildNoteCard(
    BuildContext context,
    Note note,
    NoteProvider noteProvider,
  ) {
    return GlassCard(
      onTap: () => _navigateToEditNote(context, note),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  note.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _navigateToEditNote(context, note);
                      break;
                    case 'related':
                      _showRelatedNotesDialog(context, note, noteProvider);
                      break;
                    case 'delete':
                      _showDeleteDialog(context, note, noteProvider);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'related',
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome_motion),
                        SizedBox(width: 8),
                        Text('Related Notes'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            AppHelpers.getNotePreview(note.content),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (note.aiSummary != null) ...[
            const SizedBox(height: AppConstants.paddingSmall),
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingSmall),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                border: Border.all(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.summarize,
                    size: 14,
                    color: AppConstants.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      note.aiSummary!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConstants.primaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (note.tags.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingSmall),
            Wrap(
              spacing: AppConstants.paddingSmall,
              runSpacing: AppConstants.paddingSmall,
              children: note.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusSmall,
                    ),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: AppConstants.paddingSmall),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                AppHelpers.getRelativeTime(note.updatedAt),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
              ),
              const Spacer(),
              if (note.createdAt != note.updatedAt)
                Text(
                  'Edited',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToAddNote(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddEditNoteScreen()));
  }

  void _navigateToEditNote(BuildContext context, Note note) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddEditNoteScreen(note: note)),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    Note note,
    NoteProvider noteProvider,
  ) {
    AppHelpers.showConfirmationDialog(
      context,
      title: 'Delete Note',
      content: 'Are you sure you want to delete "${note.title}"?',
      onConfirm: () {
        noteProvider.deleteNote(note.id);
        AppHelpers.showSnackBar(context, 'Note deleted successfully');
      },
    );
  }

  void _showClearAllDialog(BuildContext context, NoteProvider noteProvider) {
    AppHelpers.showConfirmationDialog(
      context,
      title: 'Clear All Notes',
      content:
          'Are you sure you want to delete all notes? This action cannot be undone.',
      onConfirm: () {
        // Clear all notes
        for (final note in noteProvider.allNotes) {
          noteProvider.deleteNote(note.id);
        }
        AppHelpers.showSnackBar(context, 'All notes cleared');
      },
    );
  }

  void _showTagsDialog(BuildContext context, NoteProvider noteProvider) {
    final tags = noteProvider.getAllTags();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Tags'),
        content: tags.isEmpty
            ? const Text('No tags found')
            : Wrap(
                spacing: AppConstants.paddingSmall,
                runSpacing: AppConstants.paddingSmall,
                children: tags.map((tag) {
                  return GestureDetector(
                    onTap: () {
                      noteProvider.setSearchQuery(tag);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingSmall,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusSmall,
                        ),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRelatedNotesDialog(
    BuildContext context,
    Note note,
    NoteProvider noteProvider,
  ) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await noteProvider.fetchRelatedNotes(note.id);
    Navigator.of(context).pop(); // hide loading

    if (!context.mounted) return;

    final relatedNotes = noteProvider.relatedNoteIds
        .map(
          (id) => noteProvider.allNotes.firstWhere(
            (n) => n.id == id,
            orElse: () => Note(
              id: '',
              title: '',
              content: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              tags: [],
            ),
          ),
        )
        .where((n) => n.id.isNotEmpty)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Related to "${note.title}"'),
        content: relatedNotes.isEmpty
            ? const Text('No related notes found by AI.')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: relatedNotes.length,
                  itemBuilder: (context, index) {
                    final related = relatedNotes[index];
                    return ListTile(
                      title: Text(
                        related.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        related.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.of(context).pop(); // close dialog
                        _navigateToEditNote(context, related);
                      },
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
