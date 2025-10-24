# Scheduling Features Documentation

## Overview

The GrabTube application now includes comprehensive scheduling functionality that allows users to automate their download tasks. Users can create schedules for one-time downloads, recurring downloads, periodic tasks, and collection downloads. This feature enables hands-free downloading of content at specified times or intervals.

## Features

### Schedule Types

#### 1. One-Time Schedules
- Execute a download once at a specific date and time
- Perfect for scheduling downloads for later viewing
- Supports all download parameters (quality, format, folder, etc.)

#### 2. Recurring Schedules
- **Daily**: Execute every day at the same time
- **Weekly**: Execute on selected days of the week
- **Monthly**: Execute on the same day each month
- **Yearly**: Execute on the same date each year

#### 3. Periodic Schedules
- Execute at regular intervals
- Support for minutes, hours, days, weeks, and months
- Flexible timing for various use cases

#### 4. Collection Schedules
- Download entire video collections periodically
- Support for playlists, channels, and other collections
- Automatic discovery of new content

### Advanced Features

#### Schedule Management
- Enable/disable schedules without deletion
- Edit existing schedules
- View execution history and statistics
- Manual execution of schedules
- Automatic cleanup of old execution records

#### Execution Control
- Configurable execution limits
- End dates for recurring schedules
- Tolerance windows for execution timing
- Error handling and retry logic
- Concurrent execution support

#### Monitoring & Analytics
- Real-time execution statistics
- Success/failure tracking
- Performance metrics
- Schedule health monitoring

## Implementation Details

### Core Models

#### Schedule Entity
```dart
class Schedule {
  final String id;
  final String name;
  final String description;
  final ScheduleType type;
  final DateTime? startDate;
  final DateTime? startTime;
  final RecurrencePattern? recurrencePattern;
  final List<WeekDay>? weekDays;
  final int? dayOfMonth;
  final int? interval;
  final TimeUnit? timeUnit;
  final DateTime? endDate;
  final int? maxExecutions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastExecutedAt;
  final DateTime? nextExecutionAt;
  final int executionCount;
  final Map<String, dynamic>? metadata;
}
```

#### ScheduledDownload Entity
```dart
class ScheduledDownload {
  final String id;
  final String scheduleId;
  final String downloadId;
  final DateTime scheduledAt;
  final DateTime? executedAt;
  final bool isExecuted;
  final bool isSuccessful;
  final String? errorMessage;
  final Map<String, dynamic>? result;
}
```

### Schedule Calculation Engine

#### Next Execution Calculation
The system calculates the next execution time based on schedule type:

```dart
DateTime? calculateNextExecution({DateTime? from}) {
  switch (type) {
    case ScheduleType.oneTime:
      return calculateOneTimeNextExecution(from);
    case ScheduleType.recurring:
      return calculateRecurringNextExecution(from);
    case ScheduleType.periodic:
      return calculatePeriodicNextExecution(from);
    case ScheduleType.collection:
      return calculatePeriodicNextExecution(from);
  }
}
```

#### Execution Timing
- **Precision**: 1-minute tolerance window for execution
- **Time Zones**: Automatic handling of system timezone changes
- **DST**: Automatic adjustment for daylight saving time
- **Leap Years**: Proper handling of February 29th in yearly schedules

### Repository Layer

#### ScheduleRepository Interface
```dart
interface ScheduleRepository {
  Stream<List<Schedule>> observeSchedules();
  Stream<List<Schedule>> observeActiveSchedules();
  Future<List<Schedule>> getAllSchedules();
  Future<Schedule?> getScheduleById(String id);
  Future<Schedule> createSchedule(Schedule schedule);
  Future<Schedule> updateSchedule(Schedule schedule);
  Future<void> deleteSchedule(String id);
  Future<void> toggleSchedule(String id, bool isActive);
  Future<List<Schedule>> getSchedulesToExecute();
  Future<void> markScheduleExecuted(String id);
  Future<List<ScheduledDownload>> getScheduledDownloads(String scheduleId);
  Future<Map<String, DateTime?>> getNextExecutionTimes();
}
```

#### ScheduleExecutionService
```dart
interface ScheduleExecutionService {
  Future<void> start();
  Future<void> stop();
  Future<void> checkAndExecuteSchedules();
  Future<void> executeScheduleNow(String scheduleId);
  Future<Map<String, dynamic>> getExecutionStats();
}
```

### UI Components

#### Flutter Client

##### SchedulesPage
Main schedules management interface with:
- Tabbed view (All/Active schedules)
- Schedule list with execution status
- Quick actions (toggle, execute, history)
- Create/edit schedule dialogs

##### ScheduleCreateDialog
Comprehensive schedule creation/editing with:
- Schedule type selection
- Date/time pickers
- Recurrence configuration
- Download parameter settings
- Advanced options

##### ScheduleListItem
Individual schedule display with:
- Schedule details and status
- Next execution time
- Action buttons
- Visual indicators

#### Web Client

##### Schedule Management Section
- Collapsible schedule panel
- Statistics display
- Schedule list with inline actions
- Modal dialogs for creation/editing

#### Android Client

##### Schedule Management Screens
- Native Android schedule list
- Material Design schedule creation
- Execution history views
- Settings and preferences

## Usage Examples

### Creating Schedules

#### One-Time Schedule
```dart
final schedule = Schedule.oneTime(
  id: 'movie-night',
  name: 'Movie Night Download',
  executeAt: DateTime(2024, 1, 20, 19, 0), // Jan 20, 7:00 PM
  metadata: {
    'url': 'https://example.com/movie',
    'quality': '1080p',
    'format': 'mp4',
  },
);
```

#### Daily Schedule
```dart
final schedule = Schedule.daily(
  id: 'daily-news',
  name: 'Daily News Summary',
  startTime: DateTime(0, 0, 0, 8, 0), // 8:00 AM daily
  metadata: {
    'url': 'https://news.example.com/daily',
    'quality': '720p',
  },
);
```

#### Weekly Schedule
```dart
final schedule = Schedule.weekly(
  id: 'weekly-podcast',
  name: 'Weekly Podcast',
  startTime: DateTime(0, 0, 0, 10, 0), // 10:00 AM
  weekDays: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
  metadata: {
    'url': 'https://podcast.example.com/latest',
  },
);
```

#### Collection Schedule
```dart
final schedule = Schedule.collection(
  id: 'youtube-channel',
  name: 'YouTube Channel Monitor',
  interval: 6,
  timeUnit: TimeUnit.hours,
  collectionUrl: 'https://youtube.com/channel/UC123',
  metadata: {
    'quality': 'best',
    'format': 'mp4',
  },
);
```

### Managing Schedules

#### Starting the Execution Service
```dart
await scheduleExecutionService.start();
```

#### Manual Execution
```dart
await scheduleExecutionService.executeScheduleNow('schedule-id');
```

#### Monitoring Execution
```dart
final stats = await scheduleExecutionService.getExecutionStats();
print('Active schedules: ${stats['activeSchedules']}');
print('Total executions: ${stats['totalExecutions']}');
```

## API Endpoints

### Schedule Management
```
GET    /api/schedules              # List all schedules
POST   /api/schedules              # Create schedule
GET    /api/schedules/{id}         # Get schedule details
PUT    /api/schedules/{id}         # Update schedule
DELETE /api/schedules/{id}         # Delete schedule
PATCH  /api/schedules/{id}/toggle  # Toggle active status
POST   /api/schedules/{id}/execute # Execute schedule now
GET    /api/schedules/{id}/history # Get execution history
GET    /api/schedules/stats        # Get execution statistics
```

### Request/Response Examples

#### Create Schedule
```json
POST /api/schedules
{
  "id": "daily-backup",
  "name": "Daily Backup",
  "description": "Daily data backup download",
  "type": "recurring",
  "recurrencePattern": "daily",
  "startTime": "2024-01-15T02:00:00Z",
  "isActive": true,
  "metadata": {
    "url": "https://backup.example.com/daily",
    "quality": "best"
  }
}
```

#### Execution Statistics
```json
GET /api/schedules/stats
{
  "totalSchedules": 15,
  "activeSchedules": 12,
  "totalExecutions": 245,
  "successfulExecutions": 238,
  "failedExecutions": 7,
  "successRate": 0.971,
  "isRunning": true
}
```

## Testing

### Unit Tests

#### Schedule Model Tests
- Schedule creation and validation
- Next execution calculation
- Expiration checking
- State transitions

#### Repository Tests
- CRUD operations
- Query filtering
- Execution tracking
- Data persistence

### Integration Tests

#### Schedule Execution Flow
- End-to-end schedule creation to execution
- Error handling and recovery
- Concurrent execution
- Resource cleanup

#### Service Integration
- Repository and service interaction
- Background execution
- State synchronization

### E2E Tests

#### User Journey Tests
- Complete schedule management workflow
- UI interaction validation
- Cross-platform consistency
- Performance validation

### Automation Tests

#### Complex Scenarios
- Large-scale scheduling (100+ schedules)
- Edge cases and error conditions
- Performance benchmarking
- Stress testing

## Performance Considerations

### Execution Optimization
- **Batched Processing**: Execute multiple schedules efficiently
- **Resource Pooling**: Reuse download connections
- **Queue Management**: Prevent resource exhaustion
- **Background Processing**: Non-blocking execution

### Storage Optimization
- **Indexed Queries**: Fast schedule lookups
- **Data Archiving**: Automatic cleanup of old records
- **Compression**: Efficient storage of execution results
- **Caching**: Frequently accessed schedule data

### Monitoring & Alerting
- **Execution Metrics**: Track performance and success rates
- **Error Reporting**: Automatic failure notifications
- **Health Checks**: System status monitoring
- **Performance Alerts**: Threshold-based notifications

## Security Considerations

### Access Control
- **Schedule Ownership**: User-specific schedule management
- **Permission Levels**: Read/write/execute permissions
- **Audit Logging**: Track schedule modifications
- **Secure Storage**: Encrypted schedule metadata

### Input Validation
- **URL Sanitization**: Prevent malicious URLs
- **Parameter Limits**: Prevent resource exhaustion
- **Schedule Limits**: Maximum schedules per user
- **Rate Limiting**: Prevent abuse

## Troubleshooting

### Common Issues

#### Schedules Not Executing
- Check if schedule is active
- Verify execution service is running
- Check system time and timezone
- Review error logs

#### Execution Failures
- Validate download URLs
- Check network connectivity
- Verify authentication credentials
- Review download service status

#### Performance Issues
- Monitor system resources
- Check concurrent execution limits
- Review database performance
- Analyze execution patterns

### Debug Tools

#### Execution Logging
```dart
// Enable detailed execution logging
ScheduleExecutionService.enableDebugLogging(true);
```

#### Performance Monitoring
```dart
// Get detailed performance metrics
final metrics = await scheduleExecutionService.getPerformanceMetrics();
```

#### Health Checks
```dart
// Run comprehensive system health check
final healthStatus = await scheduleExecutionService.runHealthCheck();
```

## Future Enhancements

### Planned Features

#### Advanced Scheduling
- **Conditional Execution**: Execute based on external conditions
- **Dependency Chains**: Schedule sequences with dependencies
- **Dynamic Parameters**: Runtime parameter modification
- **Schedule Templates**: Reusable schedule configurations

#### Integration Features
- **Calendar Integration**: Sync with external calendars
- **Notification Systems**: Push notifications for execution results
- **Webhook Support**: External service integration
- **API Callbacks**: Custom execution handlers

#### Analytics & Insights
- **Usage Analytics**: Schedule usage patterns
- **Performance Insights**: Execution time analysis
- **Failure Analysis**: Root cause identification
- **Predictive Scheduling**: AI-powered optimization

## Contributing

When contributing to scheduling features:

1. **Follow established patterns**: Use existing model and repository patterns
2. **Add comprehensive tests**: Include unit, integration, and e2e tests
3. **Update documentation**: Keep this document current
4. **Consider performance**: Profile and optimize execution logic
5. **Test edge cases**: Handle timezone changes, DST, leap years
6. **Security first**: Validate inputs and secure sensitive data

## Changelog

### Version 1.0.0
- Initial scheduling implementation
- Basic schedule types (one-time, recurring, periodic)
- Execution service and monitoring
- Cross-platform UI components
- Comprehensive testing suite

### Version 1.1.0 (Planned)
- Collection schedules
- Advanced recurrence patterns
- Execution analytics
- Performance optimizations
- Enhanced error handling</content>
</xai:function_call">Add comprehensive documentation for scheduling features