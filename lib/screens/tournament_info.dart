import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/features/rooms/data/rooms_remote_service.dart';
import 'package:sportsy_front/features/teams/data/teams_remote_service.dart';
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
import 'package:sportsy_front/screens/games_page.dart';
import 'package:sportsy_front/screens/tournament_bracket_page.dart';

class TournamentInfoPage extends StatefulWidget {
  const TournamentInfoPage({
    super.key,
    required this.roomId,
    this.userRole = 'gameObserver',
  });
  final int roomId;
  final String userRole;

  @override
  State<TournamentInfoPage> createState() => _TournamentInfoPageState();
}

class _TournamentInfoPageState extends State<TournamentInfoPage>
    with SingleTickerProviderStateMixin {
  static const String _tabInfo = 'info';
  static const String _tabGames = 'games';
  static const String _tabTeams = 'teams';
  static const String _tabUsers = 'users';
  static const String _tabBracket = 'bracket';

  late TabController _tabController;
  RoomInfoDto? _roomInfo;
  bool _isLoading = true;
  late String _role;
  late List<String> _tabOrder;
  final GlobalKey<TeamsShowPageState> _teamsKey =
      GlobalKey<TeamsShowPageState>();
  final GlobalKey<GamesTabState> _gamesTabKey = GlobalKey<GamesTabState>();
  final GlobalKey<TournamentBracketPageState> _bracketKey =
      GlobalKey<TournamentBracketPageState>();
  Set<int> _tournamentTeamIds = {};
  List<GetTeamsDto> _tournamentTeams = [];

  bool get _isAdmin => _role == 'admin';
  bool get _isSpectator => _role == 'spectrator';
  bool get _canManageContent => _isAdmin || _isSpectator;

  /// Check if bracket exists (has games in leader tree)
  bool get _bracketExists {
    final leader = _roomInfo?.tournament?.leader;
    if (leader == null) return false;
    // Bracket exists if there's a root node or preGames
    return leader.root != null || leader.preGames.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _role = widget.userRole.toLowerCase();
    _tabOrder = _buildTabOrder(_role);
    _tabController = TabController(length: _tabOrder.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _initializeData();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final currentTab = _tabOrder[_tabController.index];
      if (currentTab == _tabBracket) {
        _bracketKey.currentState?.refreshBracket();
      }
    }
  }

  @override
  void didUpdateWidget(TournamentInfoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userRole != widget.userRole) {
      final newRole = widget.userRole.toLowerCase();
      final newOrder = _buildTabOrder(newRole);
      setState(() {
        _role = newRole;
        if (!listEquals(newOrder, _tabOrder)) {
          _tabOrder = newOrder;
          _tabController.removeListener(_onTabChanged);
          _tabController.dispose();
          _tabController = TabController(length: _tabOrder.length, vsync: this);
          _tabController.addListener(_onTabChanged);
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      final roomInfo = await RoomsRemoteService.getRoomInfo(widget.roomId);
      debugPrint(
        'TournamentInfo: fetched room info ${roomInfo.id}, tournament teams raw: ${roomInfo.tournament?.teams}',
      );
      setState(() {
        _roomInfo = roomInfo;
        _tournamentTeams = _extractTournamentTeams(roomInfo);
        _tournamentTeamIds = _tournamentTeams.map((t) => t.id).toSet();
        debugPrint(
          'TournamentInfo: extracted tournament team IDs $_tournamentTeamIds',
        );
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
    if (!_canManageContent) return;
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
                const Text(
                  'Add Team',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TeamAddForm(
                  onTeamAdded: (name, file) async {
                    final trimmed = name.trim();
                    if (trimmed.isEmpty) return;
                    try {
                      final bytes = await file!.readAsBytes();
                      await TeamsRemoteService.addTeam(
                        widget.roomId,
                        TeamAddDto(trimmed, bytes),
                      );
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
        candidate = Map<String, dynamic>.from(
          entry['team'] as Map<String, dynamic>,
        );
      } else {
        candidate = Map<String, dynamic>.from(entry);
      }

      int? id =
          _asInt(candidate['id']) ??
          _asInt(entry['teamId']) ??
          _asInt(entry['id']);
      final String? name =
          candidate['name'] as String? ?? entry['name'] as String?;
      final int tournamentId =
          _asInt(candidate['tournamentId']) ??
          _asInt(entry['tournamentId']) ??
          fallbackTournamentId ??
          0;

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
                  children: _tabOrder.map(_buildTabContent).toList(),
                ),
              ),
      bottomNavigationBar: Material(
        color: Colors.black,
        child: buildTournamentBottomBar(
          context: context,
          tabController: _tabController,
          tabs: _tabOrder.map(_tabFor).toList(),
          onTabSelected: (index) {
            setState(() {
              _tabController.animateTo(index);
            });
          },
        ),
      ),

      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  List<String> _buildTabOrder(String role) {
    final base = <String>[
      _tabInfo,
      _tabGames,
      _tabTeams,
      _tabUsers,
      _tabBracket,
    ];
    if (role == 'gameobserver') {
      base.remove(_tabUsers);
    }
    return base;
  }

  Tab _tabFor(String id) {
    switch (id) {
      case _tabInfo:
        return const Tab(icon: Icon(Icons.info), text: 'INFO');
      case _tabGames:
        return const Tab(icon: Icon(Icons.sports_esports), text: 'GAMES');
      case _tabTeams:
        return const Tab(icon: Icon(Icons.groups), text: 'TEAMS');
      case _tabUsers:
        return const Tab(icon: Icon(Icons.people), text: 'USERS');
      case _tabBracket:
        return const Tab(icon: Icon(Icons.leaderboard), text: 'BRACKET');
      default:
        return const Tab(icon: Icon(Icons.help_outline), text: 'UNKNOWN');
    }
  }

  Widget _buildTabContent(String id) {
    switch (id) {
      case _tabInfo:
        if (_roomInfo?.tournament != null) {
          return TournamentOverviewTab(tournament: _roomInfo!.tournament!);
        }
        return const Center(
          child: Text(
            'No data available',
            style: TextStyle(color: Colors.white),
          ),
        );
      case _tabGames:
        return GamesTab(
          key: _gamesTabKey,
          roomId: widget.roomId,
          tournamentId: _roomInfo?.tournament?.id,
          bracketExists: _bracketExists,
        );
      case _tabTeams:
        return TeamsShowPage(
          key: _teamsKey,
          roomId: widget.roomId,
          canManage: _canManageContent,
          bracketExists: _bracketExists,
        );
      case _tabUsers:
        return RoomUsersScreen(roomId: widget.roomId, role: _role);
      case _tabBracket:
        return TournamentBracketPage(
          key: _bracketKey,
          roomId: widget.roomId,
          tournamentId: _roomInfo?.tournament?.id,
          userRole: _role,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget? _buildFloatingActionButton() {
    if (_isLoading) return null;
    if (!_canManageContent) return null;
    if (_tabOrder.isEmpty) return null;

    final currentTab = _tabOrder[_tabController.index];
    switch (currentTab) {
      case _tabInfo:
        if (_roomInfo?.tournament == null) return null;
        return FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => TournamentInfoEdit(
                      roomId: widget.roomId,
                      initialRoomInfo: _roomInfo,
                      userRole: _role,
                    ),
              ),
            );
          },
          backgroundColor: AppColors.accent,
          child: const Icon(Icons.edit),
        );
      case _tabGames:
        if (_roomInfo?.tournament == null) return null;
        if (_bracketExists) return null; // Cannot add games when bracket exists
        return FloatingActionButton(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => GamesPage(
                      roomId: widget.roomId,
                      tournamentId: _roomInfo?.tournament?.id,
                      allowedTeamIds:
                          _tournamentTeamIds.isEmpty
                              ? null
                              : _tournamentTeamIds.toList(),
                    ),
              ),
            );
            _gamesTabKey.currentState?.reloadGames();
          },
          backgroundColor: AppColors.accent,
          child: const Icon(Icons.add),
        );
      case _tabTeams:
        if (_bracketExists) return null; // Cannot add teams when bracket exists
        return FloatingActionButton(
          onPressed: _openAddTeamSheet,
          backgroundColor: AppColors.accent,
          child: const Icon(Icons.group_add),
        );
      default:
        return null;
    }
  }
}
