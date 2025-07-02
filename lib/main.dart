import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:via/config/supabase_config.dart';
import 'package:via/core/utils/storage_setup_helper.dart';
import 'package:via/core/utils/supabase_auth_bridge.dart';
import 'package:via/core/utils/supabase_storage_service.dart';
import 'package:via/core/config/api_config.dart';
import 'package:via/core/services/error_handling_service.dart';
import 'package:via/core/services/logging_service.dart';
import 'generated/l10n/app_localizations.dart';
import 'core/utils/dependency_injection.dart' as di;
import 'core/navigation/app_router.dart';
import 'core/utils/localization_service.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize global error handler
  GlobalErrorHandler.initialize();

  // Initialize logging service
  await LoggingService.initialize();
  LoggingService.info('Application starting', context: 'main');

  // Initialize API configuration
  await ApiConfig.initialize();
  LoggingService.info('API configuration initialized', context: 'main');

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  LoggingService.info('Firebase initialized', context: 'main');

  // Initialize Firebase Auth (sign in anonymously for Firestore access)
  try {
    await FirebaseAuth.instance.signInAnonymously();
    LoggingService.info('Firebase Auth: Signed in anonymously', context: 'main');
  } catch (e) {
    LoggingService.error('Firebase Auth initialization failed: $e', context: 'main');
    ErrorHandlingService.handleError(e, StackTrace.current, context: 'Firebase Auth');
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  LoggingService.info('Supabase initialized', context: 'main');

  // Initialize Firebase-Supabase auth bridge
  await SupabaseAuthBridge.initialize();
  LoggingService.info('Auth bridge initialized', context: 'main');

  // Initialize Supabase storage buckets
  await SupabaseStorageService.initializeBuckets();
  LoggingService.info('Storage buckets initialized', context: 'main');

  // Run storage diagnostics
  await StorageSetupHelper.runDiagnostics();
  LoggingService.info('Storage diagnostics completed', context: 'main');

  // Initialize dependency injection
  await di.init();
  LoggingService.info('Dependency injection initialized', context: 'main');

  LoggingService.info('Application initialization completed', context: 'main');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);

    LoggingService.debug('Building MyApp', context: 'ui');

    return MaterialApp.router(
      title: 'VIA - Voice Interactive Assistant',

      // Localization
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocalizationService.supportedLocales,

      // Theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      // Router configuration
      routerConfig: router,

      // Debug banner
      debugShowCheckedModeBanner: false,
    );
  }
}
