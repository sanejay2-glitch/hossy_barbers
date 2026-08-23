import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hossy_barbers/features/services/domain/service.dart';

class ServicesRepository {
  ServicesRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<Service>> watchAll() => _watch();

  Stream<List<Service>> watchPublished() => _watch(activeOnly: true);

  Stream<List<Service>> _watch({bool activeOnly = false}) {
    Query<Map<String, dynamic>> query = _firestore.collection('services');
    if (activeOnly) query = query.where('isActive', isEqualTo: true);
    return query.snapshots().map((snapshot) {
      final services =
          snapshot.docs
              .map((document) => Service.fromMap(document.id, document.data()))
              .toList()
            ..sort(
              (first, second) => first.sortOrder.compareTo(second.sortOrder),
            );
      return services;
    });
  }

  Future<void> save(Service service) {
    final isNew = service.id.isEmpty;
    final document = isNew
        ? _firestore.collection('services').doc()
        : _firestore.collection('services').doc(service.id);
    final data = <String, Object?>{
      ...service.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (isNew) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    return document.set(data, SetOptions(merge: true));
  }

  Future<void> delete(String serviceId) =>
      _firestore.collection('services').doc(serviceId).delete();
}
