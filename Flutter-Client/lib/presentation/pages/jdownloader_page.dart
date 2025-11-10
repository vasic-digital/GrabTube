import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/jdownloader_instance.dart';
import '../blocs/jdownloader/jdownloader_bloc.dart';
import '../blocs/jdownloader/jdownloader_event.dart';
import '../blocs/jdownloader/jdownloader_state.dart';

/// JDownloader integration page for managing remote instances
class JDownloaderPage extends StatefulWidget {
  const JDownloaderPage({super.key});

  @override
  State<JDownloaderPage> createState() => _JDownloaderPageState();
}

class _JDownloaderPageState extends State<JDownloaderPage> {
  @override
  void initState() {
    super.initState();
    context.read<JDownloaderBloc>().add(const LoadJDownloaderInstancesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JDownloader Instances'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context
                  .read<JDownloaderBloc>()
                  .add(const LoadJDownloaderInstancesEvent());
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocConsumer<JDownloaderBloc, JDownloaderState>(
        listener: (context, state) {
          if (state is JDownloaderFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is JDownloaderInstanceAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Instance added successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is JDownloaderInstanceDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Instance deleted'),
                backgroundColor: Colors.orange,
              ),
            );
          } else if (state is JDownloaderInstanceConnected) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Connected to instance'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is JDownloaderInstancesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is JDownloaderInstancesLoaded) {
            if (state.instances.isEmpty) {
              return _buildEmptyView();
            }

            return _buildInstancesList(context, state.instances);
          }

          return _buildInitialView();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddInstanceDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Instance'),
      ),
    );
  }

  Widget _buildInstancesList(
    BuildContext context,
    List<JDownloaderInstance> instances,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<JDownloaderBloc>().add(const LoadJDownloaderInstancesEvent());
      },
      child: ListView.builder(
        itemCount: instances.length,
        itemBuilder: (context, index) {
          final instance = instances[index];
          return _buildInstanceCard(context, instance);
        },
      ),
    );
  }

  Widget _buildInstanceCard(BuildContext context, JDownloaderInstance instance) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(instance.status),
          child: Icon(
            _getStatusIcon(instance.status),
            color: Colors.white,
          ),
        ),
        title: Text(
          instance.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${instance.status.name.toUpperCase()}${instance.host != null ? " • ${instance.host}:${instance.port}" : ""}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: _buildConnectionButton(context, instance),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInstanceDetails(instance),
                const SizedBox(height: 16),
                if (instance.status == JDownloaderStatus.online ||
                    instance.status == JDownloaderStatus.downloading) ...[
                  _buildInstanceStats(instance),
                  const SizedBox(height: 16),
                  _buildInstanceActions(context, instance),
                  const SizedBox(height: 16),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showEditInstanceDialog(context, instance),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () =>
                          _showDeleteConfirmation(context, instance),
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionButton(
    BuildContext context,
    JDownloaderInstance instance,
  ) {
    if (instance.status == JDownloaderStatus.online ||
        instance.status == JDownloaderStatus.downloading) {
      return IconButton(
        icon: const Icon(Icons.power_settings_new, color: Colors.green),
        onPressed: () {
          context
              .read<JDownloaderBloc>()
              .add(DisconnectJDownloaderInstanceEvent(instance.id));
        },
        tooltip: 'Disconnect',
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.power_settings_new, color: Colors.grey),
        onPressed: () {
          context
              .read<JDownloaderBloc>()
              .add(ConnectJDownloaderInstanceEvent(instance.id));
        },
        tooltip: 'Connect',
      );
    }
  }

  Widget _buildInstanceDetails(JDownloaderInstance instance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Device ID', instance.deviceId),
        if (instance.host != null)
          _buildDetailRow('Host', '${instance.host}:${instance.port}'),
        if (instance.version != null)
          _buildDetailRow('Version', instance.version!),
        if (instance.lastConnected != null)
          _buildDetailRow(
            'Last Connected',
            instance.lastConnected.toString(),
          ),
      ],
    );
  }

  Widget _buildInstanceStats(JDownloaderInstance instance) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            if (instance.downloadSpeed != null)
              _buildStatRow(
                Icons.download,
                'Download Speed',
                _formatSpeed(instance.downloadSpeed!),
              ),
            if (instance.uploadSpeed != null)
              _buildStatRow(
                Icons.upload,
                'Upload Speed',
                _formatSpeed(instance.uploadSpeed!),
              ),
            if (instance.activeDownloads != null)
              _buildStatRow(
                Icons.downloading,
                'Active Downloads',
                '${instance.activeDownloads}',
              ),
            if (instance.totalDownloads != null)
              _buildStatRow(
                Icons.folder,
                'Total Downloads',
                '${instance.totalDownloads}',
              ),
            if (instance.freeSpace != null)
              _buildStatRow(
                Icons.storage,
                'Free Space',
                _formatBytes(instance.freeSpace!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstanceActions(
    BuildContext context,
    JDownloaderInstance instance,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showAddDownloadDialog(context, instance),
          icon: const Icon(Icons.add),
          label: const Text('Add Download'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            context
                .read<JDownloaderBloc>()
                .add(GetJDownloaderDownloadsEvent(instance.id));
          },
          icon: const Icon(Icons.list),
          label: const Text('View Downloads'),
        ),
        if (instance.status == JDownloaderStatus.downloading)
          ElevatedButton.icon(
            onPressed: () {
              context
                  .read<JDownloaderBloc>()
                  .add(PauseJDownloaderInstanceEvent(instance.id));
            },
            icon: const Icon(Icons.pause),
            label: const Text('Pause All'),
          ),
        if (instance.status == JDownloaderStatus.paused)
          ElevatedButton.icon(
            onPressed: () {
              context
                  .read<JDownloaderBloc>()
                  .add(ResumeJDownloaderInstanceEvent(instance.id));
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Resume All'),
          ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No JDownloader Instances',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a JDownloader instance to get started',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_download,
            size: 120,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 24),
          const Text(
            'JDownloader Integration',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(JDownloaderStatus status) {
    switch (status) {
      case JDownloaderStatus.online:
        return Colors.green;
      case JDownloaderStatus.downloading:
        return Colors.blue;
      case JDownloaderStatus.paused:
        return Colors.orange;
      case JDownloaderStatus.error:
        return Colors.red;
      case JDownloaderStatus.offline:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(JDownloaderStatus status) {
    switch (status) {
      case JDownloaderStatus.online:
        return Icons.cloud_done;
      case JDownloaderStatus.downloading:
        return Icons.cloud_download;
      case JDownloaderStatus.paused:
        return Icons.pause_circle;
      case JDownloaderStatus.error:
        return Icons.error;
      case JDownloaderStatus.offline:
        return Icons.cloud_off;
    }
  }

  String _formatSpeed(int bytesPerSecond) {
    const units = ['B/s', 'KB/s', 'MB/s', 'GB/s'];
    var value = bytesPerSecond.toDouble();
    var unitIndex = 0;

    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex++;
    }

    return '${value.toStringAsFixed(2)} ${units[unitIndex]}';
  }

  String _formatBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var value = bytes.toDouble();
    var unitIndex = 0;

    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex++;
    }

    return '${value.toStringAsFixed(2)} ${units[unitIndex]}';
  }

  void _showAddInstanceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final deviceIdController = TextEditingController();
    final hostController = TextEditingController();
    final portController = TextEditingController(text: '3129');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add JDownloader Instance'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Instance Name',
                  hintText: 'My JDownloader',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: deviceIdController,
                decoration: const InputDecoration(
                  labelText: 'Device ID',
                  hintText: 'device123',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: hostController,
                decoration: const InputDecoration(
                  labelText: 'Host (optional)',
                  hintText: 'localhost or IP address',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: portController,
                decoration: const InputDecoration(
                  labelText: 'Port (optional)',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  deviceIdController.text.isNotEmpty) {
                context.read<JDownloaderBloc>().add(
                      AddJDownloaderInstanceEvent(
                        name: nameController.text,
                        deviceId: deviceIdController.text,
                        host: hostController.text.isEmpty
                            ? null
                            : hostController.text,
                        port: portController.text.isEmpty
                            ? null
                            : int.tryParse(portController.text),
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditInstanceDialog(
    BuildContext context,
    JDownloaderInstance instance,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Instance'),
        content: Text('Editing: ${instance.name}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    JDownloaderInstance instance,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Instance?'),
        content: Text(
          'Are you sure you want to delete "${instance.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context
                  .read<JDownloaderBloc>()
                  .add(DeleteJDownloaderInstanceEvent(instance.id));
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddDownloadDialog(
    BuildContext context,
    JDownloaderInstance instance,
  ) {
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Download'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            labelText: 'URL',
            hintText: 'https://example.com/video',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (urlController.text.isNotEmpty) {
                context.read<JDownloaderBloc>().add(
                      AddJDownloaderDownloadEvent(
                        instanceId: instance.id,
                        url: urlController.text,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
