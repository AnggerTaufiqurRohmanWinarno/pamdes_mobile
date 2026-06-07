import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Inisialisasi WebView
  WebViewPlatform.instance = AndroidWebViewPlatform();

  runApp(const PamdesApp());
}

class PamdesApp extends StatelessWidget {
  const PamdesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PAMDES Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xffeef0f3),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),

      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
      },
    );
  }
}