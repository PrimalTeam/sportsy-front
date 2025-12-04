import 'package:flutter/material.dart';
import 'package:sportsy_front/core/theme/app_colors.dart';

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
      toolbarHeight: preferredSize.height,
      title: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {},
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
        child: Container(height: 3, color: AppColors.accent),
      ),
    );
  }

  @override
  Size get preferredSize {
    const double baseHeight = 60;
    const double dividerHeight = 3;
    final double additionalHeight = appBarChild != null ? 40 : 0;
    return Size.fromHeight(baseHeight + additionalHeight + dividerHeight);
  }
}
