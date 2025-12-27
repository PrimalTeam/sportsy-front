class TeamStatusDto {
  final int teamId;
  final int score;
  const TeamStatusDto({required this.teamId, required this.score});

  Map<String, dynamic> toJson() => {'teamId': teamId, 'score': score};

  @override
  String toString() => 'TeamStatusDto(teamId: $teamId, score: $score)';
}

class GameCreateDto {
  final String status; // e.g. "Pending"
  final DateTime dateStart; // will be sent as ISO8601 UTC (no millis)
  final Duration durationTime; // HH:mm:ss
  final List<int> teamIds; // typically two team IDs
  final List<TeamStatusDto> teamStatuses; // scores aligned with teamIds

  const GameCreateDto({
    required this.status,
    required this.dateStart,
    required this.durationTime,
    required this.teamIds,
    required this.teamStatuses,
  });

  String _durationToString(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _dateToIso8601WithoutMillis(DateTime dateTime) {
    final utc = dateTime.toUtc();
    final iso = utc.toIso8601String();
    final dotIndex = iso.indexOf('.');
    if (dotIndex == -1) {
      return iso.endsWith('Z') ? iso : '${iso}Z';
    }
    return iso.substring(0, dotIndex) + 'Z';
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'dateStart': _dateToIso8601WithoutMillis(dateStart),
    'durationTime': _durationToString(durationTime),
    'teamIds': teamIds,
    'teamStatuses': teamStatuses.map((e) => e.toJson()).toList(),
  };

  @override
  String toString() {
    return 'GameCreateDto(status: $status, dateStart: ${_dateToIso8601WithoutMillis(dateStart)}, durationTime: ${_durationToString(durationTime)}, teamIds: $teamIds, teamStatuses: $teamStatuses)';
  }
}
