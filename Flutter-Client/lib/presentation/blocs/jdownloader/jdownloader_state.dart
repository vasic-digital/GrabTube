import 'package:equatable/equatable.dart';
import '../../../domain/entities/jdownloader_instance.dart';
import '../../../domain/entities/speed_data_point.dart';

/// Base class for JDownloader states
abstract class JDownloaderState extends Equatable {
  const JDownloaderState();

  @override
  List<Object?> get props => [];
}

/// Initial state when BLoC is created
class JDownloaderInitial extends JDownloaderState {
  const JDownloaderInitial();
}

/// State when instances are being loaded
class JDownloaderInstancesLoading extends JDownloaderState {
  const JDownloaderInstancesLoading();
}

/// State when instances are loaded successfully
class JDownloaderInstancesLoaded extends JDownloaderState {
  const JDownloaderInstancesLoaded(this.instances);

  final List<JDownloaderInstance> instances;

  @override
  List<Object?> get props => [instances];
}

/// State when a single instance is loaded
class JDownloaderInstanceLoaded extends JDownloaderState {
  const JDownloaderInstanceLoaded(this.instance);

  final JDownloaderInstance instance;

  @override
  List<Object?> get props => [instance];
}

/// State when operation fails
class JDownloaderFailure extends JDownloaderState {
  const JDownloaderFailure(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}

/// State when authentication is required
class JDownloaderAuthRequired extends JDownloaderState {
  const JDownloaderAuthRequired();
}

/// State when adding an instance
class JDownloaderInstanceAdding extends JDownloaderState {
  const JDownloaderInstanceAdding();
}

/// State when instance is added successfully
class JDownloaderInstanceAdded extends JDownloaderState {
  const JDownloaderInstanceAdded(this.instance);

  final JDownloaderInstance instance;

  @override
  List<Object?> get props => [instance];
}

/// State when updating an instance
class JDownloaderInstanceUpdating extends JDownloaderState {
  const JDownloaderInstanceUpdating();
}

/// State when instance is updated successfully
class JDownloaderInstanceUpdated extends JDownloaderState {
  const JDownloaderInstanceUpdated(this.instance);

  final JDownloaderInstance instance;

  @override
  List<Object?> get props => [instance];
}

/// State when deleting an instance
class JDownloaderInstanceDeleting extends JDownloaderState {
  const JDownloaderInstanceDeleting();
}

/// State when instance is deleted successfully
class JDownloaderInstanceDeleted extends JDownloaderState {
  const JDownloaderInstanceDeleted(this.instanceId);

  final String instanceId;

  @override
  List<Object?> get props => [instanceId];
}

/// State when connecting to an instance
class JDownloaderInstanceConnecting extends JDownloaderState {
  const JDownloaderInstanceConnecting(this.instanceId);

  final String instanceId;

  @override
  List<Object?> get props => [instanceId];
}

/// State when connected to an instance
class JDownloaderInstanceConnected extends JDownloaderState {
  const JDownloaderInstanceConnected(this.instance);

  final JDownloaderInstance instance;

  @override
  List<Object?> get props => [instance];
}

/// State when disconnecting from an instance
class JDownloaderInstanceDisconnecting extends JDownloaderState {
  const JDownloaderInstanceDisconnecting(this.instanceId);

  final String instanceId;

  @override
  List<Object?> get props => [instanceId];
}

/// State when disconnected from an instance
class JDownloaderInstanceDisconnected extends JDownloaderState {
  const JDownloaderInstanceDisconnected(this.instanceId);

  final String instanceId;

  @override
  List<Object?> get props => [instanceId];
}

/// State when downloads are being loaded
class JDownloaderDownloadsLoading extends JDownloaderState {
  const JDownloaderDownloadsLoading();
}

/// State when downloads are loaded
class JDownloaderDownloadsLoaded extends JDownloaderState {
  const JDownloaderDownloadsLoaded({
    required this.instanceId,
    required this.downloads,
  });

  final String instanceId;
  final List<dynamic> downloads;

  @override
  List<Object?> get props => [instanceId, downloads];
}

/// State when adding a download
class JDownloaderDownloadAdding extends JDownloaderState {
  const JDownloaderDownloadAdding();
}

/// State when download is added successfully
class JDownloaderDownloadAdded extends JDownloaderState {
  const JDownloaderDownloadAdded({
    required this.instanceId,
    required this.url,
  });

  final String instanceId;
  final String url;

  @override
  List<Object?> get props => [instanceId, url];
}

/// State when download operation is in progress
class JDownloaderDownloadOperating extends JDownloaderState {
  const JDownloaderDownloadOperating();
}

/// State when download operation completes
class JDownloaderDownloadOperated extends JDownloaderState {
  const JDownloaderDownloadOperated(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// State when speed history is being loaded
class JDownloaderSpeedHistoryLoading extends JDownloaderState {
  const JDownloaderSpeedHistoryLoading();
}

/// State when speed history is loaded
class JDownloaderSpeedHistoryLoaded extends JDownloaderState {
  const JDownloaderSpeedHistoryLoaded({
    required this.instanceId,
    required this.speedHistory,
  });

  final String instanceId;
  final List<SpeedDataPoint> speedHistory;

  @override
  List<Object?> get props => [instanceId, speedHistory];
}

/// State when checking connection
class JDownloaderConnectionChecking extends JDownloaderState {
  const JDownloaderConnectionChecking();
}

/// State when connection status is checked
class JDownloaderConnectionChecked extends JDownloaderState {
  const JDownloaderConnectionChecked({
    required this.instanceId,
    required this.isConnected,
  });

  final String instanceId;
  final bool isConnected;

  @override
  List<Object?> get props => [instanceId, isConnected];
}
