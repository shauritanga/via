import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/supabase_storage_service.dart';
import '../models/document_model.dart';
import '../models/document_content_model.dart';

abstract class DocumentRemoteDataSource {
  Future<List<DocumentModel>> getDocuments();
  Future<DocumentModel> getDocumentById(String id);
  Future<DocumentContentModel> getDocumentContent(String documentId);
  Future<DocumentModel> uploadDocument({
    required String filePath,
    required String title,
    String? description,
    List<String>? tags,
  });
  Future<void> deleteDocument(String documentId);
  Future<void> updateDocument(DocumentModel document);
  Future<void> updateLastAccessedTime(String documentId);
}

class DocumentRemoteDataSourceImpl implements DocumentRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  DocumentRemoteDataSourceImpl({required this.firestore, required this.auth});

  @override
  Future<List<DocumentModel>> getDocuments() async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        throw const AuthenticationFailure('User not authenticated');
      }

      final querySnapshot = await firestore
          .collection('documents')
          .where('userId', isEqualTo: user.uid)
          .orderBy('lastAccessedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => DocumentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to get documents: $e');
    }
  }

  @override
  Future<DocumentModel> getDocumentById(String id) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        throw const AuthenticationFailure('User not authenticated');
      }

      final doc = await firestore.collection('documents').doc(id).get();

      if (!doc.exists) {
        throw const DocumentNotFoundFailure('Document not found');
      }

      final documentModel = DocumentModel.fromFirestore(doc);

      // Check if user owns the document
      if (documentModel.userId != user.uid) {
        throw const AuthenticationFailure('Access denied');
      }

      return documentModel;
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to get document: $e');
    }
  }

  @override
  Future<DocumentContentModel> getDocumentContent(String documentId) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        throw const AuthenticationFailure('User not authenticated');
      }

      // First verify the document belongs to the user
      await getDocumentById(documentId);

      final doc = await firestore
          .collection('documents')
          .doc(documentId)
          .collection('content')
          .doc('content')
          .get();

      if (!doc.exists) {
        throw const DocumentNotFoundFailure('Document content not found');
      }

      return DocumentContentModel.fromFirestore(doc);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to get document content: $e');
    }
  }

  @override
  Future<DocumentModel> uploadDocument({
    required String filePath,
    required String title,
    String? description,
    List<String>? tags,
  }) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        throw const AuthenticationFailure('User not authenticated');
      }

      final file = File(filePath);
      if (!file.existsSync()) {
        throw const DocumentNotFoundFailure('File not found');
      }

      // Upload file to Supabase Storage
      final fileName = file.path.split('/').last;
      final downloadUrl = await SupabaseStorageService.uploadDocument(
        file: file,
        userId: user.uid,
        customPath: fileName,
      );

      if (downloadUrl == null) {
        throw const ServerFailure('Failed to upload document to storage');
      }

      // Create document metadata
      final now = DateTime.now();
      final storagePath =
          SupabaseStorageService.getFilePathFromUrl(downloadUrl) ??
          'documents/${user.uid}/$fileName';
      final documentData = DocumentModel(
        id: '', // Will be set by Firestore
        title: title,
        fileName: fileName,
        filePath: storagePath,
        downloadUrl: downloadUrl,
        sizeInBytes: file.lengthSync(),
        uploadedAt: now,
        lastAccessedAt: now,
        userId: user.uid,
        tags: tags ?? [],
        description: description ?? '',
        totalPages: 0, // Will be updated after PDF parsing
        language: 'en', // Default language
      );

      // Save document metadata to Firestore
      final docRef = await firestore
          .collection('documents')
          .add(documentData.toFirestore());

      return documentData.copyWith(id: docRef.id);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to upload document: $e');
    }
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        throw const AuthenticationFailure('User not authenticated');
      }

      // Get document to verify ownership and get storage path
      final document = await getDocumentById(documentId);

      // Delete file from Supabase storage
      await SupabaseStorageService.deleteFile(
        filePath: document.filePath,
        bucket: 'documents',
      );

      // Delete document content subcollection
      final contentCollection = firestore
          .collection('documents')
          .doc(documentId)
          .collection('content');

      final contentDocs = await contentCollection.get();
      for (final doc in contentDocs.docs) {
        await doc.reference.delete();
      }

      // Delete document metadata
      await firestore.collection('documents').doc(documentId).delete();
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to delete document: $e');
    }
  }

  @override
  Future<void> updateDocument(DocumentModel document) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        throw const AuthenticationFailure('User not authenticated');
      }

      if (document.userId != user.uid) {
        throw const AuthenticationFailure('Access denied');
      }

      await firestore
          .collection('documents')
          .doc(document.id)
          .update(document.toFirestore());
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to update document: $e');
    }
  }

  @override
  Future<void> updateLastAccessedTime(String documentId) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        throw const AuthenticationFailure('User not authenticated');
      }

      // Verify ownership
      await getDocumentById(documentId);

      await firestore.collection('documents').doc(documentId).update({
        'lastAccessedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to update last accessed time: $e');
    }
  }
}
