import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../core/constants/app_constants.dart';
import '../../core/di/injection.dart';
import '../bloc/download_bloc.dart';
import '../bloc/download_event.dart';
import '../bloc/download_state.dart';
import '../widgets/download_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/connection_status.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DownloadBloc>(),
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _urlController = TextEditingController();
  String _selectedQuality = AppConstants.defaultQuality;
  String _selectedFormat = AppConstants.defaultFormat;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveWrapper.of(context).isDesktop;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.download_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          // Connection status
          BlocBuilder<DownloadBloc, DownloadState>(
            builder: (context, state) {
              if (state is DownloadLoaded) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ConnectionStatus(isConnected: state.isConnected),
                );
              }
              return const SizedBox.shrink();
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
              _showSnackBar(context, 'Settings coming soon!');
            },
          ),
          const SizedBox(width: 8),
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
            _showSnackBar(context, state.message, isError: true);
          } else if (state is DownloadLoaded && state.message != null) {
            _showSnackBar(context, state.message!);
          }
        },
        builder: (context, state) {
          if (state is DownloadLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Add Download Section
              _buildAddDownloadSection(context, isDesktop),

              const Divider(height: 1),

              // Downloads List
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDownloadsList(context, 'queue', state),
                    _buildDownloadsList(context, 'completed', state),
                    _buildDownloadsList(context, 'pending', state),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddDownloadSection(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Download',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              if (isDesktop)
                _buildDesktopAddForm(context)
              else
                _buildMobileAddForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopAddForm(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Video URL',
              hintText: 'https://youtube.com/watch?v=...',
              prefixIcon: Icon(Icons.link),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedQuality,
            decoration: const InputDecoration(
              labelText: 'Quality',
              prefixIcon: Icon(Icons.high_quality),
            ),
            items: AppConstants.qualityOptions.map((quality) {
              return DropdownMenuItem(
                value: quality,
                child: Text(quality),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedQuality = value!;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedFormat,
            decoration: const InputDecoration(
              labelText: 'Format',
              prefixIcon: Icon(Icons.video_file),
            ),
            items: AppConstants.formatOptions.map((format) {
              return DropdownMenuItem(
                value: format,
                child: Text(format.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedFormat = value!;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        FilledButton.icon(
          onPressed: () => _handleAddDownload(context),
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildMobileAddForm(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            labelText: 'Video URL',
            hintText: 'https://youtube.com/watch?v=...',
            prefixIcon: Icon(Icons.link),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedQuality,
                decoration: const InputDecoration(
                  labelText: 'Quality',
                  prefixIcon: Icon(Icons.high_quality),
                ),
                items: AppConstants.qualityOptions.map((quality) {
                  return DropdownMenuItem(
                    value: quality,
                    child: Text(quality),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedQuality = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedFormat,
                decoration: const InputDecoration(
                  labelText: 'Format',
                  prefixIcon: Icon(Icons.video_file),
                ),
                items: AppConstants.formatOptions.map((format) {
                  return DropdownMenuItem(
                    value: format,
                    child: Text(format.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFormat = value!;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _handleAddDownload(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Download'),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadsList(
      BuildContext context, String type, DownloadState state) {
    if (state is! DownloadLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final downloads = _getDownloadsForType(type, state);

    if (downloads.isEmpty) {
      return EmptyState(
        icon: _getIconForType(type),
        title: _getTitleForType(type),
        subtitle: _getSubtitleForType(type),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final download = downloads[index];
        return DownloadCard(
          download: download,
          onStart: download.isPending
              ? () {
                  context
                      .read<DownloadBloc>()
                      .add(StartDownload(download.id));
                }
              : null,
          onCancel: download.isActive
              ? () {
                  context
                      .read<DownloadBloc>()
                      .add(CancelDownload(download.id));
                }
              : null,
          onDelete: () {
            context.read<DownloadBloc>().add(DeleteDownload(download.id));
          },
        );
      },
    );
  }

  List _getDownloadsForType(String type, DownloadLoaded state) {
    switch (type) {
      case 'queue':
        return state.activeDownloads;
      case 'completed':
        return state.completedDownloads;
      case 'pending':
        return state.pendingDownloads;
      default:
        return [];
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'queue':
        return Icons.download;
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.inbox;
    }
  }

  String _getTitleForType(String type) {
    switch (type) {
      case 'queue':
        return 'No Active Downloads';
      case 'completed':
        return 'No Completed Downloads';
      case 'pending':
        return 'No Pending Downloads';
      default:
        return 'No Downloads';
    }
  }

  String _getSubtitleForType(String type) {
    switch (type) {
      case 'queue':
        return 'Downloads will appear here once started';
      case 'completed':
        return 'Completed downloads will be shown here';
      case 'pending':
        return 'Queued downloads waiting to start';
      default:
        return '';
    }
  }

  void _handleAddDownload(BuildContext context) {
    final url = _urlController.text.trim();

    if (url.isEmpty) {
      _showSnackBar(context, 'Please enter a URL', isError: true);
      return;
    }

    context.read<DownloadBloc>().add(AddDownload(
          url: url,
          quality: _selectedQuality,
          format: _selectedFormat,
        ));

    _urlController.clear();
    _showSnackBar(context, 'Download added');
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        duration: AppConstants.snackBarDuration,
      ),
    );
  }
}
