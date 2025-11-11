import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../blocs/settings/settings_bloc.dart';
import '../blocs/settings/settings_event.dart';
import '../blocs/settings/settings_state.dart';

/// Enhanced settings page with full persistence via SettingsBloc
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appVersion = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More options',
            onSelected: (value) {
              if (value == 'export') _exportSettings();
              else if (value == 'import') _importSettings();
              else if (value == 'reset') _resetSettings();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.upload_file),
                    SizedBox(width: 12),
                    Text('Export Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.download_outlined),
                    SizedBox(width: 12),
                    Text('Import Settings'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.restore, color: Colors.orange),
                    SizedBox(width: 12),
                    Text('Reset to Defaults'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SettingsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.read<SettingsBloc>().add(const LoadSettings()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is! SettingsLoaded) {
            return const SizedBox();
          }

          return ListView(
            children: [
              // Appearance Section
              _buildSectionHeader('Appearance'),
              _buildThemeModeSelector(context, state.themeMode),
              SwitchListTile(
                title: const Text('Show Thumbnails'),
                subtitle: const Text('Display video thumbnails'),
                value: state.showThumbnails,
                onChanged: (value) => context
                    .read<SettingsBloc>()
                    .add(UpdateShowThumbnails(value)),
                secondary: const Icon(Icons.image),
              ),
              SwitchListTile(
                title: const Text('Enable Animations'),
                subtitle: const Text('Show smooth transitions'),
                value: state.animationsEnabled,
                onChanged: (value) => context
                    .read<SettingsBloc>()
                    .add(UpdateAnimationsEnabled(value)),
                secondary: const Icon(Icons.animation),
              ),
              SwitchListTile(
                title: const Text('Data Saver Mode'),
                subtitle: const Text('Reduce data usage'),
                value: state.dataSaverMode,
                onChanged: (value) => context
                    .read<SettingsBloc>()
                    .add(UpdateDataSaverMode(value)),
                secondary: const Icon(Icons.data_saver_on),
              ),
              const Divider(),

              // Downloads Section
              _buildSectionHeader('Downloads'),
              _buildQualitySelector(context, state.defaultQuality),
              _buildFormatSelector(context, state.defaultFormat),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Download Location'),
                subtitle: Text(state.downloadLocation),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _selectDownloadLocation(context, state),
              ),
              SwitchListTile(
                title: const Text('Auto-start Downloads'),
                subtitle: const Text('Start downloads immediately after adding'),
                value: state.autoStartDownloads,
                onChanged: (value) => context
                    .read<SettingsBloc>()
                    .add(UpdateAutoStartDownloads(value)),
                secondary: const Icon(Icons.play_arrow),
              ),
              ListTile(
                leading: const Icon(Icons.download_multiple),
                title: const Text('Max Concurrent Downloads'),
                subtitle: Text('${state.maxConcurrentDownloads} downloads at once'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _selectMaxConcurrentDownloads(context, state),
              ),
              SwitchListTile(
                title: const Text('Delete After Download'),
                subtitle: const Text('Remove completed downloads automatically'),
                value: state.deleteAfterDownload,
                onChanged: (value) => context
                    .read<SettingsBloc>()
                    .add(UpdateDeleteAfterDownload(value)),
                secondary: const Icon(Icons.auto_delete),
              ),
              const Divider(),

              // Notifications Section
              _buildSectionHeader('Notifications'),
              SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Receive notifications for download events'),
                value: state.notificationsEnabled,
                onChanged: (value) => context
                    .read<SettingsBloc>()
                    .add(UpdateNotificationsEnabled(value)),
                secondary: const Icon(Icons.notifications),
              ),
              SwitchListTile(
                title: const Text('Schedule Notifications'),
                subtitle: const Text('Notify when scheduled downloads execute'),
                value: state.scheduleNotificationsEnabled,
                onChanged: (value) => context
                    .read<SettingsBloc>()
                    .add(UpdateScheduleNotificationsEnabled(value)),
                secondary: const Icon(Icons.schedule_send),
              ),
              const Divider(),

              // Sync Section
              _buildSectionHeader('Sync'),
              SwitchListTile(
                title: const Text('Auto Sync'),
                subtitle: const Text('Automatically sync with server'),
                value: state.autoSyncEnabled,
                onChanged: (value) => context
                    .read<SettingsBloc>()
                    .add(UpdateAutoSyncEnabled(value)),
                secondary: const Icon(Icons.sync),
              ),
              ListTile(
                leading: const Icon(Icons.timer),
                title: const Text('Sync Interval'),
                subtitle: Text('Every ${state.syncIntervalMinutes} minutes'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _selectSyncInterval(context, state),
                enabled: state.autoSyncEnabled,
              ),
              SwitchListTile(
                title: const Text('Cloud Sync'),
                subtitle: const Text('Sync with cloud storage'),
                value: state.cloudSyncEnabled,
                onChanged: (value) => context
                    .read<SettingsBloc>()
                    .add(UpdateCloudSyncEnabled(value)),
                secondary: const Icon(Icons.cloud),
              ),
              const Divider(),

              // Server Section
              _buildSectionHeader('Server'),
              ListTile(
                leading: const Icon(Icons.dns),
                title: const Text('Server Address'),
                subtitle: Text(state.apiBaseUrl),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _configureServer(context, state),
              ),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: const Text('Request Timeout'),
                subtitle: Text('${state.apiTimeout} seconds'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _selectApiTimeout(context, state),
              ),
              const Divider(),

              // About Section
              _buildSectionHeader('About'),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.info, color: Colors.white),
                ),
                title: const Text('Version'),
                subtitle: Text('$_appVersion ($_buildNumber)'),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Licenses'),
                subtitle: const Text('Open source licenses'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showLicenses,
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showPrivacyPolicy,
              ),
              ListTile(
                leading: const Icon(Icons.article),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showTerms,
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Made with ❤️ by GrabTube Team',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildThemeModeSelector(BuildContext context, String currentMode) {
    return ListTile(
      leading: const Icon(Icons.palette),
      title: const Text('Theme Mode'),
      subtitle: Text(_getThemeModeLabel(currentMode)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final selected = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Select Theme'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: ['system', 'light', 'dark'].map((mode) {
                return RadioListTile<String>(
                  title: Text(_getThemeModeLabel(mode)),
                  value: mode,
                  groupValue: currentMode,
                  onChanged: (value) => Navigator.pop(context, value),
                );
              }).toList(),
            ),
          ),
        );
        if (selected != null && context.mounted) {
          context.read<SettingsBloc>().add(UpdateThemeMode(selected));
        }
      },
    );
  }

  String _getThemeModeLabel(String mode) {
    switch (mode) {
      case 'system':
        return 'System Default';
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      default:
        return 'Unknown';
    }
  }

  Widget _buildQualitySelector(BuildContext context, String currentQuality) {
    return ListTile(
      leading: const Icon(Icons.high_quality),
      title: const Text('Default Quality'),
      subtitle: Text(currentQuality.toUpperCase()),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final qualities = ['best', 'high', 'medium', 'low'];
        final selected = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Select Default Quality'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: qualities.map((quality) {
                return RadioListTile<String>(
                  title: Text(quality.toUpperCase()),
                  value: quality,
                  groupValue: currentQuality,
                  onChanged: (value) => Navigator.pop(context, value),
                );
              }).toList(),
            ),
          ),
        );
        if (selected != null && context.mounted) {
          context.read<SettingsBloc>().add(UpdateDefaultQuality(selected));
        }
      },
    );
  }

  Widget _buildFormatSelector(BuildContext context, String currentFormat) {
    return ListTile(
      leading: const Icon(Icons.video_file),
      title: const Text('Default Format'),
      subtitle: Text(currentFormat.toUpperCase()),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final formats = ['mp4', 'webm', 'mkv', 'mp3'];
        final selected = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Select Default Format'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: formats.map((format) {
                return RadioListTile<String>(
                  title: Text(format.toUpperCase()),
                  value: format,
                  groupValue: currentFormat,
                  onChanged: (value) => Navigator.pop(context, value),
                );
              }).toList(),
            ),
          ),
        );
        if (selected != null && context.mounted) {
          context.read<SettingsBloc>().add(UpdateDefaultFormat(selected));
        }
      },
    );
  }

  void _selectDownloadLocation(BuildContext context, SettingsLoaded state) async {
    // For now, show a dialog with the current location
    // In a full implementation, you'd use file_picker to select a directory
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Location'),
        content: Text('Current location:\n${state.downloadLocation}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _selectMaxConcurrentDownloads(
      BuildContext context, SettingsLoaded state) async {
    final controller = TextEditingController(
      text: state.maxConcurrentDownloads.toString(),
    );

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Max Concurrent Downloads'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Number of downloads',
            hintText: '1-10',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value >= 1 && value <= 10) {
                Navigator.pop(context, value);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a number between 1 and 10'),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && context.mounted) {
      context
          .read<SettingsBloc>()
          .add(UpdateMaxConcurrentDownloads(result));
    }
  }

  void _selectSyncInterval(BuildContext context, SettingsLoaded state) async {
    final intervals = [5, 10, 15, 30, 60];
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Interval'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: intervals.map((interval) {
            return RadioListTile<int>(
              title: Text('$interval minutes'),
              value: interval,
              groupValue: state.syncIntervalMinutes,
              onChanged: (value) => Navigator.pop(context, value),
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null && context.mounted) {
      context.read<SettingsBloc>().add(UpdateSyncInterval(selected));
    }
  }

  void _selectApiTimeout(BuildContext context, SettingsLoaded state) async {
    final timeouts = [10, 15, 20, 30, 45, 60];
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Timeout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: timeouts.map((timeout) {
            return RadioListTile<int>(
              title: Text('$timeout seconds'),
              value: timeout,
              groupValue: state.apiTimeout,
              onChanged: (value) => Navigator.pop(context, value),
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null && context.mounted) {
      context.read<SettingsBloc>().add(UpdateApiTimeout(selected));
    }
  }

  void _configureServer(BuildContext context, SettingsLoaded state) async {
    final urlController = TextEditingController(text: state.apiBaseUrl);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Server Address'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            labelText: 'Server URL',
            hintText: 'http://localhost:8081',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, urlController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      context.read<SettingsBloc>().add(UpdateApiBaseUrl(result));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Server address updated'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _exportSettings() async {
    try {
      final state = context.read<SettingsBloc>().state;
      if (state is! SettingsLoaded) return;

      final settings = state.toMap();
      final settingsJson = settings.entries
          .map((e) => '  "${e.key}": ${_formatValue(e.value)}')
          .join(',\n');

      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/grabtube_settings_$timestamp.json');
      await file.writeAsString('{\n$settingsJson\n}');

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'GrabTube Settings Export',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatValue(dynamic value) {
    if (value is String) return '"$value"';
    return value.toString();
  }

  Future<void> _importSettings() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) return;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();

      // Simple JSON parsing (in production, use dart:convert)
      // For now, show a dialog with the content
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import Settings'),
            content: const Text(
              'Settings import will be processed.\n\n'
              'Note: This is a placeholder. Full JSON parsing will be implemented.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resetSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings?'),
        content: const Text(
          'This will reset all settings to their default values. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<SettingsBloc>().add(const ResetSettingsToDefaults());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings reset to defaults'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: 'GrabTube',
      applicationVersion: _appVersion,
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.download,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Privacy policy content would go here.\n\n'
            'This app respects your privacy and does not collect personal data without consent.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTerms() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'Terms of service content would go here.\n\n'
            'By using this app, you agree to these terms.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
