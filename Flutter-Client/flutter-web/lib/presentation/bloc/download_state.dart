import 'package:equatable/equatable.dart';
import '../../domain/entities/download.dart';

/// Base class for download states
abstract class DownloadState extends Equatable {
  const DownloadState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class DownloadInitial extends DownloadState {
  const DownloadInitial();
}

/// Loading state
class DownloadLoading extends DownloadState {
  const DownloadLoading();
}

/// Loaded state with downloads
class DownloadLoaded extends DownloadState {
  final List<Download> activeDownloads;
  final List<Download> completedDownloads;
  final List<Download> pendingDownloads;
  final bool isConnected;
  final String? message;

  const DownloadLoaded({
    required this.activeDownloads,
    required this.completedDownloads,
    required this.pendingDownloads,
    this.isConnected = false,
    this.message,
  });

  /// Get all downloads
  List<Download> get allDownloads => [
        ...activeDownloads,
        ...completedDownloads,
        ...pendingDownloads,
      ];

  /// Get download by ID
  Download? getDownloadById(String id) {
    return allDownloads.where((d) => d.id == id).firstOrNull;
  }

  /// Copy with updated fields
  DownloadLoaded copyWith({
    List<Download>? activeDownloads,
    List<Download>? completedDownloads,
    List<Download>? pendingDownloads,
    bool? isConnected,
    String? message,
    bool clearMessage = false,
  }) {
    return DownloadLoaded(
      activeDownloads: activeDownloads ?? this.activeDownloads,
      completedDownloads: completedDownloads ?? this.completedDownloads,
      pendingDownloads: pendingDownloads ?? this.pendingDownloads,
      isConnected: isConnected ?? this.isConnected,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [
        activeDownloads,
        completedDownloads,
        pendingDownloads,
        isConnected,
        message,
      ];
}

/// Error state
class DownloadError extends DownloadState {
  final String message;
  final DownloadLoaded? previousState;

  const DownloadError(this.message, {this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}

/// Operation success state (for showing snackbars)
class DownloadOperationSuccess extends DownloadState {
  final String message;
  final DownloadLoaded state;

  const DownloadOperationSuccess(this.message, this.state);

  @override
  List<Object> get props => [message, state];
}
