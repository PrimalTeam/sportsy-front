import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';

/// Round picture for a room, team or user. Shows [image] when present and
/// otherwise falls back to [fallbackText] (e.g. an initial) or [fallbackIcon].
class EntityAvatar extends StatelessWidget {
  const EntityAvatar({
    super.key,
    this.image,
    this.fallbackIcon = Icons.image_outlined,
    this.fallbackText,
    this.size = 50,
    this.backgroundColor = const Color(0xff130f34),
    this.onEdit,
    this.isLoading = false,
  });

  final Uint8List? image;
  final IconData fallbackIcon;
  final String? fallbackText;
  final double size;
  final Color backgroundColor;

  /// When set, the avatar is tappable and shows a small camera badge.
  final VoidCallback? onEdit;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(shape: BoxShape.circle, color: backgroundColor),
      child: _content(),
    );

    if (onEdit == null) return avatar;

    final badgeSize = (size * 0.32).clamp(20.0, 36.0);
    return GestureDetector(
      onTap: isLoading ? null : onEdit,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Icon(
                Icons.photo_camera,
                size: badgeSize * 0.55,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: size * 0.4,
          height: size * 0.4,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (image != null) {
      return Image.memory(
        image!,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    if (fallbackText != null && fallbackText!.isNotEmpty) {
      return Center(
        child: Text(
          fallbackText!,
          style: TextStyle(
            fontSize: size * 0.4,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return Icon(fallbackIcon, color: Colors.white, size: size * 0.5);
  }
}
