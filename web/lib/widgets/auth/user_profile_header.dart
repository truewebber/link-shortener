import 'package:flutter/material.dart';
import 'package:link_shortener/models/auth/user_session.dart';
import 'package:link_shortener/screens/profile_screen.dart';
import 'package:link_shortener/screens/url_management_screen.dart';
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
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isMenuOpen = false;
  }

  void _showMenu(BuildContext context) {
    if (_isMenuOpen) {
      _removeOverlay();
      return;
    }

    final button = context.findRenderObject() as RenderBox;
    final offset = Offset(0, button.size.height + 8);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 200,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: offset,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMenuItem(
                  context,
                  'Profile',
                  Icons.person,
                  onTap: () async {
                    _removeOverlay();
                    if (!mounted) return;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  'My URLs',
                  Icons.link,
                  onTap: () async {
                    _removeOverlay();
                    if (!mounted) return;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UrlManagementScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildMenuItem(
                  context,
                  'Sign Out',
                  Icons.logout,
                  isDestructive: true,
                  onTap: () async {
                    _removeOverlay();
                    if (!mounted) return;
                    await _signOut();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isMenuOpen = true;
  }

  Widget _buildMenuItem(
    BuildContext context,
    String text,
    IconData icon, {
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                color: isDestructive
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () => _showMenu(context),
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

  Future<void> _signOut() async {
    try {
      await widget.authService.signOut();
      widget.onSignOutSuccess?.call();
    } catch (e) {
      widget.onSignOutError?.call(e.toString());
    }
  }
}
