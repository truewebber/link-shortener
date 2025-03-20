import 'package:flutter/material.dart';
import 'package:link_shortener/models/auth/user.dart';

class UserProfileHeader extends StatelessWidget {
  const UserProfileHeader({
    super.key,
    required this.user,
    required this.onSignOut,
  });

  final User user;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
      offset: const Offset(0, 40),
      onSelected: (value) {
        if (value == 'sign_out') {
          onSignOut();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'profile',
          enabled: false, // Will be enabled in Sprint 3
          child: Row(
            children: [
              Icon(Icons.person),
              SizedBox(width: 8),
              Text('My Profile'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'links',
          enabled: false, // Will be enabled in Sprint 3
          child: Row(
            children: [
              Icon(Icons.link),
              SizedBox(width: 8),
              Text('My Links'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'sign_out',
          child: Row(
            children: [
              Icon(Icons.logout),
              SizedBox(width: 8),
              Text('Sign Out'),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 8),
            Text(
              user.name,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ],
        ),
      ),
    );

  Widget _buildAvatar() {
    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(user.avatarUrl!),
      );
    } else {
      // Fallback to initials avatar
      return CircleAvatar(
        radius: 16,
        backgroundColor: Colors.grey[300],
        child: Text(
          _getInitials(user.name),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}';
    } else if (parts.length == 1 && parts.first.isNotEmpty) {
      return parts.first[0];
    }
    
    return '';
  }
}
