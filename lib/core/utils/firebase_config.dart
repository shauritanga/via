import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    
    // Configure Firestore settings
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  static Future<void> signInAnonymously() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      print('Signed in anonymously: ${userCredential.user?.uid}');
    } catch (e) {
      print('Failed to sign in anonymously: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  static Stream<User?> authStateChanges() {
    return FirebaseAuth.instance.authStateChanges();
  }

  // Firestore Security Rules (to be added in Firebase Console)
  static String get firestoreRules => '''
    rules_version = '2';
    service cloud.firestore {
      match /databases/{database}/documents {
        // Users can only access their own documents
        match /documents/{documentId} {
          allow read, write: if request.auth != null && 
            request.auth.uid == resource.data.userId;
          allow create: if request.auth != null && 
            request.auth.uid == request.resource.data.userId;
            
          // Document content subcollection
          match /content/{contentId} {
            allow read, write: if request.auth != null && 
              request.auth.uid == get(/databases/\$(database)/documents/documents/\$(documentId)).data.userId;
          }
        }
        
        // User preferences
        match /user_preferences/{userId} {
          allow read, write: if request.auth != null && 
            request.auth.uid == userId;
        }
      }
    }
  ''';

  // Storage Security Rules (to be added in Firebase Console)
  static String get storageRules => '''
    rules_version = '2';
    service firebase.storage {
      match /b/{bucket}/o {
        // Users can only access their own documents
        match /documents/{userId}/{allPaths=**} {
          allow read, write: if request.auth != null && 
            request.auth.uid == userId;
        }
      }
    }
  ''';
}
