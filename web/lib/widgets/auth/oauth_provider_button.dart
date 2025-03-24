import 'package:flutter/material.dart';
import 'package:link_shortener/models/auth/oauth_provider.dart';

class OAuthProviderButton extends StatefulWidget {
  const OAuthProviderButton({
    super.key,
    required this.provider,
    required this.onPressed,
  });

  final OAuthProvider provider;
  final VoidCallback onPressed;

  @override
  State<OAuthProviderButton> createState() => _OAuthProviderButtonState();
}

class _OAuthProviderButtonState extends State<OAuthProviderButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _hexToColor(widget.provider.backgroundColor);
    final textColor = _hexToColor(widget.provider.textColor);

    final buttonColor = _isPressed
        ? backgroundColor.withAlpha(204)
        : _isHovered
            ? backgroundColor.withAlpha(230)
            : backgroundColor;

    final elevation = _isPressed
        ? 1.0
        : _isHovered
            ? 4.0
            : 2.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              foregroundColor: textColor,
              backgroundColor: buttonColor,
              elevation: elevation,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Colors.grey.withAlpha(51),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Provider icon
                _buildProviderIcon(),
                const SizedBox(width: 12),
                Text(
                  'Continue with ${widget.provider.name}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProviderIcon() {
    final iconColor = _hexToColor(widget.provider.textColor);

    switch (widget.provider) {
      case OAuthProvider.google:
        return Icon(Icons.g_mobiledata, color: iconColor, size: 24);
      case OAuthProvider.apple:
        return Icon(Icons.apple, color: iconColor, size: 24);
      case OAuthProvider.github:
        return Icon(Icons.code, color: iconColor, size: 24);
      case OAuthProvider.unknown:
        return Icon(Icons.question_mark, color: iconColor, size: 24);
    }
  }

  Color _hexToColor(String hexString) {
    final hexCode = hexString.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
}
