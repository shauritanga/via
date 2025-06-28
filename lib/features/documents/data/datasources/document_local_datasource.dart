import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/failures.dart';
import '../models/document_model.dart';
import '../models/document_content_model.dart';

abstract class DocumentLocalDataSource {
  Future<List<DocumentModel>> getCachedDocuments();
  Future<void> cacheDocuments(List<DocumentModel> documents);
  Future<DocumentContentModel?> getCachedDocumentContent(String documentId);
  Future<void> cacheDocumentContent(DocumentContentModel content);
  Future<void> clearCache();
  Future<void> removeCachedDocument(String documentId);
}

class DocumentLocalDataSourceImpl implements DocumentLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String documentsKey = 'CACHED_DOCUMENTS';
  static const String documentContentPrefix = 'CACHED_CONTENT_';

  DocumentLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<DocumentModel>> getCachedDocuments() async {
    try {
      final jsonString = sharedPreferences.getString(documentsKey);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map(
            (json) => DocumentModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
    } catch (e) {
      throw CacheFailure('Failed to get cached documents: $e');
    }
  }

  @override
  Future<void> cacheDocuments(List<DocumentModel> documents) async {
    try {
      final jsonList = documents.map((doc) => doc.toJson()).toList();

      final jsonString = json.encode(jsonList);
      await sharedPreferences.setString(documentsKey, jsonString);
    } catch (e) {
      throw CacheFailure('Failed to cache documents: $e');
    }
  }

  @override
  Future<DocumentContentModel?> getCachedDocumentContent(
    String documentId,
  ) async {
    try {
      final jsonString = sharedPreferences.getString(
        '$documentContentPrefix$documentId',
      );
      if (jsonString == null) return null;

      final Map<String, dynamic> json = jsonDecode(jsonString);
      return DocumentContentModel.fromJson(json);
    } catch (e) {
      throw CacheFailure('Failed to get cached document content: $e');
    }
  }

  @override
  Future<void> cacheDocumentContent(DocumentContentModel content) async {
    try {
      final json = content.toJson();

      final jsonString = jsonEncode(json);
      await sharedPreferences.setString(
        '$documentContentPrefix${content.documentId}',
        jsonString,
      );
    } catch (e) {
      throw CacheFailure('Failed to cache document content: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final keys = sharedPreferences.getKeys();
      final documentKeys = keys.where(
        (key) => key == documentsKey || key.startsWith(documentContentPrefix),
      );

      for (final key in documentKeys) {
        await sharedPreferences.remove(key);
      }
    } catch (e) {
      throw CacheFailure('Failed to clear cache: $e');
    }
  }

  @override
  Future<void> removeCachedDocument(String documentId) async {
    try {
      // Remove from documents list
      final documents = await getCachedDocuments();
      final updatedDocuments = documents
          .where((doc) => doc.id != documentId)
          .toList();
      await cacheDocuments(updatedDocuments);

      // Remove document content
      await sharedPreferences.remove('$documentContentPrefix$documentId');
    } catch (e) {
      throw CacheFailure('Failed to remove cached document: $e');
    }
  }
}
