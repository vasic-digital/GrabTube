import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../core/utils/logger.dart';
import '../models/download_model.dart';

/// WebSocket client for real-time download updates
class DownloadWebSocketClient {
  late io.Socket _socket;
  final String serverUrl;

  final _updateController = StreamController<DownloadModel>.broadcast();
  final _addedController = StreamController<DownloadModel>.broadcast();
  final _deletedController = StreamController<String>.broadcast();
  final _clearedController = StreamController<void>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  DownloadWebSocketClient({required this.serverUrl});

  /// Stream of download updates
  Stream<DownloadModel> get updates => _updateController.stream;

  /// Stream of download additions
  Stream<DownloadModel> get additions => _addedController.stream;

  /// Stream of download deletions
  Stream<String> get deletions => _deletedController.stream;

  /// Stream of cleared events
  Stream<void> get cleared => _clearedController.stream;

  /// Stream of connection status changes
  Stream<bool> get connectionStatus => _connectionController.stream;

  /// Check if connected
  bool get isConnected => _socket.connected;

  /// Connect to WebSocket server
  void connect() {
    try {
      AppLogger.info('Connecting to WebSocket: $serverUrl');

      _socket = io.io(
        serverUrl,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(5)
            .build(),
      );

      _setupEventListeners();
    } catch (e) {
      AppLogger.error('Error connecting to WebSocket', error: e);
      _connectionController.add(false);
    }
  }

  /// Setup event listeners
  void _setupEventListeners() {
    // Connection events
    _socket.onConnect((_) {
      AppLogger.info('WebSocket connected');
      _connectionController.add(true);
    });

    _socket.onDisconnect((_) {
      AppLogger.warning('WebSocket disconnected');
      _connectionController.add(false);
    });

    _socket.onConnectError((data) {
      AppLogger.error('WebSocket connection error: $data');
      _connectionController.add(false);
    });

    _socket.onError((data) {
      AppLogger.error('WebSocket error: $data');
    });

    // Download events
    _socket.on('added', (data) {
      try {
        AppLogger.debug('Download added event: $data');
        final model = DownloadModel.fromJson(data as Map<String, dynamic>);
        _addedController.add(model);
      } catch (e) {
        AppLogger.error('Error parsing added event', error: e);
      }
    });

    _socket.on('updated', (data) {
      try {
        AppLogger.debug('Download updated event');
        final model = DownloadModel.fromJson(data as Map<String, dynamic>);
        _updateController.add(model);
      } catch (e) {
        AppLogger.error('Error parsing updated event', error: e);
      }
    });

    _socket.on('completed', (data) {
      try {
        AppLogger.info('Download completed event');
        final model = DownloadModel.fromJson(data as Map<String, dynamic>);
        _updateController.add(model);
      } catch (e) {
        AppLogger.error('Error parsing completed event', error: e);
      }
    });

    _socket.on('canceled', (data) {
      try {
        AppLogger.info('Download canceled event');
        final model = DownloadModel.fromJson(data as Map<String, dynamic>);
        _updateController.add(model);
      } catch (e) {
        AppLogger.error('Error parsing canceled event', error: e);
      }
    });

    _socket.on('error', (data) {
      try {
        AppLogger.error('Download error event');
        final model = DownloadModel.fromJson(data as Map<String, dynamic>);
        _updateController.add(model);
      } catch (e) {
        AppLogger.error('Error parsing error event', error: e);
      }
    });

    _socket.on('deleted', (data) {
      try {
        AppLogger.info('Download deleted event: $data');
        final id = data as String;
        _deletedController.add(id);
      } catch (e) {
        AppLogger.error('Error parsing deleted event', error: e);
      }
    });

    _socket.on('cleared', (data) {
      AppLogger.info('Downloads cleared event');
      _clearedController.add(null);
    });
  }

  /// Disconnect from server
  void disconnect() {
    AppLogger.info('Disconnecting WebSocket');
    _socket.disconnect();
    _socket.dispose();
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _updateController.close();
    _addedController.close();
    _deletedController.close();
    _clearedController.close();
    _connectionController.close();
  }
}
