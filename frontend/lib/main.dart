import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';
import 'package:frontend/presentation/providers/detection_provider.dart';
import 'package:frontend/presentation/providers/history_provider.dart';
import 'package:frontend/presentation/screens/about/about_screen.dart';
import 'package:frontend/presentation/screens/auth/login_screen.dart';
import 'package:frontend/presentation/screens/detect/detection_details_screen.dart';
import 'package:frontend/presentation/screens/detect/image_detect_screen.dart';
import 'package:frontend/presentation/screens/detect/text_detect_screen.dart';
import 'package:frontend/presentation/screens/detect/voice_detect_screen.dart';
import 'package:frontend/presentation/screens/help/help_screen.dart';
import 'package:frontend/presentation/screens/history/history_list_screen.dart';
import 'package:frontend/presentation/screens/home/dashboard_screen.dart';
import 'package:frontend/presentation/screens/profile/profile_screen.dart';
import 'package:frontend/presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TrustLayerApp());
}

class TrustLayerApp extends StatelessWidget {
  const TrustLayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DetectionProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: MaterialApp(
        title: 'TrustLayer',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/dashboard': (_) => const DashboardScreen(),
          '/history': (_) => const HistoryListScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/about': (_) => const AboutScreen(),
          '/help': (_) => const HelpScreen(),
          '/detect/text': (_) => const TextDetectScreen(),
          '/detect/image': (_) => const ImageDetectScreen(),
          '/detect/voice': (_) => const VoiceDetectScreen(),
          '/detection-details': (_) => const DetectionDetailsScreen(),
        },
      ),
    );
  }
}
