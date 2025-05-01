import 'package:flutter/material.dart';
import '../widgets/bottom_bar.dart';

class TeamUser extends StatefulWidget {
  const TeamUser({super.key});

  @override
  State<TeamUser> createState() => _TeamUser();
}

class _TeamUser extends State<TeamUser> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team User')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/teamuser');
            },
            child: const Text('Team User'),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
