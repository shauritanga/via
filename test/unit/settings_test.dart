import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:via/features/settings/domain/entities/app_settings.dart';
import 'package:via/features/settings/presentation/screens/settings_screen.dart';
import 'package:via/features/settings/presentation/screens/voice_settings_screen.dart';
import 'package:via/features/settings/presentation/screens/accessibility_settings_screen.dart';
import 'package:via/features/settings/presentation/providers/settings_providers.dart';

void main() {
  group('Settings Feature Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Settings Screen', () {
      testWidgets('should display all settings sections', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(home: SettingsScreen()),
          ),
        );

        await tester.pump();

        // Check for main settings sections
        expect(find.text('Language'), findsOneWidget);
        expect(find.text('Speech Settings'), findsOneWidget);
        expect(find.text('Voice Commands'), findsOneWidget);
        expect(find.text('Accessibility Settings'), findsOneWidget);
        expect(find.text('About'), findsOneWidget);
        expect(find.text('Help'), findsOneWidget);
      });

      testWidgets('should show language selector', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(home: SettingsScreen()),
          ),
        );

        await tester.pump();

        // Check for language selector
        expect(find.byType(Card), findsWidgets);
        expect(find.text('Language'), findsOneWidget);
      });

      testWidgets('should navigate to voice settings', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(home: SettingsScreen()),
          ),
        );

        await tester.pump();

        // Tap on voice settings
        await tester.tap(find.text('Speech Settings'));
        await tester.pumpAndSettle();

        // Should navigate to voice settings screen
        expect(find.text('Speech Settings'), findsOneWidget);
      });

      testWidgets('should navigate to accessibility settings', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(home: SettingsScreen()),
          ),
        );

        await tester.pump();

        // Tap on accessibility settings
        await tester.tap(find.text('Accessibility Settings'));
        await tester.pumpAndSettle();

        // Should navigate to accessibility settings screen
        expect(find.text('Accessibility Settings'), findsOneWidget);
      });

      testWidgets('should show about dialog', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(home: SettingsScreen()),
          ),
        );

        await tester.pump();

        // Tap on about
        await tester.tap(find.text('About'));
        await tester.pumpAndSettle();

        // Should show about dialog
        expect(find.text('VIA'), findsOneWidget);
        expect(find.text('Voice Interactive Assistant'), findsOneWidget);
      });
    });

    group('Voice Settings Screen', () {
      testWidgets('should display TTS settings', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(home: VoiceSettingsScreen()),
          ),
        );

        await tester.pump();

        // Check for TTS settings widget
        expect(find.byType(Card), findsWidgets);
      });

      testWidgets('should display voice command settings', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(home: VoiceSettingsScreen()),
          ),
        );

        await tester.pump();

        // Check for voice command settings
        expect(find.text('Voice Command Settings'), findsOneWidget);
        expect(find.text('Continuous Listening'), findsOneWidget);
        expect(find.text('Recognition Confidence'), findsOneWidget);
        expect(find.text('Listening Timeout'), findsOneWidget);
        expect(find.text('Wake Word'), findsOneWidget);
        expect(find.text('Voice Confirmation'), findsOneWidget);
      });

      testWidgets('should handle continuous listening toggle', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(home: VoiceSettingsScreen()),
          ),
        );

        await tester.pump();

        // Find and tap the continuous listening switch
        final switchFinder = find.byType(Switch);
        expect(switchFinder, findsWidgets);

        await tester.tap(switchFinder.first);
        await tester.pump();
      });

      testWidgets('should handle confidence slider', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(home: VoiceSettingsScreen()),
          ),
        );

        await tester.pump();

        // Find confidence slider
        final sliderFinder = find.byType(Slider);
        expect(sliderFinder, findsWidgets);

        // Test slider interaction
        final slider = tester.widget<Slider>(sliderFinder.first);
        expect(slider.value, isA<double>());
        expect(slider.min, 0.5);
        expect(slider.max, 1.0);
      });
    });

    group('Accessibility Settings Screen', () {
      testWidgets('should display visual settings', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(home: AccessibilitySettingsScreen()),
          ),
        );

        await tester.pump();

        // Check for visual settings
        expect(find.text('Visual Settings'), findsOneWidget);
        expect(find.text('High Contrast Mode'), findsOneWidget);
        expect(find.text('Text Size'), findsOneWidget);
      });

      testWidgets('should display audio settings', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(home: AccessibilitySettingsScreen()),
          ),
        );

        await tester.pump();

        // Check for audio settings
        expect(find.text('Audio Settings'), findsOneWidget);
        expect(find.text('Voice Feedback'), findsOneWidget);
        expect(find.text('Screen Reader Support'), findsOneWidget);
      });

      testWidgets('should display interaction settings', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(home: AccessibilitySettingsScreen()),
          ),
        );

        await tester.pump();

        // Check for interaction settings
        expect(find.text('Interaction Settings'), findsOneWidget);
        expect(find.text('Haptic Feedback'), findsOneWidget);
      });

      testWidgets('should handle high contrast toggle', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(home: AccessibilitySettingsScreen()),
          ),
        );

        await tester.pump();

        // Find and tap the high contrast switch
        final switchFinder = find.byType(Switch);
        expect(switchFinder, findsWidgets);

        await tester.tap(switchFinder.first);
        await tester.pump();
      });

      testWidgets('should handle text scale slider', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(home: AccessibilitySettingsScreen()),
          ),
        );

        await tester.pump();

        // Find text scale slider
        final sliderFinder = find.byType(Slider);
        expect(sliderFinder, findsWidgets);

        // Test slider interaction
        final slider = tester.widget<Slider>(sliderFinder.first);
        expect(slider.value, isA<double>());
        expect(slider.min, 0.8);
        expect(slider.max, 2.0);
      });
    });

    group('Settings Providers', () {
      test('should provide default app settings', () async {
        final settingsAsync = container.read(appSettingsProvider);

        await expectLater(settingsAsync, completion(isA<AppSettings>()));
      });

      test('should provide default TTS settings', () async {
        final ttsSettingsAsync = container.read(ttsSettingsProvider);

        await expectLater(ttsSettingsAsync, completion(isA<TTSPreferences>()));
      });

      test('should provide default accessibility settings', () async {
        final accessibilitySettingsAsync = container.read(
          accessibilitySettingsProvider,
        );

        await expectLater(
          accessibilitySettingsAsync,
          completion(isA<AccessibilitySettings>()),
        );
      });

      test('should provide default voice command settings', () async {
        final voiceCommandSettingsAsync = container.read(
          voiceCommandSettingsProvider,
        );

        await expectLater(
          voiceCommandSettingsAsync,
          completion(isA<VoiceCommandSettings>()),
        );
      });
    });

    group('Settings Entities', () {
      test('AppSettings should support copyWith', () {
        const originalSettings = AppSettings(
          language: 'en',
          ttsPreferences: TTSPreferences(
            speechRate: 1.0,
            pitch: 1.0,
            volume: 1.0,
            preferredVoice: '',
            enablePunctuation: true,
            enableEmphasis: true,
          ),
          accessibilitySettings: AccessibilitySettings(
            highContrastMode: false,
            textScaleFactor: 1.0,
            enableVoiceFeedback: true,
            enableHapticFeedback: true,
            enableScreenReader: true,
            voiceCommandTimeout: 5000,
          ),
          voiceCommandSettings: VoiceCommandSettings(
            enableContinuousListening: false,
            minimumConfidence: 0.7,
            listeningTimeout: 5000,
            enableWakeWord: false,
            wakeWord: 'via',
            enableVoiceConfirmation: true,
          ),
        );

        final updatedSettings = originalSettings.copyWith(language: 'sw');

        expect(updatedSettings.language, equals('sw'));
        expect(
          updatedSettings.ttsPreferences,
          equals(originalSettings.ttsPreferences),
        );
      });

      test('TTSPreferences should support copyWith', () {
        const originalTTS = TTSPreferences(
          speechRate: 1.0,
          pitch: 1.0,
          volume: 1.0,
          preferredVoice: '',
          enablePunctuation: true,
          enableEmphasis: true,
        );

        final updatedTTS = originalTTS.copyWith(speechRate: 1.5, pitch: 1.2);

        expect(updatedTTS.speechRate, equals(1.5));
        expect(updatedTTS.pitch, equals(1.2));
        expect(updatedTTS.volume, equals(1.0));
      });

      test('AccessibilitySettings should support copyWith', () {
        const originalAccessibility = AccessibilitySettings(
          highContrastMode: false,
          textScaleFactor: 1.0,
          enableVoiceFeedback: true,
          enableHapticFeedback: true,
          enableScreenReader: true,
          voiceCommandTimeout: 5000,
        );

        final updatedAccessibility = originalAccessibility.copyWith(
          highContrastMode: true,
          textScaleFactor: 1.5,
        );

        expect(updatedAccessibility.highContrastMode, isTrue);
        expect(updatedAccessibility.textScaleFactor, equals(1.5));
        expect(updatedAccessibility.enableVoiceFeedback, isTrue);
      });

      test('VoiceCommandSettings should support copyWith', () {
        const originalVoice = VoiceCommandSettings(
          enableContinuousListening: false,
          minimumConfidence: 0.7,
          listeningTimeout: 5000,
          enableWakeWord: false,
          wakeWord: 'via',
          enableVoiceConfirmation: true,
        );

        final updatedVoice = originalVoice.copyWith(
          enableContinuousListening: true,
          minimumConfidence: 0.8,
        );

        expect(updatedVoice.enableContinuousListening, isTrue);
        expect(updatedVoice.minimumConfidence, equals(0.8));
        expect(updatedVoice.wakeWord, equals('via'));
      });
    });
  });
}
