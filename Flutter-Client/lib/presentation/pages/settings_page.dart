import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Settings page for app configuration
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _autoStart = true;
  bool _wifiOnly = false;
  String _downloadLocation = '/storage/emulated/0/Download';
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
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
            },
            secondary: const Icon(Icons.dark_mode),
          ),
          const Divider(),
          _buildSectionHeader('Downloads'),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Download Location'),
            subtitle: Text(_downloadLocation),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _selectDownloadLocation(),
          ),
          SwitchListTile(
            title: const Text('Auto-start Downloads'),
            subtitle: const Text('Start downloads immediately after adding'),
            value: _autoStart,
            onChanged: (value) {
              setState(() {
                _autoStart = value;
              });
            },
            secondary: const Icon(Icons.play_arrow),
          ),
          SwitchListTile(
            title: const Text('WiFi Only'),
            subtitle: const Text('Only download when connected to WiFi'),
            value: _wifiOnly,
            onChanged: (value) {
              setState(() {
                _wifiOnly = value;
              });
            },
            secondary: const Icon(Icons.wifi),
          ),
          const Divider(),
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive notifications for download events'),
            value: _notifications,
            onChanged: (value) {
              setState(() {
                _notifications = value;
              });
            },
            secondary: const Icon(Icons.notifications),
          ),
          const Divider(),
          _buildSectionHeader('Data & Storage'),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Storage Usage'),
            subtitle: const Text('View and manage storage'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showStorageInfo(),
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep),
            title: const Text('Clear Cache'),
            subtitle: const Text('Remove temporary files'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _clearCache(),
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Clear Download History'),
            subtitle: const Text('Remove completed downloads from history'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _clearHistory(),
          ),
          const Divider(),
          _buildSectionHeader('Server'),
          ListTile(
            leading: const Icon(Icons.dns),
            title: const Text('Server Address'),
            subtitle: const Text('Configure backend server'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _configureServer(),
          ),
          ListTile(
            leading: const Icon(Icons.vpn_key),
            title: const Text('Authentication'),
            subtitle: const Text('Manage server credentials'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _configureAuth(),
          ),
          const Divider(),
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
            onTap: () => _showLicenses(),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPrivacyPolicy(),
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTerms(),
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

  void _selectDownloadLocation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Location'),
        content: const Text(
          'Download location picker coming soon. You will be able to select a custom folder for downloads.',
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

  void _showStorageInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Usage'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Downloads: 2.5 GB'),
            SizedBox(height: 8),
            Text('Cache: 124 MB'),
            SizedBox(height: 8),
            Text('Total: 2.62 GB'),
          ],
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

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache?'),
        content: const Text(
          'This will remove all temporary files. Downloads will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text(
          'This will remove all completed downloads from history. Downloaded files will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('History cleared'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _configureServer() {
    final urlController = TextEditingController(
      text: 'http://localhost:8081',
    );

    showDialog(
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Server address updated'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _configureAuth() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Credentials saved'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
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
