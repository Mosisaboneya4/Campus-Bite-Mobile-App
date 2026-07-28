import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campusbite/providers/settings_provider.dart';
import 'package:campusbite/providers/contract_provider.dart';
import 'package:campusbite/utils/backup_service.dart';

/// Screen for app settings
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsProvider = context.watch<SettingsProvider>();
    final contractProvider = context.watch<ContractProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Currency settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Currency',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: settingsProvider.currency,
                    decoration: const InputDecoration(
                      labelText: 'Currency Symbol',
                      prefixIcon: Icon(Icons.attach_money),
                      hintText: 'e.g., Birr, \$, €',
                    ),
                    onChanged: (value) {
                      settingsProvider.updateCurrency(value.trim());
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Dark mode
          Card(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Enable dark theme'),
              value: settingsProvider.darkMode,
              onChanged: (value) {
                settingsProvider.toggleDarkMode();
              },
              secondary: const Icon(Icons.dark_mode),
            ),
          ),
          const SizedBox(height: 16),

          // Low balance threshold
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Low Balance Warning',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: settingsProvider.lowBalanceThreshold.toString(),
                    decoration: InputDecoration(
                      labelText: 'Threshold Amount',
                      prefixIcon: const Icon(Icons.warning),
                      suffixText: settingsProvider.currency,
                      hintText: 'Enter threshold amount',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final threshold = double.tryParse(value);
                      if (threshold != null && threshold >= 0) {
                        settingsProvider.updateLowBalanceThreshold(threshold);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Show warning when balance falls below this amount',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Notifications
          Card(
            child: SwitchListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Enable low balance notifications'),
              value: settingsProvider.notificationsEnabled,
              onChanged: (value) {
                settingsProvider.toggleNotifications();
              },
              secondary: const Icon(Icons.notifications),
            ),
          ),
          const SizedBox(height: 16),

          // Contract management
          if (contractProvider.currentContract != null)
            Card(
              child: ListTile(
                title: const Text('Reset Contract'),
                subtitle: const Text('Delete current contract and all meals'),
                leading: const Icon(Icons.refresh, color: Colors.orange),
                onTap: () => _resetContract(context, contractProvider),
              ),
            ),
          const SizedBox(height: 16),

          // Backup/Restore
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Backup Data'),
                  subtitle: const Text('Export your data'),
                  leading: const Icon(Icons.backup, color: Colors.blue),
                  onTap: () => _backupData(context, contractProvider),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Restore Data'),
                  subtitle: const Text('Import your data'),
                  leading: const Icon(Icons.restore, color: Colors.green),
                  onTap: () => _restoreData(context, contractProvider),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // About
          Card(
            child: ListTile(
              title: const Text('About'),
              subtitle: const Text('Campus Meal Tracker v1.0'),
              leading: const Icon(Icons.info),
              onTap: () => _showAboutDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resetContract(
    BuildContext context,
    ContractProvider contractProvider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Contract'),
        content: const Text(
          'This will delete your current contract and all meal history. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await contractProvider.deleteContract();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contract reset successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _backupData(
    BuildContext context,
    ContractProvider contractProvider,
  ) async {
    try {
      await BackupService.backupData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _restoreData(
    BuildContext context,
    ContractProvider contractProvider,
  ) async {
    // TODO: Implement file picker for restore
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Restore feature - select backup file coming soon!'),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Campus Meal Tracker',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Campus Meal Tracker. All rights reserved.',
    );
  }
}
