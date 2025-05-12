import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/modules/services/auth.dart';
import 'package:sportsy_front/modules/tournament_services/tournament_info_struct.dart';
import 'package:sportsy_front/widgets/app_bar.dart';
import 'package:sportsy_front/widgets/bottom_app_bar.dart';
import 'package:sportsy_front/dto/room_info_dto.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      appBar: MyAppBar(
        title: 'Tournament Info',
        appBarChild: buildBotomForAppBar(_tabController),
      ),
      body: _isLoading
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
                  _buildInfoTab(),
                  Center(
                    child: Text('Widok gier', style: TextStyle(color: Colors.white)),
                  ),
                  Center(
                    child: Text(
                      'Widok drabinki',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("FloatingActionButton clicked!");
        },
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildInfoTab() {
    if (_roomInfo == null) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final tournament = _roomInfo!.tournament;

    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              tournament!.info.title,
              style: TextStyle(fontSize: 18.0, color: AppColors.accent),
            ),
            const SizedBox(height: 24.0),

            Text(
              'Description',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              tournament!.info.description,
              style: TextStyle(fontSize: 18.0, color: AppColors.accent),
            ),
            const SizedBox(height: 24.0),

            Text(
              'Date Start',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              tournament.info.dateStart.toString(),
              style: TextStyle(fontSize: 18.0, color: AppColors.accent),
            ),
            const SizedBox(height: 24.0),

            Text(
              'Date End',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              tournament.info.dateEnd.toString(),
              style: TextStyle(fontSize: 18.0, color: AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}
