import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/modules/services/auth.dart';
import 'package:sportsy_front/screens/room_users_screen.dart';
import 'package:sportsy_front/screens/teams_show_page.dart';
import 'package:sportsy_front/widgets/app_bar.dart';
import 'package:sportsy_front/dto/team_add_dto.dart';
import 'package:flutter/services.dart';
import 'package:sportsy_front/widgets/tournament_create_widgets/team_add_form.dart';
import 'package:sportsy_front/widgets/games_tab.dart';
import 'package:sportsy_front/widgets/tournament_bottom_bar.dart';
import 'package:sportsy_front/dto/room_info_dto.dart';
import 'package:sportsy_front/dto/get_teams_dto.dart';
import 'package:sportsy_front/screens/tournament_info_edit_page.dart';
import 'package:sportsy_front/screens/tournament_overview_tab.dart';

class TournamentInfoPage extends StatefulWidget {
  const TournamentInfoPage({super.key, required this.roomId});
  final int roomId;

  @override
  State<TournamentInfoPage> createState() => _TournamentInfoPageState();
}

class _TournamentInfoPageState extends State<TournamentInfoPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  RoomInfoDto? _roomInfo;
  bool _isLoading = true;
  String role = "admin"; 
  final GlobalKey<TeamsShowPageState> _teamsKey = GlobalKey<TeamsShowPageState>();
  Set<int> _tournamentTeamIds = {};
  List<GetTeamsDto> _tournamentTeams = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final roomInfo = await AuthService.getRoomInfo(widget.roomId);
      debugPrint('TournamentInfo: fetched room info ${roomInfo.id}, tournament teams raw: ${roomInfo.tournament?.teams}');
      setState(() {
        _roomInfo = roomInfo;
        _tournamentTeams = _extractTournamentTeams(roomInfo);
        _tournamentTeamIds = _tournamentTeams.map((t) => t.id).toSet();
        debugPrint('TournamentInfo: extracted tournament team IDs $_tournamentTeamIds');
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching room info: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openAddTeamSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add Team', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TeamAddForm(
                  onTeamAdded: (name, file) async {
                    final trimmed = name.trim();
                    if (trimmed.isEmpty) return;
                    try {
                      final bytes = await file!.readAsBytes();
                      await AuthService.addTeam(TeamAddDto(trimmed, bytes), widget.roomId);
                      _teamsKey.currentState?.reloadTeams();
                      await _initializeData();
                      if (mounted) Navigator.pop(ctx);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add team: $e')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<GetTeamsDto> _extractTournamentTeams(RoomInfoDto roomInfo) {
    final tournament = roomInfo.tournament;
    if (tournament == null) return [];
    final fallbackTournamentId = tournament.id;
    final result = <GetTeamsDto>[];
    for (final entry in tournament.teams) {
      final dto = _teamFromDynamic(entry, fallbackTournamentId);
      if (dto != null) {
        result.add(dto);
      }
    }
    return result;
  }

  GetTeamsDto? _teamFromDynamic(dynamic entry, int? fallbackTournamentId) {
    if (entry is Map<String, dynamic>) {
      Map<String, dynamic>? candidate;
      if (entry['team'] is Map<String, dynamic>) {
        candidate = Map<String, dynamic>.from(entry['team'] as Map<String, dynamic>);
      } else {
        candidate = Map<String, dynamic>.from(entry);
      }

      int? id = _asInt(candidate['id']) ?? _asInt(entry['teamId']) ?? _asInt(entry['id']);
      final String? name = candidate['name'] as String? ?? entry['name'] as String?;
      final int tournamentId = _asInt(candidate['tournamentId']) ?? _asInt(entry['tournamentId']) ?? fallbackTournamentId ?? 0;

      IconDto? icon;
      final iconRaw = candidate['icon'] ?? entry['icon'];
      if (iconRaw is Map<String, dynamic>) {
        try {
          icon = IconDto.fromJson(iconRaw);
        } catch (_) {}
      }

      if (id != null && name != null) {
        return GetTeamsDto(
          name: name,
          id: id,
          tournamentId: tournamentId,
          icon: icon,
        );
      }
    }
    return null;
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MyAppBar(title: 'Tournament Info'),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : GestureDetector(
                onHorizontalDragEnd: (DragEndDetails details) {
                  if (details.primaryVelocity! > 0) {
                    if (_tabController.index > 0) {
                      _tabController.animateTo(_tabController.index - 1);
                    }
                  } else if (details.primaryVelocity! < 0) {
                    if (_tabController.index < _tabController.length - 1) {
                      _tabController.animateTo(_tabController.index + 1);
                    }
                  }
                },
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    if (_roomInfo?.tournament != null)
                      TournamentOverviewTab(tournament: _roomInfo!.tournament!)
                    else
                      Center(
                        child: Text('No data available', style: TextStyle(color: Colors.white)),
                      ),
                    GamesTab(
                      roomId: widget.roomId,
                      tournamentId: _roomInfo?.tournament?.id,
                      allowedTeamIds: _tournamentTeamIds.isEmpty ? null : _tournamentTeamIds.toList(),
                      initialTeams: _tournamentTeams.isEmpty ? null : _tournamentTeams,
                    ),
                    Center(
                      child: TeamsShowPage(key: _teamsKey, roomId: widget.roomId),
                    ),
                    Center(
                      child: RoomUsersScreen(roomId: widget.roomId, role: role)
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: Material(
        color: Colors.black,
        child: buildTournamentBottomBar(
          context: context,
          tabController: _tabController,
          onTabSelected: (index) {
            setState(() {
              _tabController.animateTo(index);
            });
          },
        ),
      ),
      
      floatingActionButton: !_isLoading
          ? (_tabController.index == 0 && _roomInfo?.tournament != null)
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TournamentInfoEdit(
                          roomId: widget.roomId,
                          initialRoomInfo: _roomInfo,
                        ),
                      ),
                    );
                  },
                  backgroundColor: AppColors.accent,
                  child: const Icon(Icons.edit),
                )
              : (_tabController.index == 2)
                  ? FloatingActionButton(
                      onPressed: _openAddTeamSheet,
                      backgroundColor: AppColors.accent,
                      child: const Icon(Icons.group_add),
                    )
                  : null
          : null,
    );
  }
}
