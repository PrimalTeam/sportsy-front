import 'package:sportsy_front/dto/game_get_dto.dart';

/// Payload for joining or leaving a tournament room.
class JoinTournamentPayload {
  final int tournamentId;
  final int roomId;

  const JoinTournamentPayload({
    required this.tournamentId,
    required this.roomId,
  });

  Map<String, dynamic> toJson() => {
        'tournamentId': tournamentId,
        'roomId': roomId,
      };
}

/// Response from server when joining/leaving a tournament.
class TournamentResponse {
  final String status;
  final String? room;
  final String? message;

  const TournamentResponse({
    required this.status,
    this.room,
    this.message,
  });

  factory TournamentResponse.fromJson(Map<String, dynamic> json) {
    return TournamentResponse(
      status: json['status'] as String? ?? '',
      room: json['room'] as String?,
      message: json['message'] as String?,
    );
  }

  bool get isSuccess =>
      status == 'joined' || status == 'left' || status == 'ok';
}

/// Event payload for game created event.
class GameCreatedEvent {
  final int? gameId;
  final int? tournamentId;
  final Map<String, dynamic> rawData;

  const GameCreatedEvent({
    this.gameId,
    this.tournamentId,
    required this.rawData,
  });

  factory GameCreatedEvent.fromJson(Map<String, dynamic> json) {
    return GameCreatedEvent(
      gameId: json['gameId'] as int? ?? json['id'] as int?,
      tournamentId: json['tournamentId'] as int?,
      rawData: json,
    );
  }

  /// Try to parse the full game data if available.
  GameGetDto? toGameDto() {
    try {
      return GameGetDto.fromJson(rawData);
    } catch (_) {
      return null;
    }
  }
}

/// Event payload for game updated event.
class GameUpdatedEvent {
  final int? gameId;
  final int? tournamentId;
  final Map<String, dynamic> rawData;

  const GameUpdatedEvent({
    this.gameId,
    this.tournamentId,
    required this.rawData,
  });

  factory GameUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return GameUpdatedEvent(
      gameId: json['gameId'] as int? ?? json['id'] as int?,
      tournamentId: json['tournamentId'] as int?,
      rawData: json,
    );
  }

  /// Try to parse the full game data if available.
  GameGetDto? toGameDto() {
    try {
      return GameGetDto.fromJson(rawData);
    } catch (_) {
      return null;
    }
  }
}

/// Event payload for game deleted event.
class GameDeletedEvent {
  final int gameId;
  final int tournamentId;

  const GameDeletedEvent({
    required this.gameId,
    required this.tournamentId,
  });

  factory GameDeletedEvent.fromJson(Map<String, dynamic> json) {
    return GameDeletedEvent(
      gameId: json['gameId'] as int? ?? 0,
      tournamentId: json['tournamentId'] as int? ?? 0,
    );
  }
}
