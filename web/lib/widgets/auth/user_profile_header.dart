import 'package:flutter/material.dart';
import 'package:link_shortener/models/auth/user_session.dart';
import 'package:link_shortener/services/auth_service.dart';

class UserProfileHeader extends StatefulWidget {
  const UserProfileHeader({
    super.key,
    required this.userSession,
    required this.authService,
    this.onSignOutSuccess,
    this.onSignOutError,
  });

  final UserSession userSession;
  final AuthService authService;
  final VoidCallback? onSignOutSuccess;
  final void Function(String error)? onSignOutError;

  @override
  State<UserProfileHeader> createState() => _UserProfileHeaderState();
}

class _UserProfileHeaderState extends State<UserProfileHeader> {
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) => Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed('/profile');
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAvatar(context),
              const SizedBox(width: 8),
              Text(
                _getUserName(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );

  Widget _buildAvatar(BuildContext context) {
    final user = widget.userSession.user;

    if (user != null && user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(user.avatarUrl!),
      );
    } else {
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

  String _getUserName() {
    final user = widget.userSession.user;
    if (user == null) {
      return 'User';
    }
    return user.name.isNotEmpty ? user.name : 'User';
  }

  String _getUserInitials() {
    final user = widget.userSession.user;
    if (user == null) {
      return 'U';
    }
    
    final name = user.name;
    
    if (name.isEmpty) {
      if (user.email.isNotEmpty) {
        return user.email.substring(0, 1).toUpperCase();
      } else {
        return 'U';
      }
    }
    
    final parts = name.split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    } else {
      return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
    }
  }
}
