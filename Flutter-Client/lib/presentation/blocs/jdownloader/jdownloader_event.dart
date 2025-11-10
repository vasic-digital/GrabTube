import 'package:equatable/equatable.dart';
import '../../../domain/entities/jdownloader_instance.dart';

/// Base class for JDownloader events
abstract class JDownloaderEvent extends Equatable {
  const JDownloaderEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all JDownloader instances
class LoadJDownloaderInstancesEvent extends JDownloaderEvent {
  const LoadJDownloaderInstancesEvent();
}

/// Event to load a specific instance by ID
class LoadJDownloaderInstanceByIdEvent extends JDownloaderEvent {
  const LoadJDownloaderInstanceByIdEvent(this.instanceId);

  final String instanceId;

  @override
  List<Object?> get props => [instanceId];
}

/// Event to add a new JDownloader instance
class AddJDownloaderInstanceEvent extends JDownloaderEvent {
  const AddJDownloaderInstanceEvent({
    required this.name,
    required this.deviceId,
    this.host,
    this.port,
    this.username,
    this.password,
  });

  final String name;
  final String deviceId;
  final String? host;
  final int? port;
  final String? username;
  final String? password;

  @override
  List<Object?> get props => [name, deviceId, host, port, username, password];
}

/// Event to update instance details
class UpdateJDownloaderInstanceEvent extends JDownloaderEvent {
  const UpdateJDownloaderInstanceEvent(this.instance);

  final JDownloaderInstance instance;

  @override
  List<Object?> get props => [instance];
}

/// Event to delete an instance
class DeleteJDownloaderInstanceEvent extends JDownloaderEvent {
  const DeleteJDownloaderInstanceEvent(this.instanceId);

  final String instanceId;

  @override
  List<Object?> get props => [instanceId];
}

/// Event to connect to an instance
class ConnectJDownloaderInstanceEvent extends JDownloaderEvent {
  const ConnectJDownloaderInstanceEvent(this.instanceId);

  final String instanceId;

  @override
  List<Object?> get props => [instanceId];
}

/// Event to disconnect from an instance
class DisconnectJDownloaderInstanceEvent extends JDownloaderEvent {
  const DisconnectJDownloaderInstanceEvent(this.instanceId);

  final String instanceId;

  @override
  List<Object?> get props => [instanceId];
}

/// Event to pause downloads on an instance
class PauseJDownloaderInstanceEvent extends JDownloaderEvent {
  const PauseJDownloaderInstanceEvent(this.instanceId);

  final String instanceId;

  @override
  List<Object?> get props => [instanceId];
}

/// Event to resume downloads on an instance
class ResumeJDownloaderInstanceEvent extends JDownloaderEvent {
  const ResumeJDownloaderInstanceEvent(this.instanceId);

  final String instanceId;

  @override
  List<Object?> get props => [instanceId];
}

/// Event to add a download to JDownloader
class AddJDownloaderDownloadEvent extends JDownloaderEvent {
  const AddJDownloaderDownloadEvent({
    required this.instanceId,
    required this.url,
    this.destinationFolder,
    this.packageName,
  });

  final String instanceId;
  final String url;
  final String? destinationFolder;
  final String? packageName;

  @override
  List<Object?> get props => [instanceId, url, destinationFolder, packageName];
}

/// Event to get downloads from an instance
class GetJDownloaderDownloadsEvent extends JDownloaderEvent {
  const GetJDownloaderDownloadsEvent(this.instanceId);

  final String instanceId;

  @override
  List<Object?> get props => [instanceId];
}

/// Event to pause a specific download
class PauseJDownloaderDownloadEvent extends JDownloaderEvent {
  const PauseJDownloaderDownloadEvent({
    required this.instanceId,
    required this.downloadId,
  });

  final String instanceId;
  final String downloadId;

  @override
  List<Object?> get props => [instanceId, downloadId];
}

/// Event to resume a specific download
class ResumeJDownloaderDownloadEvent extends JDownloaderEvent {
  const ResumeJDownloaderDownloadEvent({
    required this.instanceId,
    required this.downloadId,
  });

  final String instanceId;
  final String downloadId;

  @override
  List<Object?> get props => [instanceId, downloadId];
}

/// Event to remove a download
class RemoveJDownloaderDownloadEvent extends JDownloaderEvent {
  const RemoveJDownloaderDownloadEvent({
    required this.instanceId,
    required this.downloadId,
  });

  final String instanceId;
  final String downloadId;

  @override
  List<Object?> get props => [instanceId, downloadId];
}

/// Event to get speed history
class GetJDownloaderSpeedHistoryEvent extends JDownloaderEvent {
  const GetJDownloaderSpeedHistoryEvent({
    required this.instanceId,
    this.limit = 100,
  });

  final String instanceId;
  final int limit;

  @override
  List<Object?> get props => [instanceId, limit];
}

/// Event to check connection status
class CheckJDownloaderConnectionEvent extends JDownloaderEvent {
  const CheckJDownloaderConnectionEvent(this.instanceId);

  final String instanceId;

  @override
  List<Object?> get props => [instanceId];
}

/// Event when instance is updated from stream
class JDownloaderInstanceUpdatedFromStreamEvent extends JDownloaderEvent {
  const JDownloaderInstanceUpdatedFromStreamEvent(this.instance);

  final JDownloaderInstance instance;

  @override
  List<Object?> get props => [instance];
}
