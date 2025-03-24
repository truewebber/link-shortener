import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:link_shortener/services/url_service.dart';

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

class _UrlShortenerFormState extends State<UrlShortenerForm> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _shortenedUrl;
  String? _errorMessage;
  bool _isValidUrl = false;
  late final UrlService _urlService;
  
  String _selectedTtl = '3m';

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
      });
      return;
    }
    
    try {
      final uri = Uri.parse(url);
      setState(() {
        _isValidUrl = uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
      });
    } catch (e) {
      setState(() {
        _isValidUrl = false;
      });
    }
  }

  @override
  void dispose() {
    _urlController..removeListener(_onUrlChanged)
    ..dispose();
    _animationController..stop()
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
    });
    
    try {
      final url = _urlController.text.trim();
      final shortenedUrl = await _urlService.shortenUrl(url);
      
      setState(() {
        _isLoading = false;
        _isSuccess = true;
        _shortenedUrl = shortenedUrl;
      });
      
      await _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to shorten URL. Please try again.';
      });
    }
  }
  
  DateTime? _getExpirationDate() {
    if (!widget.isAuthenticated) {
      return DateTime.now().add(const Duration(days: 91));
    }
    
    switch (_selectedTtl) {
      case 'never':
        return null;
      case '3m':
        return DateTime.now().add(const Duration(days: 91));
      case '6m':
        return DateTime.now().add(const Duration(days: 183));
      case '12m':
        return DateTime.now().add(const Duration(days: 365));
    }

    return null;
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
      _selectedTtl = '3m';
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
  
  String _formatDuration(Duration duration) {
    if (duration.inHours < 24) {
      return '${duration.inHours} hours';
    } else if (duration.inDays < 30) {
      return '${duration.inDays} days';
    } else if (duration.inDays < 365) {
      final months = (duration.inDays / 30).round();
      return '$months months';
    } else {
      final years = (duration.inDays / 365).round();
      return '$years years';
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
        DropdownButtonFormField<String>(
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

  List<DropdownMenuItem<String>> _getTTLDropdownElements() {
    if (!widget.isAuthenticated) {
      return [
        const DropdownMenuItem(
          value: '3m',
          child: Text('3 months'),
        )
      ];
    }

    return [
      const DropdownMenuItem(
        value: '3m',
        child: Text('3 months'),
      ),
      const DropdownMenuItem(
        value: '6m',
        child: Text('6 months'),
      ),
      const DropdownMenuItem(
        value: '12m',
        child: Text('12 months'),
      ),
      const DropdownMenuItem(
        value: 'never',
        child: Text('Never'),
      ),
    ];
  }

  Widget _buildFormView() => Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                errorText: !_isValidUrl && _urlController.text.isNotEmpty
                  ? 'Please enter a valid URL'
                  : null,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a URL';
                }
                if (!_isValidUrl) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
              onChanged: (value) {
                _onUrlChanged();
              },
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            if (widget.isAuthenticated) ...[
              const SizedBox(height: 16),
              _buildTtlOptions(),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading || !_isValidUrl ? null : _handleSubmit,
              child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text('SHORTEN URL'),
            ),
          ],
        ),
      ),
    );
  
  Widget _buildSuccessView() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'URL Shortened Successfully!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_selectedTtl != 'never')
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Link expires in: ${_formatDuration(_getExpirationDate()!.difference(DateTime.now()))}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withAlpha(128),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _shortenedUrl ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copy to clipboard',
                        onPressed: _copyToClipboard,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: OutlinedButton(
            onPressed: _resetForm,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Shorten another URL'),
          ),
        ),
      ],
    );

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _isSuccess ? _buildSuccessView() : _buildFormView(),
    );
}
