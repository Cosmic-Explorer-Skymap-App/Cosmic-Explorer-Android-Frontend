import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String username;
  final double radius;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    required this.username,
    this.radius = 20,
  });

  Color _colorFromUsername(String name) {
    const colors = [
      Color(0xFF6C63FF),
      Color(0xFF3D5AFE),
      Color(0xFFFF7043),
      Color(0xFFFFD54F),
      Color(0xFF00E5FF),
      Color(0xFFEF5350),
      Color(0xFF66BB6A),
      Color(0xFFAB47BC),
    ];
    final idx = name.codeUnitAt(0) % colors.length;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white12,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: avatarUrl!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            placeholder: (_, __) => _initials(),
            errorWidget: (_, __, ___) => _initials(),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: _colorFromUsername(username),
      child: Text(
        username.isNotEmpty ? username[0].toUpperCase() : '?',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.9,
        ),
      ),
    );
  }

  Widget _initials() {
    return Container(
      width: radius * 2,
      height: radius * 2,
      color: _colorFromUsername(username),
      alignment: Alignment.center,
      child: Text(
        username.isNotEmpty ? username[0].toUpperCase() : '?',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.9,
        ),
      ),
    );
  }
}
