import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../blocs/download/download_bloc.dart';
import '../blocs/download/download_event.dart';
import '../blocs/download/download_state.dart';
import '../widgets/download_list_item.dart';
import '../widgets/add_download_dialog.dart';
import '../widgets/empty_state_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load downloads on init
    context.read<DownloadBloc>().add(const LoadDownloads());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppConstants.appName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<DownloadBloc>().add(const RefreshDownloads());
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Queue', icon: Icon(Icons.download)),
            Tab(text: 'Completed', icon: Icon(Icons.check_circle)),
            Tab(text: 'Pending', icon: Icon(Icons.pending)),
          ],
        ),
      ),
      body: BlocConsumer<DownloadBloc, DownloadState>(
        listener: (context, state) {
          if (state is DownloadError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                duration: AppConstants.snackBarDuration,
              ),
            );
          } else if (state is DownloadOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.primary,
                duration: AppConstants.snackBarDuration,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DownloadLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DownloadsLoaded) {
            return Column(
              children: [
                // Connection status banner
                if (!state.isConnected)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_off,
                          size: 16,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Disconnected from server',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Stats bar
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        context,
                        'Active',
                        state.activeCount,
                        Icons.downloading,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        context,
                        'Pending',
                        state.pendingCount,
                        Icons.pending,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        context,
                        'Completed',
                        state.completedCount,
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ],
                  ),
                ),

                // Downloads list
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDownloadsList(state.queue, 'queue'),
                      _buildDownloadsList(state.completed, 'done'),
                      _buildDownloadsList(state.pending, 'pending'),
                    ],
                  ),
                ),
              ],
            );
          }

          return const EmptyStateWidget(
            icon: Icons.download,
            title: 'No downloads yet',
            subtitle: 'Tap the + button to add a download',
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDownloadDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Download'),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    int value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadsList(List<dynamic> downloads, String where) {
    if (downloads.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.inbox,
        title: 'No downloads',
        subtitle: where == 'queue'
            ? 'Active downloads will appear here'
            : where == 'done'
                ? 'Completed downloads will appear here'
                : 'Pending downloads will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DownloadBloc>().add(const RefreshDownloads());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: downloads.length,
        itemBuilder: (context, index) {
          return DownloadListItem(
            download: downloads[index],
            onDelete: () {
              context.read<DownloadBloc>().add(
                    DeleteDownloads(
                      ids: [downloads[index].id],
                      where: where,
                    ),
                  );
            },
            onStart: where == 'pending'
                ? () {
                    context.read<DownloadBloc>().add(
                          StartDownloads(ids: [downloads[index].id]),
                        );
                  }
                : null,
          );
        },
      ),
    );
  }

  void _showAddDownloadDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<DownloadBloc>(),
        child: const AddDownloadDialog(),
      ),
    );
  }
}
