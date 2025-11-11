import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/search_parameters.dart';
import '../../domain/entities/search_result.dart';
import '../blocs/search/search_bloc.dart';
import '../blocs/search/search_event.dart';
import '../blocs/search/search_state.dart';
import '../widgets/download_list_item.dart';
import '../widgets/grabtube_progress_indicator.dart';
import '../blocs/download/download_bloc.dart';
import '../blocs/download/download_event.dart';

/// Search page for filtering and searching downloads
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  String _sortBy = 'title';
  String _sortOrder = 'asc';
  bool _favoritesOnly = false;

  // Advanced filter fields
  List<String> _selectedStatuses = [];
  List<String> _selectedFormats = [];
  String? _selectedQuality;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      // Load more when near bottom
      context.read<SearchBloc>().add(const LoadMoreSearchResultsEvent());
    }
  }

  void _performSearch() {
    final parameters = SearchParameters(
      query: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      favoritesOnly: _favoritesOnly,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
      page: 1,
      pageSize: 20,
    );

    context.read<SearchBloc>().add(PerformSearchEvent(parameters));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Downloads'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              context.read<SearchBloc>().add(const LoadSearchHistoryEvent());
              _showSearchHistoryDialog(context);
            },
            tooltip: 'Search History',
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _showFiltersDialog(context),
            tooltip: 'Advanced Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: BlocConsumer<SearchBloc, SearchState>(
              listener: (context, state) {
                if (state is SearchFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is SearchLoading) {
                  return _buildLoadingShimmer();
                }

                if (state is SearchSuccess || state is SearchMoreResultsLoaded) {
                  final result = state is SearchSuccess
                      ? state.result
                      : (state as SearchMoreResultsLoaded).result;

                  if (result.downloads.isEmpty) {
                    return _buildEmptyView();
                  }

                  return _buildResultsList(context, result);
                }

                return _buildInitialView();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search downloads...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onSubmitted: (_) => _performSearch(),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Favorites Only'),
            selected: _favoritesOnly,
            onSelected: (selected) {
              setState(() {
                _favoritesOnly = selected;
              });
              _performSearch();
            },
            avatar: _favoritesOnly
                ? const Icon(Icons.favorite, size: 18)
                : const Icon(Icons.favorite_border, size: 18),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: Text('Sort: $_sortBy'),
            selected: true,
            onSelected: (_) => _showSortDialog(context),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: Text(_sortOrder == 'asc' ? 'Ascending' : 'Descending'),
            selected: true,
            onSelected: (_) {
              setState(() {
                _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc';
              });
              _performSearch();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, SearchResult result) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: result.downloads.length + (result.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= result.downloads.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final download = result.downloads[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: AnimatedListItem(
            index: index,
            child: DownloadListItem(
              download: download,
              onDelete: () {
                context.read<DownloadBloc>().add(
                      DeleteDownloadEvent(download.id),
                    );
              },
              onStart: download.status.name.toLowerCase() == 'pending'
                  ? () {
                      context.read<DownloadBloc>().add(
                            StartDownloadEvent(download.id),
                          );
                    }
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail shimmer
                  ShimmerLoading(
                    width: 120,
                    height: 68,
                    borderRadius: 8,
                  ),
                  const SizedBox(width: 12),
                  // Content shimmer
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerLoading(
                          width: double.infinity,
                          height: 20,
                          borderRadius: 4,
                        ),
                        const SizedBox(height: 8),
                        ShimmerLoading(
                          width: 150,
                          height: 16,
                          borderRadius: 4,
                        ),
                        const SizedBox(height: 8),
                        ShimmerLoading(
                          width: 100,
                          height: 16,
                          borderRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInitialView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 120,
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'Search Your Downloads',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.0),
            child: Text(
              'Enter a search query above or use filters to find specific downloads',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
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
          const Icon(
            Icons.search_off,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Results Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search or filters',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Title'),
              value: 'title',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.pop(context);
                _performSearch();
              },
            ),
            RadioListTile<String>(
              title: const Text('Date'),
              value: 'date',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.pop(context);
                _performSearch();
              },
            ),
            RadioListTile<String>(
              title: const Text('Status'),
              value: 'status',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.pop(context);
                _performSearch();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFiltersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Advanced Filters'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Filter
                  const Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['downloading', 'completed', 'pending', 'error', 'canceled']
                        .map((status) => FilterChip(
                              label: Text(status[0].toUpperCase() + status.substring(1)),
                              selected: _selectedStatuses.contains(status),
                              onSelected: (selected) {
                                setDialogState(() {
                                  if (selected) {
                                    _selectedStatuses.add(status);
                                  } else {
                                    _selectedStatuses.remove(status);
                                  }
                                });
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // Format Filter
                  const Text(
                    'Format',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['mp4', 'webm', 'mkv', 'm4a', 'mp3', 'flac']
                        .map((format) => FilterChip(
                              label: Text(format.toUpperCase()),
                              selected: _selectedFormats.contains(format),
                              onSelected: (selected) {
                                setDialogState(() {
                                  if (selected) {
                                    _selectedFormats.add(format);
                                  } else {
                                    _selectedFormats.remove(format);
                                  }
                                });
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // Quality Filter
                  const Text(
                    'Quality',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['4K', '1080p', '720p', '480p', '360p', 'best', 'worst']
                        .map((quality) => ChoiceChip(
                              label: Text(quality),
                              selected: _selectedQuality == quality,
                              onSelected: (selected) {
                                setDialogState(() {
                                  _selectedQuality = selected ? quality : null;
                                });
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // Date Range Filter
                  const Text(
                    'Date Range',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: _dateRange,
                      );
                      if (picked != null) {
                        setDialogState(() {
                          _dateRange = picked;
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _dateRange == null
                          ? 'Select Date Range'
                          : '${_dateRange!.start.toString().split(' ')[0]} - ${_dateRange!.end.toString().split(' ')[0]}',
                    ),
                  ),
                  if (_dateRange != null) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        setDialogState(() {
                          _dateRange = null;
                        });
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear Date Range'),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Reset all filters
                  setState(() {
                    _selectedStatuses.clear();
                    _selectedFormats.clear();
                    _selectedQuality = null;
                    _dateRange = null;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Reset'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {});
                  _performSearch();
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSearchHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search History'),
        content: SizedBox(
          width: double.maxFinite,
          child: BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              if (state is SearchHistoryLoaded) {
                if (state.history.isEmpty) {
                  return const Center(child: Text('No search history'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.history.length,
                  itemBuilder: (context, index) {
                    final params = state.history[index];
                    return ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(params.query ?? 'All Downloads'),
                      subtitle: Text(
                        'Sort: ${params.sortBy} (${params.sortOrder})',
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        context
                            .read<SearchBloc>()
                            .add(ApplyHistorySearchEvent(params));
                      },
                    );
                  },
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<SearchBloc>().add(const ClearSearchHistoryEvent());
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
