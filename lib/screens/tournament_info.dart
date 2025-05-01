import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/modules/tournament_services/tournament_info_struct.dart';
import 'package:sportsy_front/widgets/app_bar.dart';
import 'package:sportsy_front/widgets/bottom_app_bar.dart';

class TournamentInfoPage extends StatefulWidget {
  final TournamentInfo tournamentDetails;

  const TournamentInfoPage({super.key, required this.tournamentDetails});

  @override
  State<TournamentInfoPage> createState() => _TournamentInfoPageState();
}

class _TournamentInfoPageState extends State<TournamentInfoPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      body: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity! > 0) {
            // Swiped right
            if (_tabController.index > 0) {
              _tabController.animateTo(_tabController.index - 1);
            }
          } else if (details.primaryVelocity! < 0) {
            // Swiped left
            if (_tabController.index < 2) {
              _tabController.animateTo(_tabController.index + 1);
            }
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildInfoTab(),

            // WIDOK GIER
            Center(
              child: Text('Widok gier', style: TextStyle(color: Colors.white)),
            ),

            // WIDOK DRABINEK
            Center(
              child: Text(
                'Widok drabinki',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
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
              widget
                  .tournamentDetails
                  .title, //TRZEBA BEDZIE STWORZYC LISTE DLA TURNIEJOW TAK JAK JEST DLA GIER
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
              widget.tournamentDetails.description.toString(),
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
              widget.tournamentDetails.dateStart.toString(),
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
              widget.tournamentDetails.dateEnd.toString(),
              style: TextStyle(fontSize: 18.0, color: AppColors.accent),
            ),
            const SizedBox(height: 24.0),

            Text(
              'Location',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Tu bedzie lokalizacja',
              style: TextStyle(fontSize: 18.0, color: AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}
