import 'package:flutter/material.dart';

class BottomBarHome extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomBarHome({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.amber,
      unselectedItemColor: Colors.white,
      backgroundColor: Colors.grey[900],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events),
          label: 'Tournaments',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
