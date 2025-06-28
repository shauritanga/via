import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/documents/presentation/screens/document_list_screen.dart';
import '../../features/documents/presentation/screens/document_reader_screen.dart';
import '../../features/documents/presentation/screens/document_upload_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/accessibility_settings_screen.dart';
import '../../features/settings/presentation/screens/voice_settings_screen.dart';
import '../../features/voice_commands/presentation/screens/voice_commands_screen.dart';
import '../screens/home_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';

// Route names for voice navigation
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String documents = '/documents';
  static const String documentReader = '/documents/reader';
  static const String documentUpload = '/documents/upload';
  static const String settings = '/settings';
  static const String accessibilitySettings = '/settings/accessibility';
  static const String voiceSettings = '/settings/voice';
  static const String voiceCommands = '/voice-commands';
  static const String help = '/help';
}

// Router configuration
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding screen
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Home screen with bottom navigation
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          // Documents section
          GoRoute(
            path: AppRoutes.documents,
            name: 'documents',
            builder: (context, state) => const DocumentListScreen(),
            routes: [
              // Document reader
              GoRoute(
                path: '/reader/:documentId',
                name: 'document-reader',
                builder: (context, state) {
                  final documentId = state.pathParameters['documentId']!;
                  return DocumentReaderScreen(documentId: documentId);
                },
              ),
              // Document upload
              GoRoute(
                path: '/upload',
                name: 'document-upload',
                builder: (context, state) => const DocumentUploadScreen(),
              ),
            ],
          ),

          // Voice commands screen
          GoRoute(
            path: AppRoutes.voiceCommands,
            name: 'voice-commands',
            builder: (context, state) => const VoiceCommandsScreen(),
          ),

          // Settings section
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              // Accessibility settings
              GoRoute(
                path: '/accessibility',
                name: 'accessibility-settings',
                builder: (context, state) => const AccessibilitySettingsScreen(),
              ),
              // Voice settings
              GoRoute(
                path: '/voice',
                name: 'voice-settings',
                builder: (context, state) => const VoiceSettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Help screen (can be accessed from anywhere)
      GoRoute(
        path: AppRoutes.help,
        name: 'help',
        builder: (context, state) => const HelpScreen(),
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
});

// Voice navigation service
class VoiceNavigationService {
  static final Map<String, String> _voiceRouteMap = {
    // English commands
    'home': AppRoutes.home,
    'documents': AppRoutes.documents,
    'upload': AppRoutes.documentUpload,
    'settings': AppRoutes.settings,
    'voice commands': AppRoutes.voiceCommands,
    'accessibility': AppRoutes.accessibilitySettings,
    'voice settings': AppRoutes.voiceSettings,
    'help': AppRoutes.help,
    
    // Swahili commands
    'nyumbani': AppRoutes.home,
    'hati': AppRoutes.documents,
    'pakia': AppRoutes.documentUpload,
    'mipangilio': AppRoutes.settings,
    'amri za sauti': AppRoutes.voiceCommands,
    'ufikaji': AppRoutes.accessibilitySettings,
    'mipangilio ya sauti': AppRoutes.voiceSettings,
    'msaada': AppRoutes.help,
  };

  static String? getRouteFromVoiceCommand(String command) {
    final normalizedCommand = command.toLowerCase().trim();
    
    // Direct match
    if (_voiceRouteMap.containsKey(normalizedCommand)) {
      return _voiceRouteMap[normalizedCommand];
    }
    
    // Partial match
    for (final entry in _voiceRouteMap.entries) {
      if (normalizedCommand.contains(entry.key) || entry.key.contains(normalizedCommand)) {
        return entry.value;
      }
    }
    
    return null;
  }

  static List<String> getAvailableVoiceRoutes(String language) {
    if (language == 'sw') {
      return [
        'nyumbani',
        'hati',
        'pakia',
        'mipangilio',
        'amri za sauti',
        'ufikaji',
        'mipangilio ya sauti',
        'msaada',
      ];
    } else {
      return [
        'home',
        'documents',
        'upload',
        'settings',
        'voice commands',
        'accessibility',
        'voice settings',
        'help',
      ];
    }
  }

  static String getRouteDescription(String route, String language) {
    final descriptions = {
      AppRoutes.home: language == 'sw' ? 'Ukurasa wa nyumbani' : 'Home screen',
      AppRoutes.documents: language == 'sw' ? 'Orodha ya hati' : 'Document list',
      AppRoutes.documentUpload: language == 'sw' ? 'Pakia hati mpya' : 'Upload new document',
      AppRoutes.settings: language == 'sw' ? 'Mipangilio ya programu' : 'App settings',
      AppRoutes.voiceCommands: language == 'sw' ? 'Amri za sauti' : 'Voice commands',
      AppRoutes.accessibilitySettings: language == 'sw' ? 'Mipangilio ya ufikaji' : 'Accessibility settings',
      AppRoutes.voiceSettings: language == 'sw' ? 'Mipangilio ya sauti' : 'Voice settings',
      AppRoutes.help: language == 'sw' ? 'Msaada na maelezo' : 'Help and instructions',
    };
    
    return descriptions[route] ?? route;
  }
}

// Navigation extensions for voice commands
extension VoiceNavigation on GoRouter {
  void navigateByVoice(String voiceCommand, {String language = 'en'}) {
    final route = VoiceNavigationService.getRouteFromVoiceCommand(voiceCommand);
    if (route != null) {
      go(route);
    }
  }
  
  void announceCurrentRoute(String language) {
    final currentRoute = routerDelegate.currentConfiguration.uri.path;
    final description = VoiceNavigationService.getRouteDescription(currentRoute, language);
    
    // This would trigger TTS to announce the current screen
    // Implementation would depend on your TTS service
  }
}

// Route transition animations
class SlideTransitionPage extends CustomTransitionPage<void> {
  const SlideTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionsBuilder: _slideTransition,
          transitionDuration: const Duration(milliseconds: 300),
        );

  static Widget _slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOut)),
      ),
      child: child,
    );
  }
}

class FadeTransitionPage extends CustomTransitionPage<void> {
  const FadeTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionsBuilder: _fadeTransition,
          transitionDuration: const Duration(milliseconds: 200),
        );

  static Widget _fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

// Error screen
class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

// Help screen
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      body: const Center(
        child: Text('Help content will be implemented here'),
      ),
    );
  }
}
