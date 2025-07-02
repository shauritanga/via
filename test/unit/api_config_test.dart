import 'package:flutter_test/flutter_test.dart';
import 'package:via/core/config/api_config.dart';

void main() {
  group('ApiConfig API Key Management', () {
    setUp(() async {
      // Clear any existing keys before each test
      await ApiConfig.clearAllApiKeys();
    });

    test('should initialize without errors', () async {
      expect(() async => await ApiConfig.initialize(), returnsNormally);
    });

    test('should set and get OpenAI API key', () async {
      const testKey = 'sk-test123456789012345678901234567890';
      await ApiConfig.setOpenAiApiKey(testKey);

      // In test environment, we need to check the private variable directly
      // since secure storage doesn't work in tests
      expect(ApiConfig.isOpenAiConfigured, isTrue);
    });

    test('should set and get Google Translate API key', () async {
      const testKey = 'test-google-translate-key-12345678901234567890';
      await ApiConfig.setGoogleTranslateApiKey(testKey);

      expect(ApiConfig.isGoogleTranslateConfigured, isTrue);
    });

    test('should set and get Firebase Web API key', () async {
      const testKey = 'test-firebase-web-key-12345678901234567890';
      await ApiConfig.setFirebaseWebApiKey(testKey);

      // Check if Firebase key is configured
      final status = ApiConfig.getConfigStatus();
      expect(status['hasFirebaseKey'], isTrue);
    });

    test('should clear all API keys', () async {
      // Set some keys first
      await ApiConfig.setOpenAiApiKey('test-key-1');
      await ApiConfig.setGoogleTranslateApiKey('test-key-2');
      await ApiConfig.setFirebaseWebApiKey('test-key-3');

      // Clear all keys
      await ApiConfig.clearAllApiKeys();

      // Verify keys are cleared
      expect(ApiConfig.isOpenAiConfigured, isFalse);
      expect(ApiConfig.isGoogleTranslateConfigured, isFalse);
    });
  });

  group('ApiConfig API Key Validation', () {
    test('should validate OpenAI API key format correctly', () {
      expect(
        ApiConfig.isValidOpenAiKey('sk-test123456789012345678901234567890'),
        isTrue,
      );
      expect(ApiConfig.isValidOpenAiKey('invalid-key'), isFalse);
      expect(ApiConfig.isValidOpenAiKey('sk-'), isFalse);
      expect(ApiConfig.isValidOpenAiKey(''), isFalse);
    });

    test('should validate Google API key format correctly', () {
      expect(
        ApiConfig.isValidGoogleKey(
          'AIzaSyC12345678901234567890123456789012345',
        ),
        isTrue,
      );
      expect(ApiConfig.isValidGoogleKey('invalid'), isFalse);
      expect(ApiConfig.isValidGoogleKey('key with spaces'), isFalse);
      expect(ApiConfig.isValidGoogleKey(''), isFalse);
    });
  });

  group('ApiConfig Configuration Status', () {
    test('should return correct configuration status when no keys are set', () {
      final status = ApiConfig.getConfigStatus();

      expect(status['openAiConfigured'], isFalse);
      expect(status['googleTranslateConfigured'], isFalse);
      expect(status['useLocalServices'], isTrue);
      expect(status['environment'], equals('development'));
    });

    test(
      'should return correct configuration status when keys are set',
      () async {
        // Set valid keys
        await ApiConfig.setOpenAiApiKey(
          'sk-test123456789012345678901234567890',
        );
        await ApiConfig.setGoogleTranslateApiKey(
          'AIzaSyC12345678901234567890123456789012345',
        );

        final status = ApiConfig.getConfigStatus();

        expect(status['openAiConfigured'], isTrue);
        expect(status['googleTranslateConfigured'], isTrue);
        expect(status['useLocalServices'], isTrue); // Still true in debug mode
      },
    );
  });

  group('ApiConfig Headers Generation', () {
    test('should generate correct OpenAI headers', () async {
      await ApiConfig.setOpenAiApiKey('sk-test123456789012345678901234567890');

      final headers = ApiConfig.openAiHeaders;
      expect(headers['Content-Type'], equals('application/json'));
      expect(
        headers['Authorization'],
        equals('Bearer sk-test123456789012345678901234567890'),
      );
    });

    test('should generate correct Google Translate headers', () async {
      await ApiConfig.setGoogleTranslateApiKey(
        'AIzaSyC12345678901234567890123456789012345',
      );

      final headers = ApiConfig.googleTranslateHeaders;
      expect(headers['Content-Type'], equals('application/json'));
      expect(
        headers['Authorization'],
        equals('Bearer AIzaSyC12345678901234567890123456789012345'),
      );
    });

    test('should handle null API keys in headers', () async {
      await ApiConfig.clearAllApiKeys();
      final headers = ApiConfig.openAiHeaders;
      expect(headers['Content-Type'], equals('application/json'));
      expect(headers.containsKey('Authorization'), isFalse);
    });
  });

  group('ApiConfig Configuration Checks', () {
    test('should correctly identify when OpenAI is configured', () async {
      await ApiConfig.clearAllApiKeys();
      expect(ApiConfig.isOpenAiConfigured, isFalse);
      await ApiConfig.setOpenAiApiKey('sk-test123456789012345678901234567890');
      expect(ApiConfig.isOpenAiConfigured, isTrue);
    });

    test(
      'should correctly identify when Google Translate is configured',
      () async {
        await ApiConfig.clearAllApiKeys();
        expect(ApiConfig.isGoogleTranslateConfigured, isFalse);
        await ApiConfig.setGoogleTranslateApiKey(
          'AIzaSyC12345678901234567890123456789012345',
        );
        expect(ApiConfig.isGoogleTranslateConfigured, isTrue);
      },
    );

    test('should use local services when no API keys are configured', () {
      expect(ApiConfig.useLocalServices, isTrue);
    });

    test(
      'should use local services in debug mode even with API keys',
      () async {
        await ApiConfig.setOpenAiApiKey(
          'sk-test123456789012345678901234567890',
        );
        expect(ApiConfig.useLocalServices, isTrue); // Still true in debug mode
      },
    );
  });

  group('ApiConfig Constants', () {
    test('should have correct API endpoints', () {
      expect(ApiConfig.openAiBaseUrl, equals('https://api.openai.com/v1'));
      expect(
        ApiConfig.googleTranslateBaseUrl,
        equals('https://translation.googleapis.com/language/translate/v2'),
      );
    });

    test('should have correct timeout and retry settings', () {
      expect(ApiConfig.apiTimeout, equals(const Duration(seconds: 30)));
      expect(ApiConfig.maxRetries, equals(3));
      expect(ApiConfig.requestsPerMinute, equals(60));
    });

    test('should have correct rate limiting settings', () {
      expect(ApiConfig.requestsPerMinute, equals(60));
      expect(ApiConfig.tokensPerMinute, equals(90000));
    });
  });
}
