import 'package:cloud_firestore/cloud_firestore.dart';

// Facade pattern: profile writes use one small entry point for Firestore paths
// and merge semantics. GetIt registers one lazy instance for reuse.
class FirestoreService {
  const FirestoreService(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> userDoc(String userId) =>
      _firestore.collection('Users').doc(userId);

  Future<void> mergeUser(String userId, Map<String, dynamic> data) =>
      userDoc(userId).set(data, SetOptions(merge: true));
}
