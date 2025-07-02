// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:via/main.dart';
import 'package:via/core/config/api_config.dart';

void main() {
  group('VIA App Tests', () {
    setUpAll(() async {
      // Initialize API configuration for tests
      await ApiConfig.initialize();
    });

    testWidgets('App should start without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MyApp(),
        ),
      );
      
      // Wait for initial build
      await tester.pump();
      
      // Verify that the app renders without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should have proper title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MyApp(),
        ),
      );
      
      await tester.pump();
      
      // Check for the app title in the MaterialApp
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, equals('VIA - Voice Interactive Assistant'));
    });

    testWidgets('App should support multiple languages', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MyApp(),
        ),
      );
      
      await tester.pump();
      
      // Verify that the app supports localization
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.localizationsDelegates, isNotEmpty);
      expect(materialApp.supportedLocales, isNotEmpty);
    });

    test('API Configuration should work correctly', () {
      // Test configuration status
      final status = ApiConfig.getConfigStatus();
      expect(status, isA<Map<String, dynamic>>());
      expect(status['openAiConfigured'], isA<bool>());
      expect(status['googleTranslateConfigured'], isA<bool>());
    });

    test('API Key validation should work', () {
      // Test OpenAI key validation
      expect(ApiConfig.isValidOpenAiKey('sk-test123456789012345678901234567890'), isTrue);
      expect(ApiConfig.isValidOpenAiKey('invalid-key'), isFalse);
      
      // Test Google key validation
      expect(ApiConfig.isValidGoogleKey('AIzaSyC12345678901234567890123456789012345'), isTrue);
      expect(ApiConfig.isValidGoogleKey('invalid'), isFalse);
    });

    test('API Key management should work', () async {
      // Test setting and getting API keys
      await ApiConfig.setOpenAiApiKey('sk-test123456789012345678901234567890');
      
      // Clear keys after test
      await ApiConfig.clearAllApiKeys();
    });

    test('Headers generation should work', () {
      // Test OpenAI headers
      final openAiHeaders = ApiConfig.openAiHeaders;
      expect(openAiHeaders['Content-Type'], equals('application/json'));
      
      // Test Google Translate headers
      final googleHeaders = ApiConfig.googleTranslateHeaders;
      expect(googleHeaders['Content-Type'], equals('application/json'));
    });
  });
}
