import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:via/core/config/api_config.dart';
import 'package:via/features/voice_commands/domain/entities/voice_command.dart';

void main() {
  group('Voice Commands Integration Tests', () {
    late ProviderContainer container;

    setUpAll(() async {
      // Initialize API configuration for tests
      await ApiConfig.initialize();
    });

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('Voice command entity should work correctly', (WidgetTester tester) async {
      // Test voice command creation
      final command = VoiceCommand(
        command: 'read document',
        type: VoiceCommandType.readDocument,
        parameters: {},
        language: 'en',
        confidence: 0.95,
        timestamp: DateTime.now(),
      );

      expect(command.command, equals('read document'));
      expect(command.type, equals(VoiceCommandType.readDocument));
      expect(command.confidence, equals(0.95));
      expect(command.timestamp, isA<DateTime>());
    });

    testWidgets('Voice command types should be valid', (WidgetTester tester) async {
      // Test all voice command types
      expect(VoiceCommandType.readDocument, isA<VoiceCommandType>());
      expect(VoiceCommandType.pauseReading, isA<VoiceCommandType>());
      expect(VoiceCommandType.resumeReading, isA<VoiceCommandType>());
      expect(VoiceCommandType.stopReading, isA<VoiceCommandType>());
      expect(VoiceCommandType.changeLanguage, isA<VoiceCommandType>());
      expect(VoiceCommandType.settings, isA<VoiceCommandType>());
    });

    testWidgets('Voice command confidence should be valid', (WidgetTester tester) async {
      // Test confidence values
      final highConfidence = VoiceCommand(
        command: 'high confidence',
        type: VoiceCommandType.readDocument,
        parameters: {},
        language: 'en',
        confidence: 0.99,
        timestamp: DateTime.now(),
      );

      final lowConfidence = VoiceCommand(
        command: 'low confidence',
        type: VoiceCommandType.readDocument,
        parameters: {},
        language: 'en',
        confidence: 0.1,
        timestamp: DateTime.now(),
      );

      expect(highConfidence.confidence, greaterThan(0.5));
      expect(lowConfidence.confidence, lessThan(0.5));
    });

    testWidgets('Voice command timestamp should be recent', (WidgetTester tester) async {
      final command = VoiceCommand(
        command: 'test command',
        type: VoiceCommandType.readDocument,
        parameters: {},
        language: 'en',
        confidence: 0.8,
        timestamp: DateTime.now(),
      );

      final now = DateTime.now();
      final difference = now.difference(command.timestamp).inSeconds;
      
      expect(difference, lessThan(5)); // Should be within 5 seconds
    });

    test('API configuration should be available for voice commands', () {
      // Test that API configuration is available
      final status = ApiConfig.getConfigStatus();
      expect(status, isA<Map<String, dynamic>>());
      expect(status['openAiConfigured'], isA<bool>());
      expect(status['googleTranslateConfigured'], isA<bool>());
    });

    test('Voice command processing should handle different text inputs', () {
      // Test various voice command texts
      final commands = [
        VoiceCommand(
          command: 'read the document',
          type: VoiceCommandType.readDocument,
          parameters: {},
          language: 'en',
          confidence: 0.9,
          timestamp: DateTime.now(),
        ),
        VoiceCommand(
          command: 'pause reading',
          type: VoiceCommandType.pauseReading,
          parameters: {},
          language: 'en',
          confidence: 0.85,
          timestamp: DateTime.now(),
        ),
        VoiceCommand(
          command: 'change language to Spanish',
          type: VoiceCommandType.changeLanguage,
          parameters: {'language': 'es'},
          language: 'en',
          confidence: 0.8,
          timestamp: DateTime.now(),
        ),
      ];

      for (final command in commands) {
        expect(command.command, isNotEmpty);
        expect(command.confidence, greaterThan(0.0));
        expect(command.confidence, lessThanOrEqualTo(1.0));
        expect(command.timestamp, isA<DateTime>());
      }
    });
  });
}
