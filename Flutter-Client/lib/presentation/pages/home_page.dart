import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/di/injection.dart';
import '../blocs/download/download_bloc.dart';
import '../blocs/download/download_event.dart';
import '../blocs/download/download_state.dart';
import '../blocs/jdownloader/jdownloader_bloc.dart';
import '../blocs/search/search_bloc.dart';
import '../blocs/qr_scanner/qr_scanner_bloc.dart';
import '../blocs/favorites/favorites_bloc.dart';
import '../blocs/schedule/schedule_bloc.dart';
import '../widgets/download_list_item.dart';
import '../widgets/add_download_dialog.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/adaptive_qr_scanner.dart';
import 'history_page.dart';
import 'search_page.dart';
import 'jdownloader_page.dart';
import 'favorites_page.dart';
import 'schedule_page.dart';
import 'settings_page.dart';

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
      drawer: _buildNavigationDrawer(context),
      appBar: AppBar(
        title: const Text(
          AppConstants.appName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search & Favorites',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => getIt<SearchBloc>(),
                    child: const SearchPage(),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.cloud_download),
            tooltip: 'My JDownloader',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<JDownloaderBloc>(),
                    child: const JDownloaderPage(),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<DownloadBloc>(),
                    child: const HistoryPage(),
                  ),
                ),
              );
            },
          ),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () => _showAddDownloadDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Download'),
            heroTag: "addDownload",
          ),
          const SizedBox(width: 16),
          FloatingActionButton.extended(
            onPressed: () => _showQRScanner(context),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan QR'),
            backgroundColor: const Color(0xFFE74C3C),
            foregroundColor: Colors.white,
            heroTag: "scanQR",
          ),
        ],
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

  void _showQRScanner(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdaptiveQRScanner(
          onUrlScanned: (url) {
            Navigator.of(context).pop();
            _showAddDownloadDialogWithUrl(context, url);
          },
        ),
      ),
    );
  }

  void _showAddDownloadDialogWithUrl(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<DownloadBloc>(),
        child: AddDownloadDialog(initialUrl: url),
      ),
    );
  }

  Widget _buildNavigationDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.download,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Multi-platform downloader',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // Close drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => getIt<FavoritesBloc>(),
                    child: const FavoritesPage(),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Scheduled Downloads'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => getIt<ScheduleBloc>(),
                    child: const SchedulePage(),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('QR Scanner'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => getIt<QRScannerBloc>(),
                    child: const QRScannerPage(),
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search & Filter'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => getIt<SearchBloc>(),
                    child: const SearchPage(),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('History'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<DownloadBloc>(),
                    child: const HistoryPage(),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_download),
            title: const Text('JDownloader'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<JDownloaderBloc>(),
                    child: const JDownloaderPage(),
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
