import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/schedule.dart';
import '../blocs/schedule/schedule_bloc.dart';
import '../blocs/schedule/schedule_event.dart';
import '../blocs/schedule/schedule_state.dart';

/// Schedule page for managing download schedules
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<ScheduleBloc>().add(const LoadSchedulesEvent());
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
        title: const Text('Schedules'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.schedule)),
            Tab(text: 'Active', icon: Icon(Icons.check_circle)),
            Tab(text: 'Inactive', icon: Icon(Icons.cancel)),
          ],
        ),
      ),
      body: BlocConsumer<ScheduleBloc, ScheduleState>(
        listener: (context, state) {
          if (state is ScheduleFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ScheduleCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Schedule created successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ScheduleDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Schedule deleted'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildSchedulesList(context, state, showAll: true),
              _buildSchedulesList(context, state, activeOnly: true),
              _buildSchedulesList(context, state, inactiveOnly: true),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateScheduleDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Schedule'),
      ),
    );
  }

  Widget _buildSchedulesList(
    BuildContext context,
    ScheduleState state, {
    bool showAll = false,
    bool activeOnly = false,
    bool inactiveOnly = false,
  }) {
    if (state is SchedulesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Schedule> schedules = [];

    if (state is SchedulesLoaded) {
      schedules = state.schedules;
    } else if (state is ActiveSchedulesLoaded) {
      schedules = state.schedules;
    }

    if (!showAll) {
      if (activeOnly) {
        schedules = schedules.where((s) => s.isActive).toList();
      } else if (inactiveOnly) {
        schedules = schedules.where((s) => !s.isActive).toList();
      }
    }

    if (schedules.isEmpty) {
      return _buildEmptyView(
        activeOnly ? 'No Active Schedules' : 'No Schedules',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ScheduleBloc>().add(const LoadSchedulesEvent());
      },
      child: ListView.builder(
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final schedule = schedules[index];
          return _buildScheduleCard(context, schedule);
        },
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, Schedule schedule) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: schedule.isActive ? Colors.green : Colors.grey,
          child: Icon(
            _getScheduleTypeIcon(schedule.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          schedule.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _getScheduleDescription(schedule),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Switch(
          value: schedule.isActive,
          onChanged: (value) {
            context
                .read<ScheduleBloc>()
                .add(ToggleScheduleEvent(schedule.id));
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (schedule.description != null) ...[
                  Text(
                    schedule.description!,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                ],
                _buildScheduleDetails(schedule),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showEditScheduleDialog(context, schedule),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showDeleteConfirmation(context, schedule),
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

  Widget _buildScheduleDetails(Schedule schedule) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Type', schedule.type.name.toUpperCase()),
        if (schedule.startDate != null)
          _buildDetailRow('Start Date', schedule.startDate.toString()),
        if (schedule.recurrencePattern != null)
          _buildDetailRow('Pattern', schedule.recurrencePattern!.name),
        if (schedule.lastExecutedAt != null)
          _buildDetailRow('Last Executed', schedule.lastExecutedAt.toString()),
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

  Widget _buildEmptyView(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a schedule to automate downloads',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  IconData _getScheduleTypeIcon(ScheduleType type) {
    switch (type) {
      case ScheduleType.oneTime:
        return Icons.event;
      case ScheduleType.recurring:
        return Icons.repeat;
      case ScheduleType.periodic:
        return Icons.timer;
      case ScheduleType.collection:
        return Icons.collections;
    }
  }

  String _getScheduleDescription(Schedule schedule) {
    final buffer = StringBuffer();

    buffer.write('${schedule.type.name.toUpperCase()}');

    if (schedule.recurrencePattern != null) {
      buffer.write(' • ${schedule.recurrencePattern!.name}');
    }

    if (!schedule.isActive) {
      buffer.write(' • INACTIVE');
    }

    return buffer.toString();
  }

  void _showCreateScheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Schedule'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Schedule creation form coming soon'),
              // Form widgets would go here
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
              // Create schedule logic here
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditScheduleDialog(BuildContext context, Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Schedule'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Editing: ${schedule.name}'),
              const SizedBox(height: 16),
              const Text('Edit form coming soon'),
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
              // Update schedule logic here
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule?'),
        content: Text(
          'Are you sure you want to delete "${schedule.name}"? This action cannot be undone.',
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
                  .read<ScheduleBloc>()
                  .add(DeleteScheduleEvent(schedule.id));
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
