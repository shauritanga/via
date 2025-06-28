import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Features
import '../../features/documents/data/datasources/document_local_datasource.dart';
import '../../features/documents/data/datasources/document_remote_datasource.dart';
import '../../features/documents/data/repositories/document_repository_impl.dart';
import '../../features/documents/domain/repositories/document_repository.dart';
import '../../features/documents/domain/usecases/get_documents.dart';
import '../../features/documents/domain/usecases/upload_document.dart';
import '../../features/documents/domain/usecases/delete_document.dart';
import '../../features/documents/domain/usecases/get_document_content.dart';
import '../../features/documents/domain/usecases/upload_and_process_document.dart';

import '../../features/voice_commands/data/datasources/speech_recognition_datasource.dart';
import '../../features/voice_commands/data/datasources/text_to_speech_datasource.dart';
import '../../features/voice_commands/data/repositories/voice_repository_impl.dart';
import '../../features/voice_commands/domain/repositories/voice_repository.dart';
import '../../features/voice_commands/domain/usecases/start_listening.dart';
import '../../features/voice_commands/domain/usecases/stop_listening.dart';
import '../../features/voice_commands/domain/usecases/speak_text.dart';
import '../../features/voice_commands/domain/usecases/stop_speaking.dart';
import '../../features/voice_commands/domain/usecases/read_document_content.dart';
import '../../features/voice_commands/domain/usecases/process_voice_command.dart';

import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_language_preference.dart';
import '../../features/settings/domain/usecases/set_language_preference.dart';
import '../../features/settings/domain/usecases/get_tts_settings.dart';
import '../../features/settings/domain/usecases/set_tts_settings.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);

  // Features - Documents
  _initDocuments();

  // Features - Voice Commands
  _initVoiceCommands();

  // Features - Settings
  _initSettings();
}

void _initDocuments() {
  // Use cases
  sl.registerLazySingleton(() => GetDocuments(sl()));
  sl.registerLazySingleton(() => UploadDocument(sl()));
  sl.registerLazySingleton(() => DeleteDocument(sl()));
  sl.registerLazySingleton(() => GetDocumentContent(sl()));
  sl.registerLazySingleton(() => UploadAndProcessDocument(sl()));
  sl.registerLazySingleton(() => UploadWithProgress(sl()));

  // Repository
  sl.registerLazySingleton<DocumentRepository>(
    () => DocumentRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<DocumentRemoteDataSource>(
    () => DocumentRemoteDataSourceImpl(firestore: sl(), auth: sl()),
  );

  sl.registerLazySingleton<DocumentLocalDataSource>(
    () => DocumentLocalDataSourceImpl(sharedPreferences: sl()),
  );
}

void _initVoiceCommands() {
  // Use cases
  sl.registerLazySingleton(() => StartListening(sl()));
  sl.registerLazySingleton(() => StopListening(sl()));
  sl.registerLazySingleton(() => SpeakText(sl()));
  sl.registerLazySingleton(() => StopSpeaking(sl()));
  sl.registerLazySingleton(() => ReadDocumentContent(sl()));
  sl.registerLazySingleton(() => ProcessVoiceCommand(sl(), sl(), sl()));

  // Repository
  sl.registerLazySingleton<VoiceRepository>(
    () => VoiceRepositoryImpl(
      speechRecognitionDataSource: sl(),
      textToSpeechDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<SpeechRecognitionDataSource>(
    () => SpeechRecognitionDataSourceImpl(),
  );

  sl.registerLazySingleton<TextToSpeechDataSource>(
    () => TextToSpeechDataSourceImpl(),
  );
}

void _initSettings() {
  // Use cases
  sl.registerLazySingleton(() => GetLanguagePreference(sl()));
  sl.registerLazySingleton(() => SetLanguagePreference(sl()));
  sl.registerLazySingleton(() => GetTtsSettings(sl()));
  sl.registerLazySingleton(() => SetTtsSettings(sl()));

  // Repository
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(sharedPreferences: sl()),
  );
}
