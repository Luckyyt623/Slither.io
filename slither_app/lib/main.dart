import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    _initWebView(desktop: false);
  }

  void _initWebView({required bool desktop}) {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(desktop ? _desktopUA : _mobileUA)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse('http://slither.io'));
  }

  void _toggleMode() {
    setState(() {
      _isDesktop = !_isDesktop;
      _isLoading = true;
    });
    _initWebView(desktop: _isDesktop);
  }

  void _reload() {
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: Row(
          children: [
            const Text(
              '🐍 Slither.io',
              style: TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    color: Colors.greenAccent,
                    strokeWidth: 2,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          // Desktop / Normal toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: _toggleMode,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _isDesktop
                      ? Colors.greenAccent.withOpacity(0.2)
                      : Colors.transparent,
                  border: Border.all(
                    color: _isDesktop ? Colors.greenAccent : Colors.white38,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isDesktop ? Icons.desktop_windows : Icons.smartphone,
                      size: 14,
                      color: _isDesktop ? Colors.greenAccent : Colors.white70,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _isDesktop ? 'Desktop' : 'Mobile',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isDesktop ? Colors.greenAccent : Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Reload button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
            onPressed: _reload,
            tooltip: 'Reload',
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: const Color(0xFF0D0D1A),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🐍', style: TextStyle(fontSize: 60)),
                    SizedBox(height: 20),
                    CircularProgressIndicator(color: Colors.greenAccent),
                    SizedBox(height: 16),
                    Text(
                      'Loading Slither.io...',
                      style: TextStyle(color: Colors.greenAccent, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
