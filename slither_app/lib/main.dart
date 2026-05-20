import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SlitherApp());
}

class SlitherApp extends StatelessWidget {
  const SlitherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slither.io',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1A2E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SlitherHome(),
    );
  }
}

class SlitherHome extends StatefulWidget {
  const SlitherHome({super.key});

  @override
  State<SlitherHome> createState() => _SlitherHomeState();
}

class _SlitherHomeState extends State<SlitherHome> {
  late WebViewController _controller;
  bool _isDesktop = false;
  bool _isLoading = true;

  static const String _mobileUA =
      'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

  static const String _desktopUA =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

  static const String _url = 'https://www.slither.io';

  @override
  void initState() {
    super.initState();
    _initWebView(desktop: false);
  }

  Future<void> _initWebView({required bool desktop}) async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..enableZoom(true)
      ..setUserAgent(desktop ? _desktopUA : _mobileUA)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) => setState(() => _isLoading = false),
        onWebResourceError: (error) async {
          debugPrint('WebView Error: ${error.errorCode} - ${error.description}');

          // Retry on cache miss
          if (error.errorCode == -1 || 
              error.description.contains("CACHE_MISS") ||
              error.description.contains("ERR_")) {
            await Future.delayed(const Duration(seconds: 1));
            await _controller.loadRequest(Uri.parse(_url));
          }
        },
      ));

    // Android Specific Optimizations
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidController = _controller.platform as AndroidWebViewController;

      await androidController.setMediaPlaybackRequiresUserGesture(false);
      await androidController.clearCache();
      await androidController.clearLocalStorage();
      
      // Important fixes for loading issues
      await androidController.setMixedContentMode(
        AndroidWebViewController.MIXED_CONTENT_ALWAYS_ALLOW,
      );
    }

    await _controller.loadRequest(Uri.parse(_url));
  }

  void _toggleMode() {
    setState(() {
      _isDesktop = !_isDesktop;
      _isLoading = true;
    });
    _initWebView(desktop: _isDesktop);
  }

  // Back Button Handler
  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D1A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1A2E),
          elevation: 0,
          title: Row(children: [
            const Text('🐍 Slither.io',
                style: TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        color: Colors.greenAccent, strokeWidth: 2)),
              ),
          ]),
          actions: [
            // Mode Toggle
            GestureDetector(
              onTap: _toggleMode,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: _isDesktop
                      ? Colors.greenAccent.withOpacity(0.2)
                      : Colors.transparent,
                  border: Border.all(
                      color: _isDesktop ? Colors.greenAccent : Colors.white38),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                      _isDesktop ? Icons.desktop_windows : Icons.smartphone,
                      size: 14,
                      color: _isDesktop ? Colors.greenAccent : Colors.white70),
                  const SizedBox(width: 5),
                  Text(_isDesktop ? 'Desktop' : 'Mobile',
                      style: TextStyle(
                          fontSize: 12,
                          color: _isDesktop
                              ? Colors.greenAccent
                              : Colors.white70,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
            // Refresh Button
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
              onPressed: () async {
                if (defaultTargetPlatform == TargetPlatform.android) {
                  final android = _controller.platform as AndroidWebViewController?;
                  if (android != null) {
                    await android.clearCache();
                    await android.clearLocalStorage();
                  }
                }
                await _controller.reload();
              },
            ),
          ],
        ),
        body: Stack(children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: const Color(0xFF0D0D1A),
              child: const Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('🐍', style: TextStyle(fontSize: 60)),
                SizedBox(height: 20),
                CircularProgressIndicator(color: Colors.greenAccent),
                SizedBox(height: 16),
                Text('Loading Slither.io...',
                    style:
                        TextStyle(color: Colors.greenAccent, fontSize: 16)),
              ])),
            ),
        ]),
      ),
    );
  }
}