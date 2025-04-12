import 'package:flutter/material.dart';
import 'package:sportsy_front/modules/tournament_services/tournament_info_struct.dart';
import 'package:sportsy_front/widgets/app_bar.dart';

class AppColors {
  static const Color textColor = Color(0xFFFAFAFA);
  static const Color smallIconsColor = Color(0xFFD4AF37);
  static const Color largeIconsColor = Color(0xFFEFC15A);
  static const Color mainSurfaceColor = Color(0xFF222222);
  static const Color backgroundColor = Color(0xFF000000);
  static const Color errorColor = Color(0xFFE63946);
}

class TournamentInfoPage extends StatefulWidget {
  final TournamentInfo tournamentDetails; 

  const TournamentInfoPage({super.key, required this.tournamentDetails});

  @override
  State<TournamentInfoPage> createState() => _TournamentInfoPageState();
}

class _TournamentInfoPageState extends State<TournamentInfoPage> with SingleTickerProviderStateMixin {
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
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.tournamentDetails.title, style: TextStyle(color: AppColors.textColor)),
            const SizedBox(width: 8),
            Icon(Icons.circle_outlined, color: AppColors.smallIconsColor),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.more_vert, color: AppColors.smallIconsColor),
              onPressed: () {
               
              },
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.smallIconsColor,
          labelColor: AppColors.smallIconsColor,
          unselectedLabelColor: AppColors.textColor,
          tabs: const [
            Tab(text: 'INFO'),
            Tab(text: 'GAMES'),
            Tab(text: 'LEADER'),
          ],
        ),
        backgroundColor: AppColors.mainSurfaceColor,
        foregroundColor: AppColors.textColor,
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
              child: Text(
                'Widok gier',
                style: TextStyle(color: AppColors.textColor),
              ),
            ),
            
            // WIDOK DRABINEK
            Center(
              child: Text(
                'Widok drabinki',
                style: TextStyle(color: AppColors.textColor),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.mainSurfaceColor,
        selectedItemColor: AppColors.smallIconsColor,
        unselectedItemColor: AppColors.textColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.casino),
            label: 'Tournaments',
          ),
        ],
        onTap: (index) {
          // NAWIGACJA
        },
      ),
    );
  }
  
  Widget _buildInfoTab() {
    return Container(
      color: AppColors.mainSurfaceColor,
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
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              widget.tournamentDetails.title, //TRZEBA BEDZIE STWORZYC LISTE DLA TURNIEJOW TAK JAK JEST DLA GIER
              style: TextStyle(
                fontSize: 18.0,
                color: AppColors.smallIconsColor,
              ),
            ),
            const SizedBox(height: 24.0),
            
            Text(
              'Description',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Tu bedzie opis.',
              style: TextStyle(
                fontSize: 18.0,
                color: AppColors.smallIconsColor,
              ),
            ),
            const SizedBox(height: 24.0),
            
            Text(
              'Date Start',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Tu bedzie data rozpoczecia',
              style: TextStyle(
                fontSize: 18.0,
                color: AppColors.smallIconsColor,
              ),
            ),
            const SizedBox(height: 24.0),
            
            Text(
              'Date End',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Tu bedzie data zakonczenia.',
              style: TextStyle(
                fontSize: 18.0,
                color: AppColors.smallIconsColor,
              ),
            ),
            const SizedBox(height: 24.0),
            
            Text(
              'Location',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Tu bedzie lokalizacja',
              style: TextStyle(
                fontSize: 18.0,
                color: AppColors.smallIconsColor,
              ),
            ),
        ],
      ),
    ));
  }
}