import 'package:flutter/material.dart';
import 'package:sportsy_front/dto/get_room_dto.dart';
import 'package:sportsy_front/features/rooms/data/rooms_remote_service.dart';
import 'package:sportsy_front/screens/create_tournament_screen.dart';
import 'package:sportsy_front/core/auth/jwt_storage_service.dart';
import 'package:sportsy_front/screens/user_profile_page.dart';
import 'package:sportsy_front/features/weather/data/weather_remote_service.dart';
import 'package:sportsy_front/dto/weather_forecast_dto.dart';
import 'package:geolocator/geolocator.dart';
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
  bool _isLoadingWeather = false;
  String? _weatherError;
  WeatherForecastDto? _forecast;
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchRooms();
    _loadSavedCityAndWeather();
  }

  Future<void> _loadSavedCityAndWeather() async {
    final savedCity = await JwtStorageService.getCity();
    if (savedCity != null && savedCity.isNotEmpty) {
      _cityController.text = savedCity;
      await _loadWeatherByCity();
    } else {
      await _loadWeatherWithLocation();
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
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

  Future<Position?> _tryGetPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return Geolocator.getCurrentPosition();
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadWeatherWithLocation() async {
    setState(() {
      _isLoadingWeather = true;
      _weatherError = null;
    });

    try {
      final position = await _tryGetPosition();
      if (position == null) {
        setState(() {
          _weatherError = 'No location available. Enter a city to see the forecast.';
        });
        return;
      }

      final forecast = await WeatherRemoteService.getForecastByCoordinates(
        lat: position.latitude,
        lon: position.longitude,
      );

      if (!mounted) return;
      setState(() {
        _forecast = forecast;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _weatherError = 'Failed to fetch weather: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingWeather = false;
        });
      }
    }
  }

  Future<void> _loadWeatherByCity() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) {
      setState(() {
        _weatherError = 'Enter a city name.';
      });
      return;
    }

    setState(() {
      _isLoadingWeather = true;
      _weatherError = null;
    });

    try {
      final forecast = await WeatherRemoteService.getForecastByCity(city);
      if (!mounted) return;
      setState(() {
        _forecast = forecast;
      });
      // Save city for next app launch
      await JwtStorageService.storeCity(city);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _weatherError = 'Failed to fetch weather: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingWeather = false;
        });
      }
    }
  }

  List<ForecastItemDto> _pickNextFive(List<ForecastItemDto> all) {
    if (all.length <= 5) return all;
    final Map<String, ForecastItemDto> byDate = {};
    for (final item in all) {
      final date = item.dateTime.split(' ').first;
      byDate.putIfAbsent(date, () => item);
      if (byDate.length == 5) break;
    }
    if (byDate.isNotEmpty && byDate.length < 5) {
      for (final item in all) {
        if (byDate.length == 5) break;
        byDate[item.dateTime] = item;
      }
    }
    return byDate.values.toList();
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

  Widget _buildWeatherSection() {
    final theme = Theme.of(context).textTheme;
    final forecast = _forecast;
    final entries = forecast == null
        ? const <ForecastItemDto>[]
        : _pickNextFive(forecast.forecast);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.black.withOpacity(0.75),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud, color: Colors.white70),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '5-day weather',
                    style: theme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh using location',
                  onPressed: _isLoadingWeather ? null : _loadWeatherWithLocation,
                  icon: const Icon(Icons.my_location, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                hintText: 'City (fallback)',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  onPressed: _isLoadingWeather ? null : _loadWeatherByCity,
                  icon: const Icon(Icons.search, color: Colors.white70),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) => _loadWeatherByCity(),
            ),
            const SizedBox(height: 8),
            if (_isLoadingWeather)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (_weatherError != null)
              Text(
                _weatherError!,
                style: const TextStyle(color: Colors.redAccent),
              )
            else if (forecast != null && entries.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${forecast.city}, ${forecast.country}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...entries.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(
                              item.dateTime,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${item.description} | ${item.temperature.toStringAsFixed(1)}°C',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Text(
                            '${item.tempMin.toStringAsFixed(0)} / ${item.tempMax.toStringAsFixed(0)}°C',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            else
              const Text(
                'No weather data. Use location or enter a city.',
                style: TextStyle(color: Colors.white70),
              ),
          ],
        ),
      ),
    );
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

    Widget body;
    if (_selectedIndex == 0) {
      body = _buildWeatherSection();
    } else if (_selectedIndex == 2) {
      body = _buildProfileBody();
    } else {
      body = ListView.builder(
        itemCount: filteredGames.length,
        itemBuilder: (context, index) {
          return GameHomeWidget(gameDetails: filteredGames[index]);
        },
      );
    }

    return Scaffold(
      body: body,
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
