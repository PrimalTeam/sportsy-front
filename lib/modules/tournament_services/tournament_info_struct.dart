class TournamentInfo {
  final String title;
  final String? description;
  final DateTime? dateStart;
  final DateTime? dateEnd;

  TournamentInfo({
    required this.title,
    this.description,
    this.dateStart,
    this.dateEnd,
  });
}
