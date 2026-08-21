import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAuthorizationRepository {
  AdminAuthorizationRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<bool> isAuthorized(String userId) async {
    final snapshot = await _firestore
        .collection('adminUsers')
        .doc(userId)
        .get();
    return snapshot.data()?['active'] == true;
  }
}
