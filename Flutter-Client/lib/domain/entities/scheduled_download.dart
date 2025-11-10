import 'package:equatable/equatable.dart';

/// Scheduled download entity representing an instance of a schedule execution
class ScheduledDownload extends Equatable {
  const ScheduledDownload({
    required this.id,
    required this.scheduleId,
    required this.downloadId,
    required this.scheduledAt,
    this.executedAt,
    this.isExecuted = false,
    this.isSuccessful = false,
    this.errorMessage,
    this.result,
  });

  /// Unique scheduled download identifier
  final String id;

  /// The schedule that created this download
  final String scheduleId;

  /// The download task identifier
  final String downloadId;

  /// When this download was scheduled to execute
  final DateTime scheduledAt;

  /// When this download was actually executed
  final DateTime? executedAt;

  /// Whether the download has been executed
  final bool isExecuted;

  /// Whether the download execution was successful
  final bool isSuccessful;

  /// Error message if execution failed
  final String? errorMessage;

  /// Result data from the execution (e.g., file size, duration)
  final Map<String, dynamic>? result;

  /// Create a copy with updated fields
  ScheduledDownload copyWith({
    String? id,
    String? scheduleId,
    String? downloadId,
    DateTime? scheduledAt,
    DateTime? executedAt,
    bool? isExecuted,
    bool? isSuccessful,
    String? errorMessage,
    Map<String, dynamic>? result,
  }) {
    return ScheduledDownload(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      downloadId: downloadId ?? this.downloadId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      executedAt: executedAt ?? this.executedAt,
      isExecuted: isExecuted ?? this.isExecuted,
      isSuccessful: isSuccessful ?? this.isSuccessful,
      errorMessage: errorMessage ?? this.errorMessage,
      result: result ?? this.result,
    );
  }

  /// Check if the scheduled download is pending execution
  bool get isPending => !isExecuted && DateTime.now().isBefore(scheduledAt);

  /// Check if the scheduled download is overdue
  bool get isOverdue => !isExecuted && DateTime.now().isAfter(scheduledAt);

  /// Check if the scheduled download failed
  bool get isFailed => isExecuted && !isSuccessful;

  /// Get execution duration if executed
  Duration? get executionDuration {
    if (executedAt == null) return null;
    return executedAt!.difference(scheduledAt);
  }

  @override
  List<Object?> get props => [
        id,
        scheduleId,
        downloadId,
        scheduledAt,
        executedAt,
        isExecuted,
        isSuccessful,
        errorMessage,
        result,
      ];
}
