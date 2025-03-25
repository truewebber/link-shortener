import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:link_shortener/models/short_url.dart';
import 'package:link_shortener/services/auth_service.dart';
import 'package:link_shortener/services/url_service.dart';

class UrlManagementScreen extends StatefulWidget {
  const UrlManagementScreen({
    super.key,
    this.authService,
    this.urlService,
  });

  final AuthService? authService;
  final UrlService? urlService;

  @override
  State<UrlManagementScreen> createState() => _UrlManagementScreenState();
}

class _UrlManagementScreenState extends State<UrlManagementScreen> {
  late final UrlService _urlService;
  late final AuthService _authService;
  
  List<ShortUrl>? _urls;
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _urlService = widget.urlService ?? UrlService();
    _authService = widget.authService ?? AuthService();
    _isLoading = true;
    _loadUrls();
  }
  
  Future<void> _loadUrls() async {
    if (!_authService.isAuthenticated) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please sign in to view your URLs';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final urls = await _urlService.getUserUrls(context: context);
      setState(() {
        _urls = urls;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load URLs: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _deleteUrl(ShortUrl url) async {
    try {
      final confirmed = await _showDeleteConfirmation(url);
      if (confirmed != true) return;
      
      setState(() {
        _isLoading = true;
      });
      
      await _urlService.deleteUrl(url.shortId, context: context);
      
      setState(() {
        _urls?.removeWhere((item) => item.shortId == url.shortId);
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('URL deleted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete URL: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _copyToClipboard(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
      await Future.delayed(Duration.zero);
    }
  }
  
  Future<bool?> _showDeleteConfirmation(ShortUrl url) => showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete URL'),
        content: Text(
          'Are you sure you want to delete the shortened URL for "${url.originalUrl}"?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  
  String _formatDate(DateTime date) => DateFormat.yMMMd().format(date);
  
  String _truncateUrl(String url, {int maxLength = 40}) {
    if (url.length <= maxLength) return url;
    return '${url.substring(0, maxLength)}...';
  }
  
  Widget _buildEmptyState() => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.link_off,
              size: 64,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 16),
            Text(
              'No URLs found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first shortened URL',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.add),
              label: const Text('Create Short URL'),
            ),
          ],
        ),
      ),
    );
  
  Widget _buildUrlList() => RefreshIndicator(
      onRefresh: _loadUrls,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _urls!.length,
        itemBuilder: (context, index) {
          final url = _urls![index];
          final isExpired = url.isExpired;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _truncateUrl(url.originalUrl, maxLength: 50),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          url.shortUrl,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: isExpired ? TextDecoration.lineThrough : null,
                            decorationColor: Colors.red,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copy URL',
                        onPressed: () => _copyToClipboard(url.shortUrl),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete URL',
                        onPressed: () => _deleteUrl(url),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        url.expiresAt != null
                          ? 'Expires ${_formatDate(url.expiresAt!)}'
                          : 'Never expires',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  
  @override
  Widget build(BuildContext context) {
    if (!_authService.isAuthenticated) {
      return Scaffold(
        body: Center(
          child: Text(
            'Please sign in to view your URLs',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My URLs'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My URLs'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUrls,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_urls == null || _urls!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My URLs'),
        ),
        body: _buildEmptyState(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My URLs'),
      ),
      body: _buildUrlList(),
    );
  }
}
