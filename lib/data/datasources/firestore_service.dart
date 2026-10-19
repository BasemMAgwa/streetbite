import 'package:cloud_firestore/cloud_firestore.dart';

// Single Firestore entry point for the app (SRS requirement).
class FirestoreService {
  const FirestoreService(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> userDoc(String userId) =>
      _firestore.collection('Users').doc(userId);

  Future<void> mergeUser(String userId, Map<String, dynamic> data) =>
      userDoc(userId).set(data, SetOptions(merge: true));
}
