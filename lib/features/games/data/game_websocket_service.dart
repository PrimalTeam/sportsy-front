import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sportsy_front/core/network/base_websocket_service.dart';
import 'package:sportsy_front/core/network/websocket_config.dart';

import 'game_websocket_events.dart';

/// WebSocket service for real-time game updates.
///
/// Provides functionality to:
/// - Connect to the games WebSocket namespace
/// - Join/leave tournament rooms
/// - Receive real-time game created/updated/deleted events
///
/// Usage:
/// ```dart
/// final gameSocket = GameWebSocketService();
///
/// // Listen to events
/// gameSocket.onGameCreated.listen((event) {
///   print('Game created: ${event.gameId}');
/// });
///
/// // Connect and join tournament
/// await gameSocket.connect();
/// await gameSocket.joinTournament(roomId: 1, tournamentId: 5);
/// ```
class GameWebSocketService extends BaseWebSocketService {
  static final GameWebSocketService _instance = GameWebSocketService._();

  factory GameWebSocketService() => _instance;

  GameWebSocketService._();

  @override
  String get namespace => gamesNamespace;

  // Stream controllers for game events
  final _gameCreatedController =
      StreamController<GameCreatedEvent>.broadcast();
  final _gameUpdatedController =
      StreamController<GameUpdatedEvent>.broadcast();
  final _gameDeletedController =
      StreamController<GameDeletedEvent>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  // Currently subscribed tournament info
  int? _subscribedTournamentId;
  int? _subscribedRoomId;

  /// Stream of game created events.
  Stream<GameCreatedEvent> get onGameCreated => _gameCreatedController.stream;

  /// Stream of game updated events.
  Stream<GameUpdatedEvent> get onGameUpdated => _gameUpdatedController.stream;

  /// Stream of game deleted events.
  Stream<GameDeletedEvent> get onGameDeleted => _gameDeletedController.stream;

  /// Stream of connection state changes.
  Stream<bool> get onConnectionStateChanged => _connectionStateController.stream;

  /// Stream of error messages.
  Stream<String> get onError => _errorController.stream;

  /// Currently subscribed tournament ID.
  int? get subscribedTournamentId => _subscribedTournamentId;

  /// Currently subscribed room ID.
  int? get subscribedRoomId => _subscribedRoomId;

  /// Whether currently subscribed to a tournament.
  bool get isSubscribedToTournament =>
      _subscribedTournamentId != null && _subscribedRoomId != null;

  @override
  void setupCustomListeners() {
    debugPrint('[GameWS] Setting up custom listeners');
    
    on('gameCreated', (data) {
      debugPrint('[GameWS] Received gameCreated: $data');
      if (data is Map<String, dynamic>) {
        final event = GameCreatedEvent.fromJson(data);
        _gameCreatedController.add(event);
      }
    });

    on('gameUpdated', (data) {
      debugPrint('[GameWS] Received gameUpdated: $data');
      if (data is Map<String, dynamic>) {
        final event = GameUpdatedEvent.fromJson(data);
        _gameUpdatedController.add(event);
      }
    });

    on('gameDeleted', (data) {
      debugPrint('[GameWS] Received gameDeleted: $data');
      if (data is Map<String, dynamic>) {
        final event = GameDeletedEvent.fromJson(data);
        _gameDeletedController.add(event);
      }
    });
  }

  @override
  void onConnected() {
    debugPrint('[GameWS] Connected!');
    _connectionStateController.add(true);
  }

  @override
  void onDisconnected(String reason) {
    debugPrint('[GameWS] Disconnected: $reason');
    _connectionStateController.add(false);
    _subscribedTournamentId = null;
    _subscribedRoomId = null;
  }

  @override
  void onConnectionError(String error) {
    _errorController.add('Connection error: $error');
  }

  @override
  void onException(dynamic data) {
    final message = data is Map ? data['message'] ?? data.toString() : data.toString();
    _errorController.add('Server exception: $message');
  }

  /// Join a tournament room to receive real-time updates.
  ///
  /// Returns a [Future] that completes with the server response.
  Future<TournamentResponse> joinTournament({
    required int roomId,
    required int tournamentId,
  }) async {
    if (!isConnected) {
      throw Exception('Not connected. Call connect() first.');
    }

    final completer = Completer<TournamentResponse>();
    final payload = JoinTournamentPayload(
      tournamentId: tournamentId,
      roomId: roomId,
    );

    emit(
      'joinTournament',
      payload.toJson(),
      ack: (response) {
        if (response is Map<String, dynamic>) {
          final result = TournamentResponse.fromJson(response);
          if (result.isSuccess) {
            _subscribedTournamentId = tournamentId;
            _subscribedRoomId = roomId;
          }
          completer.complete(result);
        } else {
          completer.complete(
            const TournamentResponse(status: 'error', message: 'Invalid response'),
          );
        }
      },
    );

    return completer.future;
  }

  /// Leave the currently joined tournament room.
  ///
  /// Returns a [Future] that completes with the server response.
  Future<TournamentResponse> leaveTournament() async {
    if (!isConnected) {
      throw Exception('Not connected. Call connect() first.');
    }

    if (_subscribedTournamentId == null || _subscribedRoomId == null) {
      return const TournamentResponse(
        status: 'error',
        message: 'No active tournament subscription',
      );
    }

    final completer = Completer<TournamentResponse>();
    final payload = JoinTournamentPayload(
      tournamentId: _subscribedTournamentId!,
      roomId: _subscribedRoomId!,
    );

    emit(
      'leaveTournament',
      payload.toJson(),
      ack: (response) {
        if (response is Map<String, dynamic>) {
          final result = TournamentResponse.fromJson(response);
          if (result.isSuccess) {
            _subscribedTournamentId = null;
            _subscribedRoomId = null;
          }
          completer.complete(result);
        } else {
          completer.complete(
            const TournamentResponse(status: 'error', message: 'Invalid response'),
          );
        }
      },
    );

    return completer.future;
  }

  /// Disconnect and clean up resources.
  @override
  void disconnect() {
    _subscribedTournamentId = null;
    _subscribedRoomId = null;
    super.disconnect();
  }

  /// Dispose all stream controllers.
  /// Call this when the service is no longer needed.
  void dispose() {
    disconnect();
    _gameCreatedController.close();
    _gameUpdatedController.close();
    _gameDeletedController.close();
    _connectionStateController.close();
    _errorController.close();
  }
}
