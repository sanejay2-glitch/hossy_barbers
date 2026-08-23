import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hossy_barbers/features/reviews/domain/customer_review.dart';

class ReviewsRepository {
  ReviewsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<CustomerReview>> watchPublished() => _watch(publishedOnly: true);

  Stream<List<CustomerReview>> watchAll() => _watch();

  Stream<List<CustomerReview>> _watch({bool publishedOnly = false}) {
    Query<Map<String, dynamic>> query = _firestore.collection('reviews');
    if (publishedOnly) query = query.where('published', isEqualTo: true);
    return query.snapshots().map((snapshot) {
      final reviews =
          snapshot.docs
              .map(
                (document) =>
                    CustomerReview.fromMap(document.id, document.data()),
              )
              .toList()
            ..sort(
              (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
                a.createdAt ?? DateTime(0),
              ),
            );
      return reviews;
    });
  }

  Future<void> submit({
    required int rating,
    required String review,
    required String displayName,
  }) async {
    await _firestore
        .collection('reviews')
        .add({
          'rating': rating,
          'review': review,
          'displayName': displayName,
          'published': false,
          'createdAt': FieldValue.serverTimestamp(),
        })
        .timeout(const Duration(seconds: 20));
  }

  Future<void> setPublished(CustomerReview review, bool published) => _firestore
      .collection('reviews')
      .doc(review.id)
      .update({'published': published});

  Future<void> delete(String reviewId) =>
      _firestore.collection('reviews').doc(reviewId).delete();
}
