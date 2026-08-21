import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hossy_barbers/features/admin/domain/business_settings.dart';

class BusinessSettingsRepository {
  BusinessSettingsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<BusinessSettings?> watchMain() {
    return _firestore
        .collection('businessSettings')
        .doc('main')
        .snapshots()
        .map(
          (snapshot) => snapshot.exists
              ? BusinessSettings.fromMap(snapshot.data()!)
              : null,
        );
  }
}
