import 'package:flutter/material.dart';
import 'package:sportsy_front/dto/get_room_dto.dart';
import 'package:sportsy_front/features/rooms/data/rooms_remote_service.dart';
import 'package:sportsy_front/screens/create_tournament_screen.dart';
import 'package:sportsy_front/core/auth/jwt_storage_service.dart';
import 'package:sportsy_front/screens/user_profile_page.dart';
import '../widgets/app_bar.dart';
import '../widgets/game_home_widget.dart';
import '../widgets/bottom_bar_home.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;
  String? _currentUserEmail;
  bool _isLoadingProfile = false;
  String? _profileError;

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  String searchQuery = '';

  void onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
    });
  }

  List<GetRoomDto> roomsList = [];
  Future<void> fetchRooms() async {
    // zmieniono: Future<void>
    try {
      final rooms = await RoomsRemoteService.getRooms();
      if (!mounted) return;
      setState(() {
        // nowa instancja listy, żeby na pewno zainicjować rebuild
        roomsList = List<GetRoomDto>.from(rooms);
      });
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      _openCurrentUserProfile(); // teraz przełącza widok lokalnie
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _openCurrentUserProfile() async {
    // Przełącz na widok profilu i rozpocznij ładowanie e-maila
    setState(() {
      _selectedIndex = 2;
      _isLoadingProfile = true;
      _profileError = null;
    });

    try {
      final token = await JwtStorageService.getToken();
      if (token == null) {
        _profileError = 'Brak tokenu – zaloguj się ponownie.';
        return;
      }

      final String? email = JwtStorageService.getDataFromToken(token, 'email');
      if (email == null || email.isEmpty) {
        _profileError = 'Nie udało się odczytać adresu e-mail z tokenu.';
        return;
      }

      _currentUserEmail = email;
    } catch (e) {
      _profileError = 'Błąd otwierania profilu: $e';
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  Widget _buildProfileBody() {
    if (_isLoadingProfile) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_profileError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_profileError!),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _openCurrentUserProfile,
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      );
    }
    if (_currentUserEmail == null) {
      return const Center(child: Text('Brak danych profilu.'));
    }
    return UserProfilePage(username: _currentUserEmail!);
  }

  @override
  Widget build(BuildContext context) {
    final filteredGames =
        roomsList
            .where(
              (game) =>
                  game.name.toLowerCase().contains(searchQuery.toLowerCase()),
            )
            .toList();

    return Scaffold(
      appBar:
          _selectedIndex == 2
              ? AppBar(
                title: const Text('Profile'),
                automaticallyImplyLeading: false,
              )
              : MyAppBar(title: 'Games list'),
      body:
          _selectedIndex == 2
              ? _buildProfileBody()
              : ListView.builder(
                itemCount: filteredGames.length,
                itemBuilder: (context, index) {
                  return GameHomeWidget(gameDetails: filteredGames[index]);
                },
              ),
      bottomNavigationBar: BottomBarHome(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton:
          _selectedIndex == 2
              ? null
              : FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              CreateTournamentScreen(fetchRooms: fetchRooms),
                    ),
                  );
                },
                child: const Icon(Icons.add),
              ),
    );
  }
}
