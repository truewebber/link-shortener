import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:link_shortener/models/ttl.dart';
import 'package:link_shortener/services/url_service.dart';
import 'package:link_shortener/utils/url_utils.dart';

class UrlShortenerForm extends StatefulWidget {
  const UrlShortenerForm({
    super.key,
    this.isAuthenticated = false,
    this.urlService,
  });

  final bool isAuthenticated;

  final UrlService? urlService;

  @override
  State<UrlShortenerForm> createState() => _UrlShortenerFormState();
}

class _UrlShortenerFormState extends State<UrlShortenerForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _shortenedUrl;
  String? _errorMessage;
  bool _isValidUrl = false;
  late final UrlService _urlService;

  TTL _selectedTtl = TTL.threeMonths;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _urlService = widget.urlService ?? UrlService();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _urlController.addListener(_onUrlChanged);
  }

  void _onUrlChanged() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _isValidUrl = false;
        _errorMessage = null;
      });
      return;
    }

    final isValid = UrlUtils.isValidUrl(url);
    final errorMessage = UrlUtils.getValidationErrorMessage(url);
    
    setState(() {
      _isValidUrl = isValid;
      _errorMessage = errorMessage;
    });
  }

  @override
  void dispose() {
    _urlController
      ..removeListener(_onUrlChanged)
      ..dispose();
    _animationController
      ..stop()
      ..dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isSuccess = false;
      _shortenedUrl = null;
    });

    try {
      final url = _urlController.text.trim();
      String shortenedUrl;

      if (!widget.isAuthenticated) {
        shortenedUrl = await _urlService.shortenRestrictedUrl(url);
      } else {
        shortenedUrl = await _urlService.createShortUrl(
          context: context,
          url: url,
          ttl: _selectedTtl,
        );
      }

      setState(() {
        _isLoading = false;
        _isSuccess = true;
        _shortenedUrl = shortenedUrl;
      });

      await _animationController.forward();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('URL shortened successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to shorten URL. Please try again.';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Reset the form to initial state
  void _resetForm() {
    setState(() {
      _isLoading = false;
      _isSuccess = false;
      _shortenedUrl = null;
      _errorMessage = null;
      _urlController.clear();
      _isValidUrl = false;
      _selectedTtl = TTL.threeMonths;
    });

    _animationController.reset();
  }

  Future<void> _copyToClipboard() async {
    if (_shortenedUrl == null) return;

    await Clipboard.setData(ClipboardData(text: _shortenedUrl!));
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL copied to clipboard'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildTtlOptions() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              'Link expiration',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          DropdownButtonFormField<TTL>(
            value: _selectedTtl,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedTtl = value;
                });
              }
            },
            items: _getTTLDropdownElements(),
          ),
        ],
      );

  List<DropdownMenuItem<TTL>> _getTTLDropdownElements() {
    if (!widget.isAuthenticated) {
      return [
        const DropdownMenuItem(
          value: TTL.threeMonths,
          child: Text('3 months'),
        )
      ];
    }

    return [
      const DropdownMenuItem(
        value: TTL.threeMonths,
        child: Text('3 months'),
      ),
      const DropdownMenuItem(
        value: TTL.sixMonths,
        child: Text('6 months'),
      ),
      const DropdownMenuItem(
        value: TTL.twelveMonths,
        child: Text('12 months'),
      ),
      const DropdownMenuItem(
        value: TTL.never,
        child: Text('Never'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(26),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isAuthenticated)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Links created by anonymous users expire after 3 months.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ),
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Enter URL to shorten',
                hintText: 'Paste your long URL here',
                prefixIcon: const Icon(Icons.link),
                errorText: _errorMessage,
                suffixIcon: _urlController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          _isValidUrl ? Icons.check_circle : Icons.error,
                          color: _isValidUrl
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () {
                          if (!_isValidUrl) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_errorMessage ?? 'Invalid URL'),
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        },
                      )
                    : null,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a URL';
                }
                if (!_isValidUrl) {
                  return _errorMessage;
                }
                return null;
              },
              onChanged: (value) {
                _onUrlChanged();
              },
            ),
            if (widget.isAuthenticated) ...[
              const SizedBox(height: 16),
              _buildTtlOptions(),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 12 : 16,
                  horizontal: isMobile ? 16 : 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: isMobile ? 16 : 20,
                      width: isMobile ? 16 : 20,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Shorten URL',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                      ),
                    ),
            ),
            if (_isSuccess && _shortenedUrl != null) ...[
              const SizedBox(height: 24),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 12 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your shortened URL:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _shortenedUrl!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: _copyToClipboard,
                              tooltip: 'Copy URL',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: _resetForm,
                              icon: const Icon(Icons.refresh),
                              label:
                                  Text(isMobile ? 'New URL' : 'Create Another'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
