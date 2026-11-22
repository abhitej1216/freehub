import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:freehub/presentation/widgets/sonner_toast.dart';

/// Full-featured in-app web browser with progress indicator, navigation controls,
/// and external launch fallback for non-mobile platforms.
class InAppBrowserScreen extends StatefulWidget {
  final String url;
  final String title;

  const InAppBrowserScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<InAppBrowserScreen> createState() => _InAppBrowserScreenState();
}

class _InAppBrowserScreenState extends State<InAppBrowserScreen> {
  WebViewController? _controller;
  int _loadingProgress = 0;
  bool _canGoBack = false;
  bool _canGoForward = false;
  String _currentUrl = '';
  String _pageTitle = '';

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
    _pageTitle = widget.title;

    // WebView is supported on Android, iOS, and macOS
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      _initWebView();
    }
  }

  void _initWebView() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _loadingProgress = progress);
          },
          onPageStarted: (url) {
            if (mounted) {
              setState(() {
                _currentUrl = url;
                _loadingProgress = 10;
              });
              _updateNavigationState();
            }
          },
          onPageFinished: (url) async {
            if (mounted) {
              setState(() {
                _currentUrl = url;
                _loadingProgress = 100;
              });
              final title = await _controller?.getTitle();
              if (title != null && title.isNotEmpty && mounted) {
                setState(() => _pageTitle = title);
              }
              _updateNavigationState();
            }
          },
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    _controller = controller;
  }

  Future<void> _updateNavigationState() async {
    if (_controller == null) return;
    final canBack = await _controller!.canGoBack();
    final canForward = await _controller!.canGoForward();
    if (mounted) {
      setState(() {
        _canGoBack = canBack;
        _canGoForward = canForward;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Fallback UI for Web and Desktop platforms where native WebView isn't available
    final bool isMobileWebViewSupported = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS);

    return PopScope(
      canPop: !_canGoBack,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_controller != null && _canGoBack) {
          await _controller!.goBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _pageTitle.isNotEmpty ? _pageTitle : widget.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _currentUrl,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Reload',
              onPressed: () => _controller?.reload(),
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Share',
              onPressed: () => Share.share(_currentUrl, subject: _pageTitle),
            ),
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'external') {
                  _openInExternalBrowser(_currentUrl);
                } else if (val == 'copy') {
                  Clipboard.setData(ClipboardData(text: _currentUrl));
                  SonnerToast.copy(context, 'URL copied to clipboard!');
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'external',
                  child: Row(
                    children: [
                      Icon(Icons.open_in_new_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Open in Browser'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'copy',
                  child: Row(
                    children: [
                      Icon(Icons.copy_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Copy URL'),
                    ],
                  ),
                ),
              ],
            ),
          ],
          bottom: _loadingProgress < 100 && isMobileWebViewSupported
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(3),
                  child: LinearProgressIndicator(
                    value: _loadingProgress / 100.0,
                    minHeight: 3,
                  ),
                )
              : null,
        ),
        body: isMobileWebViewSupported && _controller != null
            ? WebViewWidget(controller: _controller!)
            : _buildNonMobileFallback(context),
        bottomNavigationBar: isMobileWebViewSupported
            ? BottomAppBar(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                      tooltip: 'Back',
                      onPressed: _canGoBack ? () => _controller?.goBack() : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                      tooltip: 'Forward',
                      onPressed:
                          _canGoForward ? () => _controller?.goForward() : null,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.open_in_browser_rounded),
                      tooltip: 'Open in External Browser',
                      onPressed: () => _openInExternalBrowser(_currentUrl),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildNonMobileFallback(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.devices_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Desktop / Web Mode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'External browser is recommended on this platform for the best experience.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Open in Browser'),
              onPressed: () => _openInExternalBrowser(widget.url),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openInExternalBrowser(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
