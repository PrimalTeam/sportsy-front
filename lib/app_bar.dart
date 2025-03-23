import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
        toolbarHeight: 140,
        backgroundColor: const Color(0xff130f34),
        
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xff283963),
                  child: Icon(Icons.person, color: Colors.black),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Spacer(),
                Container(
                  width: 40,
                  height: 40,
                  
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xff283963),
                  ),
                  child: IconButton(
                    
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      // Add your settings action here
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(color: Colors.white),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xff283963),
              ),
            ),
          ],
        ),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
        height: 3,
        color: Colors.grey,
          ),
        ),
    );
  }
  
  @override

  Size get preferredSize => const Size.fromHeight(140 + 3);
}