import 'package:flutter/material.dart';
import '../widgets/bottom_bar.dart';

class TeamStatus extends StatefulWidget {
  const TeamStatus({super.key});

  @override
  State<TeamStatus> createState() => _TeamStatus();
}

class _TeamStatus extends State<TeamStatus> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team Status')),
      body: const Center(child: Text('TeamStatus')),

      bottomNavigationBar: BottomBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
