import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:sportsy_front/core/auth/jwt_storage_service.dart';
import 'package:sportsy_front/core/network/websocket_config.dart';

/// Base class for WebSocket connections using Socket.IO.
///
/// Provides common functionality for connecting, disconnecting, and
/// managing WebSocket events with JWT authentication.
abstract class BaseWebSocketService {
  io.Socket? _socket;
  bool _isConnected = false;
  Completer<void>? _connectCompleter;

  /// The namespace for this WebSocket connection (e.g., '/games').
  String get namespace;

  /// Whether the socket is currently connected.
  bool get isConnected => _isConnected;

  /// The underlying Socket.IO socket instance.
  io.Socket? get socket => _socket;

  /// Connect to the WebSocket server with JWT authentication.
  Future<void> connect() async {
    if (_socket != null && _isConnected) {
      debugPrint('[BaseWS] Already connected, skipping');
      return;
    }

    // If already connecting, wait for that to complete
    if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
      debugPrint('[BaseWS] Already connecting, waiting...');
      return _connectCompleter!.future;
    }

    _connectCompleter = Completer<void>();

    final token = await JwtStorageService.getToken();
    final url = '$websocketBaseUrl$namespace';
    debugPrint('[BaseWS] Connecting to: $url');
    debugPrint('[BaseWS] Token present: ${token != null}');

    _socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth(token != null ? {'token': token} : {})
          .build(),
    );

    _setupBaseListeners();
    setupCustomListeners();

    _socket!.connect();
    debugPrint('[BaseWS] Connect called, waiting for connection...');

    // Wait for connection with timeout
    try {
      await _connectCompleter!.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );
      debugPrint('[BaseWS] Connection established!');
    } catch (e) {
      debugPrint('[BaseWS] Connection failed: $e');
      _connectCompleter = null;
      rethrow;
    }
  }

  /// Disconnect from the WebSocket server.
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    onDisconnected('Manual disconnect');
  }

  /// Setup base connection listeners.
  void _setupBaseListeners() {
    _socket?.onConnect((_) {
      _isConnected = true;
      if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
        _connectCompleter!.complete();
      }
      onConnected();
    });

    _socket?.onDisconnect((reason) {
      _isConnected = false;
      onDisconnected(reason.toString());
    });

    _socket?.onConnectError((error) {
      _isConnected = false;
      if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
        _connectCompleter!.completeError(Exception(error.toString()));
      }
      onConnectionError(error.toString());
    });

    _socket?.on('exception', (data) {
      onException(data);
    });
  }

  /// Override to setup custom event listeners specific to the service.
  void setupCustomListeners();

  /// Called when connection is established.
  void onConnected() {}

  /// Called when disconnected from server.
  void onDisconnected(String reason) {}

  /// Called when a connection error occurs.
  void onConnectionError(String error) {}

  /// Called when server sends an exception.
  void onException(dynamic data) {}

  /// Emit an event with optional acknowledgement callback.
  void emit(String event, dynamic data, {Function(dynamic)? ack}) {
    if (_socket == null) {
      throw Exception('Socket not connected. Call connect() first.');
    }
    if (ack != null) {
      _socket!.emitWithAck(event, data, ack: ack);
    } else {
      _socket!.emit(event, data);
    }
  }

  /// Listen to a specific event.
  void on(String event, void Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  /// Remove listener for a specific event.
  void off(String event) {
    _socket?.off(event);
  }
}
