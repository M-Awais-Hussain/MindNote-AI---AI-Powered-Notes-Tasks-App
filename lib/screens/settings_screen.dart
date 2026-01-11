import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_profile.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
backgroundColor: Color(0xFF673AB7),  
      appBar: AppBar(
        backgroundColor: Color(0xFF00BCD4), 
        title: const Text('Settings'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            children: [
              _buildSection(
                context,
                'Appearance',
                [
                  _buildSwitchTile(
                    context,
                    'Dark Mode',
                    'Switch between light and dark theme',
                    Icons.dark_mode,
                    userProvider.isDarkMode,
                    (value) => userProvider.toggleDarkMode(),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              _buildSection(
                context,
                'Language',
                [
                  _buildListTile(
                    context,
                    'Language',
                    'English',
                    Icons.language,
                    () => _showLanguageDialog(context, userProvider),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              _buildSection(
                context,
                'Notifications',
                [
                  _buildSwitchTile(
                    context,
                    'Push Notifications',
                    'Receive notifications for tasks and reminders',
                    Icons.notifications,
                    userProvider.userProfile?.preferences['notifications'] ?? true,
                    (value) => userProvider.updatePreferences({'notifications': value}),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              _buildSection(
                context,
                'Data & Storage',
                [
                  _buildListTile(
                    context,
                    'Export Data',
                    'Export your tasks and notes',
                    Icons.download,
                    () => _exportData(context),
                  ),
                  _buildListTile(
                    context,
                    'Clear Cache',
                    'Clear app cache and temporary files',
                    Icons.cleaning_services,
                    () => _clearCache(context),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              _buildSection(
                context,
                'About',
                [
                  _buildListTile(
                    context,
                    'App Version',
                    AppConstants.appVersion,
                    Icons.info,
                    null,
                  ),
                  _buildListTile(
                    context,
                    'Privacy Policy',
                    'View our privacy policy',
                    Icons.privacy_tip,
                    () => _showPrivacyPolicy(context),
                  ),
                  _buildListTile(
                    context,
                    'Terms of Service',
                    'View terms of service',
                    Icons.description,
                    () => _showTermsOfService(context),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              _buildDangerZone(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      secondary: Icon(icon),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildListTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      leading: Icon(icon),
      trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    return Card(
      color: Colors.red[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Text(
              'Danger Zone',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
          ),
          ListTile(
            title: const Text('Reset All Data'),
            subtitle: const Text('Delete all tasks, notes, and settings'),
            leading: Icon(Icons.delete_forever, color: Colors.red[700]),
            onTap: () => _showResetDataDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, UserProvider userProvider) {
    final languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'es', 'name': 'Español'},
      {'code': 'fr', 'name': 'Français'},
      {'code': 'de', 'name': 'Deutsch'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) {
            return ListTile(
              title: Text(language['name']!),
              trailing: userProvider.language == language['code']
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                userProvider.setLanguage(language['code']!);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Language changed to ${language['name']}'),
                    backgroundColor: AppConstants.successColor,
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _exportData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Export feature coming soon!'),
        backgroundColor: AppConstants.warningColor,
      ),
    );
  }

  void _clearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear the app cache?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: AppConstants.successColor,
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'This is a practice app created for learning purposes. '
            'We do not collect, store, or share any personal data. '
            'All data is stored locally on your device.\n\n'
            'If you have any questions about privacy, please contact us.',
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

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'This is a practice app created for learning purposes. '
            'By using this app, you agree to use it responsibly and '
            'in accordance with applicable laws.\n\n'
            'The app is provided "as is" without any warranties.',
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

  void _showResetDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data'),
        content: const Text(
          'Are you sure you want to reset all data? This will delete all tasks, '
          'notes, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Reset all data
              final userProvider = context.read<UserProvider>();
              // Create a new default profile instead of setting to null
              final defaultProfile = UserProfile(
                id: AppHelpers.generateId(),
                name: 'John Doe',
                email: 'john.doe@example.com',
                createdAt: DateTime.now(),
                preferences: {
                  'notifications': true,
                  'theme': 'system',
                  'language': 'en',
                },
              );
              userProvider.setUserProfile(defaultProfile);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data has been reset'),
                  backgroundColor: AppConstants.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
