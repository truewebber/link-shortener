import 'package:flutter/material.dart';
import 'package:link_shortener/models/auth/user.dart';
import 'package:link_shortener/screens/profile_screen.dart';
import 'package:link_shortener/screens/url_management_screen.dart';
import 'package:link_shortener/services/auth_service.dart';

/// A widget that displays the user's profile in the app header
class UserProfileHeader extends StatelessWidget {
  /// Creates a user profile header
  const UserProfileHeader({
    super.key,
    required this.userSession,
  });

  /// The current user session
  final UserSession userSession;

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
      offset: const Offset(0, 48),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            _buildAvatar(context),
            const SizedBox(width: 8),
            Text(
              _getUserName(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text('Profile'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'urls',
          child: Row(
            children: [
              Icon(
                Icons.link,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text('My URLs'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'signout',
          child: Row(
            children: [
              Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              const Text('Sign Out'),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'profile':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
            break;
          case 'urls':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UrlManagementScreen(),
              ),
            );
            break;
          case 'signout':
            _signOut(context);
            break;
        }
      },
    );

  Widget _buildAvatar(BuildContext context) {
    final user = userSession.user;
    
    // Check if the user has an avatar URL
    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(user.avatarUrl!),
      );
    } else {
      // If no avatar, use initials
      final initials = _getUserInitials();
      
      return CircleAvatar(
        radius: 16,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(
          initials,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  String _getUserName() => userSession.user.name;

  String _getUserInitials() {
    final name = userSession.user.name;
    
    if (name.isEmpty) {
      // If no name, use first letter of email
      return userSession.user.email.substring(0, 1).toUpperCase();
    }
    
    // Get initials from name
    final parts = name.split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    } else {
      return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final authService = AuthService();
    await authService.signOut();
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have been signed out.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
