import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../constants/app_constants.dart';
import '../utils/logger.dart';
import '../../data/models/download_model.dart';

/// Socket events
enum SocketEvent {
  added,
  updated,
  completed,
  canceled,
  cleared,
  error,
}

@singleton
class SocketClient {
  SocketClient(this._prefs) {
    _initialize();
  }

  final SharedPreferences _prefs;
  late io.Socket _socket;
  bool _isConnected = false;

  // Streams for different events
  final _downloadAddedController = BehaviorSubject<DownloadModel>();
  final _downloadUpdatedController = BehaviorSubject<DownloadModel>();
  final _downloadCompletedController = BehaviorSubject<DownloadModel>();
  final _downloadCanceledController = BehaviorSubject<String>();
  final _downloadsClearedController = BehaviorSubject<void>();
  final _errorController = BehaviorSubject<String>();
  final _connectionController = BehaviorSubject<bool>.seeded(false);

  // Public streams
  Stream<DownloadModel> get downloadAdded => _downloadAddedController.stream;
  Stream<DownloadModel> get downloadUpdated => _downloadUpdatedController.stream;
  Stream<DownloadModel> get downloadCompleted => _downloadCompletedController.stream;
  Stream<String> get downloadCanceled => _downloadCanceledController.stream;
  Stream<void> get downloadsCleared => _downloadsClearedController.stream;
  Stream<String> get error => _errorController.stream;
  Stream<bool> get connectionStatus => _connectionController.stream;

  bool get isConnected => _isConnected;

  void _initialize() {
    final serverUrl = _prefs.getString(AppConstants.prefKeyServerUrl) ??
        AppConstants.defaultServerUrl;

    AppLogger.info('Initializing Socket.IO client for: $serverUrl');

    _socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(AppConstants.socketReconnectDelay.inMilliseconds)
          .setReconnectionAttempts(AppConstants.socketMaxReconnectAttempts)
          .build(),
    );

    _setupEventListeners();
  }

  void _setupEventListeners() {
    // Connection events
    _socket.onConnect((_) {
      AppLogger.info('Socket.IO connected');
      _isConnected = true;
      _connectionController.add(true);
    });

    _socket.onDisconnect((_) {
      AppLogger.warning('Socket.IO disconnected');
      _isConnected = false;
      _connectionController.add(false);
    });

    _socket.onConnectError((error) {
      AppLogger.error('Socket.IO connection error', error);
      _errorController.add('Connection error: $error');
    });

    _socket.onError((error) {
      AppLogger.error('Socket.IO error', error);
      _errorController.add('Socket error: $error');
    });

    // Download events
    _socket.on('added', (data) {
      try {
        AppLogger.debug('Download added event: $data');
        final download = DownloadModel.fromJson(data as Map<String, dynamic>);
        _downloadAddedController.add(download);
      } catch (e, stackTrace) {
        AppLogger.error('Error parsing added event', e, stackTrace);
      }
    });

    _socket.on('updated', (data) {
      try {
        AppLogger.debug('Download updated event: $data');
        final download = DownloadModel.fromJson(data as Map<String, dynamic>);
        _downloadUpdatedController.add(download);
      } catch (e, stackTrace) {
        AppLogger.error('Error parsing updated event', e, stackTrace);
      }
    });

    _socket.on('completed', (data) {
      try {
        AppLogger.debug('Download completed event: $data');
        final download = DownloadModel.fromJson(data as Map<String, dynamic>);
        _downloadCompletedController.add(download);
      } catch (e, stackTrace) {
        AppLogger.error('Error parsing completed event', e, stackTrace);
      }
    });

    _socket.on('canceled', (data) {
      try {
        AppLogger.debug('Download canceled event: $data');
        final id = data['id'] as String;
        _downloadCanceledController.add(id);
      } catch (e, stackTrace) {
        AppLogger.error('Error parsing canceled event', e, stackTrace);
      }
    });

    _socket.on('cleared', (_) {
      AppLogger.debug('Downloads cleared event');
      _downloadsClearedController.add(null);
    });
  }

  /// Connect to the socket server
  void connect() {
    if (!_isConnected) {
      AppLogger.info('Connecting to Socket.IO server...');
      _socket.connect();
    }
  }

  /// Disconnect from the socket server
  void disconnect() {
    if (_isConnected) {
      AppLogger.info('Disconnecting from Socket.IO server...');
      _socket.disconnect();
    }
  }

  /// Update server URL and reconnect
  void updateServerUrl(String newUrl) {
    AppLogger.info('Updating Socket.IO server URL to: $newUrl');
    disconnect();
    _socket.dispose();
    _initialize();
    connect();
  }

  @disposeMethod
  void dispose() {
    AppLogger.info('Disposing Socket.IO client');
    _socket.dispose();
    _downloadAddedController.close();
    _downloadUpdatedController.close();
    _downloadCompletedController.close();
    _downloadCanceledController.close();
    _downloadsClearedController.close();
    _errorController.close();
    _connectionController.close();
  }
}
