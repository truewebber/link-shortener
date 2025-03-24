import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:link_shortener/models/short_url.dart';
import 'package:link_shortener/services/auth_service.dart';
import 'package:link_shortener/services/url_service.dart';

class UrlManagementScreen extends StatefulWidget {
  const UrlManagementScreen({super.key});

  @override
  State<UrlManagementScreen> createState() => _UrlManagementScreenState();
}

class _UrlManagementScreenState extends State<UrlManagementScreen> {
  final _urlService = UrlService();
  final _authService = AuthService();
  
  List<ShortUrl>? _urls;
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadUrls();
  }
  
  Future<void> _loadUrls() async {
    if (!_authService.isAuthenticated) {
      Navigator.of(context).pop();
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final urls = await _urlService.getUserUrls();
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
      
      await _urlService.deleteUrl(url.shortId);
      
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
    }
  }
  
  Future<bool?> _showDeleteConfirmation(ShortUrl url) => showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete URL'),
        content: Text(
          'Are you sure you want to delete the shortened URL for "${_truncateUrl(url.originalUrl)}"?\n\n'
          'This action cannot be undone.'
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
              'You haven\'t created any shortened URLs yet.',
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
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Wrap(
                    spacing: 16,
                    children: [
                      Text(
                        'Created: ${_formatDate(url.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      
                      if (url.expiresAt != null)
                        Text(
                          'Expires: ${_formatDate(url.expiresAt!)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isExpired 
                              ? Colors.red 
                              : Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      
                      Text(
                        'Clicks: ${url.clickCount}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _deleteUrl(url),
                        icon: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        label: Text(
                          'Delete',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.error.withAlpha(128),
                          ),
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
  
  Widget _buildErrorState() => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unknown error occurred',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadUrls,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('My URLs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadUrls,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _urls == null || _urls!.isEmpty
                  ? _buildEmptyState()
                  : _buildUrlList(),
    );
}
