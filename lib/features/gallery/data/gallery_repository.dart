import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hossy_barbers/features/gallery/domain/gallery_item.dart';

class GalleryRepository {
  GalleryRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<GalleryItem>> watchAll() => _watch();

  Stream<List<GalleryItem>> watchPublished() => _watch(publishedOnly: true);

  Stream<List<GalleryItem>> _watch({bool publishedOnly = false}) {
    Query<Map<String, dynamic>> query = _firestore.collection('gallery');
    if (publishedOnly) query = query.where('isPublished', isEqualTo: true);
    return query.snapshots().map((snapshot) {
      final items =
          snapshot.docs
              .map(
                (document) => GalleryItem.fromMap(document.id, document.data()),
              )
              .toList()
            ..sort(
              (first, second) => first.sortOrder.compareTo(second.sortOrder),
            );
      return items;
    });
  }

  Future<void> save(GalleryItem item) {
    final isNew = item.id.isEmpty;
    final document = isNew
        ? _firestore.collection('gallery').doc()
        : _firestore.collection('gallery').doc(item.id);
    final data = <String, Object>{
      ...item.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (isNew) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    return document.set(data, SetOptions(merge: true));
  }

  Future<void> delete(String itemId) =>
      _firestore.collection('gallery').doc(itemId).delete();
}
