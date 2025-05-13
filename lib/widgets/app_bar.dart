import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/screens/profile_jwt_test.dart';
import '../modules/services/jwt_logic.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({
    super.key,
    this.appBarChild,
    required this.title,
    this.onSearchChanged,
  });

  final String title;
  final Widget? appBarChild;
  final ValueChanged<String>? onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      toolbarHeight: preferredSize.height, // Explicitly set the toolbar height
      title: Padding(
        padding: const EdgeInsets.only(top: 8), // Add padding to push content below the safe area
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Ensure the column takes only the required space
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileJwtTestScreen(),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.black,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Container(
                //   width: 40,
                //   height: 40,
                //   decoration: const BoxDecoration(
                //     shape: BoxShape.circle,
                //   ),
                //   child: IconButton(
                //     icon: const Icon(Icons.settings, color: Colors.white),
                //     onPressed: () {
                //       JwtStorageService.clearTokens();
                //     },
                //   ),
                // ),
              ],
            ),
            if (appBarChild != null) ...[
              const SizedBox(height: 10),
              appBarChild!,
            ],
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(3),
        child: Container(
          height: 3,
          color: AppColors.accent,
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    double baseHeight = 60; // Base height for title and row
    double additionalHeight = appBarChild != null ? 40 : 0; // Height for appBarChild
    return Size.fromHeight(baseHeight + additionalHeight + 3); // +3 for the bottom line
  }
}