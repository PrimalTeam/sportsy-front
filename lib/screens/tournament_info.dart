import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/modules/services/auth.dart';
import 'package:sportsy_front/screens/room_users_screen.dart';
import 'package:sportsy_front/screens/teams_show_page.dart';
import 'package:sportsy_front/widgets/app_bar.dart';
import 'package:sportsy_front/widgets/tournament_bottom_bar.dart';
import 'package:sportsy_front/dto/room_info_dto.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final roomInfo = await AuthService.getRoomInfo(widget.roomId);
      print(roomInfo);
      setState(() {
        _roomInfo = roomInfo;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching room info: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                    if (_tabController.index < 2) {
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
                    Center(
                      child: Text(
                        'Widok gier',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Center(
                      child: TeamsShowPage(roomId: widget.roomId),
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
      
      floatingActionButton: (_tabController.index == 0 && !_isLoading && _roomInfo?.tournament != null)
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
          : null,
    );
  }
}
