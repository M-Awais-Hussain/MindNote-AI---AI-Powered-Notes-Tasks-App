import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/task_provider.dart';
import '../providers/note_provider.dart';
import '../models/user_profile.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initializeUserProfile();
    });
  }

  void _initializeUserProfile() {
    final userProvider = context.read<UserProvider>();
    if (userProvider.userProfile == null) {
      // Create a default user profile
      final defaultProfile = UserProfile(
        id: AppHelpers.generateId(),
        name: 'Awais',
        email: 'noman@gmail.com',
        createdAt: DateTime.now(),
        preferences: {
          'notifications': true,
          'theme': 'system',
          'language': 'en',
        },
      );
      userProvider.setUserProfile(defaultProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _navigateToSettings(context),
          ),
        ],
      ),
      body: Consumer3<UserProvider, TaskProvider, NoteProvider>(
        builder: (context, userProvider, taskProvider, noteProvider, child) {
          final user = userProvider.userProfile;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              children: [
                _buildProfileHeader(context, user),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildStatsCards(context, taskProvider, noteProvider),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildProfileInfo(context, user),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildQuickActions(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            ElevatedButton.icon(
              onPressed: () => _editProfile(context, user),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, TaskProvider taskProvider,
      NoteProvider noteProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Total Tasks',
            '${taskProvider.allTasks.length}',
            Icons.task_alt,
            AppConstants.primaryColor,
          ),
        ),
        const SizedBox(width: AppConstants.paddingMedium),
        Expanded(
          child: _buildStatCard(
            context,
            'Completed',
            '${taskProvider.completedTasksCount}',
            Icons.check_circle,
            AppConstants.successColor,
          ),
        ),
        const SizedBox(width: AppConstants.paddingMedium),
        Expanded(
          child: _buildStatCard(
            context,
            'Notes',
            '${noteProvider.allNotes.length}',
            Icons.note,
            AppConstants.accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context, UserProfile user) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                _buildInfoRow(context, 'Name', user.name),
                _buildInfoRow(context, 'Email', user.email),
                _buildInfoRow(context, 'Member Since',
                    AppHelpers.formatDate(user.createdAt)),
                _buildInfoRow(context, 'Theme',
                    userProvider.isDarkMode ? 'Dark' : 'Light'),
                _buildInfoRow(
                    context, 'Language', userProvider.language.toUpperCase()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            _buildActionTile(
              context,
              'Settings',
              'Manage app preferences',
              Icons.settings,
              () => _navigateToSettings(context),
            ),
            _buildActionTile(
              context,
              'Export Data',
              'Export your tasks and notes',
              Icons.download,
              () => _exportData(context),
            ),
            _buildActionTile(
              context,
              'Clear All Data',
              'Delete all tasks and notes',
              Icons.delete_forever,
              () => _showClearDataDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _editProfile(BuildContext context, UserProfile user) {
    showDialog(
      context: context,
      builder: (context) => _EditProfileDialog(user: user),
    );
  }

  void _exportData(BuildContext context) {
    AppHelpers.showSnackBar(
      context,
      'Export feature coming soon!',
      backgroundColor: AppConstants.warningColor,
    );
  }

  void _showClearDataDialog(BuildContext context) {
    AppHelpers.showConfirmationDialog(
      context,
      title: 'Clear All Data',
      content:
          'Are you sure you want to delete all tasks and notes? This action cannot be undone.',
      onConfirm: () {
        final taskProvider = context.read<TaskProvider>();
        final noteProvider = context.read<NoteProvider>();

        // Clear all tasks
        for (final task in taskProvider.allTasks) {
          taskProvider.deleteTask(task.id);
        }

        // Clear all notes
        for (final note in noteProvider.allNotes) {
          noteProvider.deleteNote(note.id);
        }

        AppHelpers.showSnackBar(
          context,
          'All data cleared successfully',
          backgroundColor: AppConstants.successColor,
        );
      },
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  final UserProfile user;

  const _EditProfileDialog({required this.user});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _emailController.text = widget.user.email;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveProfile,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = context.read<UserProvider>();
      final updatedProfile = widget.user.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );

      userProvider.updateUserProfile(updatedProfile);
      AppHelpers.showSnackBar(
        context,
        'Profile updated successfully',
        backgroundColor: AppConstants.successColor,
      );

      Navigator.of(context).pop();
    } catch (e) {
      AppHelpers.showSnackBar(
        context,
        'Error updating profile: $e',
        backgroundColor: AppConstants.errorColor,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
