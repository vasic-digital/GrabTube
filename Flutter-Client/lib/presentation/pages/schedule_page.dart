import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/di/injection.dart';
import '../../domain/entities/download_schedule.dart';
import '../blocs/schedule/schedule_bloc.dart';
import '../blocs/schedule/schedule_event.dart';
import '../blocs/schedule/schedule_state.dart';
import '../widgets/grabtube_progress_indicator.dart';

/// Page for managing scheduled downloads
class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ScheduleBloc>()..add(const LoadSchedulesEvent()),
      child: const _SchedulePageContent(),
    );
  }
}

class _SchedulePageContent extends StatefulWidget {
  const _SchedulePageContent();

  @override
  State<_SchedulePageContent> createState() => _SchedulePageContentState();
}

class _SchedulePageContentState extends State<_SchedulePageContent> {
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    // Update countdown every second
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduled Downloads'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<ScheduleBloc>().add(const LoadSchedulesEvent());
            },
          ),
        ],
      ),
      body: BlocConsumer<ScheduleBloc, ScheduleState>(
        listener: (context, state) {
          if (state is ScheduleFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: colorScheme.error,
              ),
            );
          } else if (state is ScheduleCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Schedule created successfully'),
                backgroundColor: colorScheme.primary,
              ),
            );
          } else if (state is ScheduleDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Schedule deleted')),
            );
          } else if (state is ScheduleExecuted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Schedule executed')),
            );
          }
        },
        builder: (context, state) {
          if (state is ScheduleLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GrabTubeProgressIndicator(
                    progress: 0.5,
                    size: 80,
                    isAnimating: true,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading schedules...',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          if (state is ScheduleLoaded) {
            if (state.schedules.isEmpty) {
              return _buildEmptyState(context);
            }

            // Group schedules by status
            final pendingSchedules = state.schedules
                .where((s) => s.status == ScheduleStatus.pending)
                .toList()
              ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

            final executingSchedules = state.schedules
                .where((s) => s.status == ScheduleStatus.executing)
                .toList();

            final completedSchedules = state.schedules
                .where((s) => s.status == ScheduleStatus.completed)
                .toList()
              ..sort((a, b) =>
                  (b.completedAt ?? DateTime.now())
                      .compareTo(a.completedAt ?? DateTime.now()));

            final failedSchedules = state.schedules
                .where((s) => s.status == ScheduleStatus.failed)
                .toList();

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ScheduleBloc>().add(const LoadSchedulesEvent());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (executingSchedules.isNotEmpty) ...[
                    _buildSectionHeader(context, 'Executing', executingSchedules.length),
                    ...executingSchedules.map((s) => _ScheduleListItem(schedule: s)),
                    const SizedBox(height: 16),
                  ],
                  if (pendingSchedules.isNotEmpty) ...[
                    _buildSectionHeader(context, 'Upcoming', pendingSchedules.length),
                    ...pendingSchedules.map((s) => _ScheduleListItem(schedule: s)),
                    const SizedBox(height: 16),
                  ],
                  if (failedSchedules.isNotEmpty) ...[
                    _buildSectionHeader(context, 'Failed', failedSchedules.length),
                    ...failedSchedules.map((s) => _ScheduleListItem(schedule: s)),
                    const SizedBox(height: 16),
                  ],
                  if (completedSchedules.isNotEmpty) ...[
                    _buildSectionHeader(context, 'Completed', completedSchedules.length),
                    ...completedSchedules.take(10).map((s) => _ScheduleListItem(schedule: s)),
                  ],
                ],
              ),
            );
          }

          return _buildEmptyState(context);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateScheduleDialog(context),
        icon: const Icon(Icons.schedule),
        label: const Text('Schedule'),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            size: 120,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No Scheduled Downloads',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Schedule downloads to run at a specific time',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => _showCreateScheduleDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Schedule'),
          ),
        ],
      ),
    );
  }

  void _showCreateScheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => _CreateScheduleDialog(
        onScheduleCreated: (schedule) {
          context.read<ScheduleBloc>().add(CreateScheduleEvent(schedule));
        },
      ),
    );
  }
}

class _ScheduleListItem extends StatelessWidget {
  const _ScheduleListItem({required this.schedule});

  final DownloadSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildStatusIcon(context),
        title: Text(
          schedule.title ?? schedule.url,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              schedule.url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            _buildScheduleInfo(context),
            if (schedule.quality != null || schedule.format != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    if (schedule.quality != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          schedule.quality!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    if (schedule.quality != null && schedule.format != null)
                      const SizedBox(width: 4),
                    if (schedule.format != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          schedule.format!.toUpperCase(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
        trailing: _buildActions(context),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (schedule.status) {
      case ScheduleStatus.pending:
        return Icon(
          Icons.schedule,
          color: colorScheme.primary,
          size: 32,
        );
      case ScheduleStatus.executing:
        return SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: colorScheme.primary,
          ),
        );
      case ScheduleStatus.completed:
        return Icon(
          Icons.check_circle,
          color: colorScheme.tertiary,
          size: 32,
        );
      case ScheduleStatus.failed:
        return Icon(
          Icons.error,
          color: colorScheme.error,
          size: 32,
        );
      case ScheduleStatus.canceled:
        return Icon(
          Icons.cancel,
          color: colorScheme.onSurface.withOpacity(0.5),
          size: 32,
        );
    }
  }

  Widget _buildScheduleInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (schedule.status == ScheduleStatus.completed) {
      final completedAt = schedule.completedAt ?? DateTime.now();
      return Text(
        'Completed ${_formatRelativeTime(completedAt)}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.tertiary,
        ),
      );
    }

    if (schedule.status == ScheduleStatus.failed) {
      return Text(
        'Failed: ${schedule.error ?? "Unknown error"}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.error,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (schedule.status == ScheduleStatus.executing) {
      return Text(
        'Executing now...',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    // Pending status - show countdown
    final now = DateTime.now();
    final scheduledTime = schedule.scheduledTime;
    final difference = scheduledTime.difference(now);

    String countdownText;
    if (difference.isNegative) {
      countdownText = 'Due now';
    } else if (difference.inDays > 0) {
      countdownText = 'In ${difference.inDays}d ${difference.inHours % 24}h';
    } else if (difference.inHours > 0) {
      countdownText = 'In ${difference.inHours}h ${difference.inMinutes % 60}m';
    } else if (difference.inMinutes > 0) {
      countdownText = 'In ${difference.inMinutes}m ${difference.inSeconds % 60}s';
    } else {
      countdownText = 'In ${difference.inSeconds}s';
    }

    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 14,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(
          countdownText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          DateFormat('MMM d, h:mm a').format(scheduledTime),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        if (schedule.isRepeating) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.repeat,
            size: 14,
            color: colorScheme.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            _formatRepeatInterval(schedule.repeatInterval!),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.secondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return PopupMenuButton<String>(
      itemBuilder: (context) => [
        if (schedule.status == ScheduleStatus.pending)
          const PopupMenuItem(
            value: 'execute',
            child: Row(
              children: [
                Icon(Icons.play_arrow),
                SizedBox(width: 8),
                Text('Execute Now'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete),
              SizedBox(width: 8),
              Text('Delete'),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'delete') {
          _confirmDelete(context);
        } else if (value == 'execute') {
          context.read<ScheduleBloc>().add(ExecuteScheduleEvent(schedule.id));
        }
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ScheduleBloc>().add(DeleteScheduleEvent(schedule.id));
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  String _formatRepeatInterval(RepeatInterval interval) {
    switch (interval) {
      case RepeatInterval.daily:
        return 'Daily';
      case RepeatInterval.weekly:
        return 'Weekly';
      case RepeatInterval.monthly:
        return 'Monthly';
    }
  }
}

class _CreateScheduleDialog extends StatefulWidget {
  const _CreateScheduleDialog({required this.onScheduleCreated});

  final void Function(DownloadSchedule) onScheduleCreated;

  @override
  State<_CreateScheduleDialog> createState() => _CreateScheduleDialogState();
}

class _CreateScheduleDialogState extends State<_CreateScheduleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();

  DateTime _scheduledDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _scheduledTime = TimeOfDay.now();
  String? _quality;
  String? _format;
  RepeatInterval? _repeatInterval;

  final _qualities = ['best', '1080p', '720p', '480p', '360p'];
  final _formats = ['mp4', 'webm', 'mkv', 'mp3', 'm4a'];

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Schedule Download'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Video URL *',
                  hintText: 'https://www.youtube.com/watch?v=...',
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title (optional)',
                  hintText: 'My video',
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Scheduled Time',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(DateFormat('MMM d, y').format(_scheduledDate)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectTime(context),
                      icon: const Icon(Icons.access_time),
                      label: Text(_scheduledTime.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Quality (optional)',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _quality,
                decoration: const InputDecoration(
                  hintText: 'Select quality',
                  prefixIcon: Icon(Icons.high_quality),
                ),
                items: _qualities.map((q) => DropdownMenuItem(
                  value: q,
                  child: Text(q),
                )).toList(),
                onChanged: (value) => setState(() => _quality = value),
              ),
              const SizedBox(height: 16),
              Text(
                'Format (optional)',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _format,
                decoration: const InputDecoration(
                  hintText: 'Select format',
                  prefixIcon: Icon(Icons.video_file),
                ),
                items: _formats.map((f) => DropdownMenuItem(
                  value: f,
                  child: Text(f.toUpperCase()),
                )).toList(),
                onChanged: (value) => setState(() => _format = value),
              ),
              const SizedBox(height: 24),
              Text(
                'Repeat (optional)',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<RepeatInterval>(
                value: _repeatInterval,
                decoration: const InputDecoration(
                  hintText: 'No repeat',
                  prefixIcon: Icon(Icons.repeat),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('No repeat'),
                  ),
                  ...RepeatInterval.values.map((i) => DropdownMenuItem(
                    value: i,
                    child: Text(_formatRepeatInterval(i)),
                  )),
                ],
                onChanged: (value) => setState(() => _repeatInterval = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _createSchedule,
          child: const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _scheduledDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime,
    );

    if (picked != null) {
      setState(() => _scheduledTime = picked);
    }
  }

  void _createSchedule() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final scheduledDateTime = DateTime(
      _scheduledDate.year,
      _scheduledDate.month,
      _scheduledDate.day,
      _scheduledTime.hour,
      _scheduledTime.minute,
    );

    final schedule = DownloadSchedule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      url: _urlController.text.trim(),
      scheduledTime: scheduledDateTime,
      status: ScheduleStatus.pending,
      title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
      quality: _quality,
      format: _format,
      repeatInterval: _repeatInterval,
    );

    widget.onScheduleCreated(schedule);
    Navigator.pop(context);
  }

  String _formatRepeatInterval(RepeatInterval interval) {
    switch (interval) {
      case RepeatInterval.daily:
        return 'Daily';
      case RepeatInterval.weekly:
        return 'Weekly';
      case RepeatInterval.monthly:
        return 'Monthly';
    }
  }
}
