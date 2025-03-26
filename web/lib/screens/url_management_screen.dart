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

    // Use addPostFrameCallback to ensure loading state is visible in first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUrls();
    });
  }

  Future<void> _loadUrls() async {
    if (!_authService.isAuthenticated) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please sign in to view your URLs';
      });
      return;
    }

    try {
      final urls = await _urlService.getUserUrls(context: context);
      if (mounted) {
        setState(() {
          _urls = urls;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load URLs: ${e.toString()}';
          _isLoading = false;
        });
      }
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
    try {
      await Clipboard.setData(ClipboardData(text: url));

      if (!mounted) return;

      // Show snackbar immediately after clipboard operation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to copy URL: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool?> _showDeleteConfirmation(ShortUrl url) => showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete URL'),
          content: Text(
              'Are you sure you want to delete the shortened URL for "${url.originalUrl}"?'),
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
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  decoration: isExpired
                                      ? TextDecoration.lineThrough
                                      : null,
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
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Created ${_formatDate(url.createdAt)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        if (url.expiresAt != null) ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.timer,
                            size: 16,
                            color: isExpired ? Colors.red : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isExpired
                                ? 'Expired'
                                : 'Expires ${_formatDate(url.expiresAt!)}',
                            style: TextStyle(
                              color: isExpired ? Colors.red : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadUrls,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_urls == null || _urls!.isEmpty) {
      return _buildEmptyState();
    }

    return _buildUrlList();
  }
}
