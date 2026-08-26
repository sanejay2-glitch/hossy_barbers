import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hossy_barbers/features/reviews/domain/customer_review.dart';
import 'package:hossy_barbers/features/reviews/domain/review_summary.dart';

class ReviewsRepository {
  ReviewsRepository(this._firestore);

  static const _summaryCollection = 'reviewSummaries';
  static const _summaryDocument = 'main';

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _reviews =>
      _firestore.collection('reviews');
  DocumentReference<Map<String, dynamic>> get _summary =>
      _firestore.collection(_summaryCollection).doc(_summaryDocument);

  Stream<List<CustomerReview>> watchPublished() => _watch(publishedOnly: true);

  Stream<ReviewSummary> watchPublicSummary() =>
      watchPublished().map(ReviewSummary.fromReviews);

  Stream<List<CustomerReview>> watchAll() => _watch();

  Future<PublishedReviewsPage> fetchPublishedPage({
    PublishedReviewsPage? after,
    int pageSize = 12,
  }) async {
    final fallbackReviews = after?._fallbackReviews;
    if (fallbackReviews != null) {
      return _fallbackPage(
        fallbackReviews,
        start: after!._fallbackOffset,
        pageSize: pageSize,
      );
    }
    try {
      Query<Map<String, dynamic>> query = _publishedByDate().limit(
        pageSize + 1,
      );
      if (after?._lastDocument != null) {
        query = query.startAfterDocument(after!._lastDocument!);
      }
      final snapshot = await query.get();
      final documents = snapshot.docs;
      final hasMore = documents.length > pageSize;
      final pageDocuments = hasMore
          ? documents.take(pageSize).toList()
          : documents;
      return PublishedReviewsPage(
        reviews: pageDocuments
            .map(
              (document) =>
                  CustomerReview.fromMap(document.id, document.data()),
            )
            .toList(),
        hasMore: hasMore,
        lastDocument: pageDocuments.isEmpty
            ? after?._lastDocument
            : pageDocuments.last,
      );
    } on FirebaseException {
      final snapshot = await _reviews
          .where('published', isEqualTo: true)
          .get();
      return _fallbackPage(_reviewsFromSnapshot(snapshot), pageSize: pageSize);
    }
  }

  PublishedReviewsPage _fallbackPage(
    List<CustomerReview> reviews, {
    int start = 0,
    required int pageSize,
  }) {
    final end = (start + pageSize).clamp(0, reviews.length).toInt();
    final pageReviews = reviews.sublist(start, end);
    return PublishedReviewsPage(
      reviews: pageReviews,
      hasMore: end < reviews.length,
      fallbackReviews: reviews,
      fallbackOffset: end,
    );
  }

  Future<void> submit({
    required int rating,
    required String review,
    required String displayName,
  }) async {
    await _reviews
        .add({
          'rating': rating,
          'review': review,
          'displayName': displayName,
          'published': false,
          'createdAt': FieldValue.serverTimestamp(),
        })
        .timeout(const Duration(seconds: 20));
  }

  Future<void> setPublished(CustomerReview review, bool published) async {
    if (review.published == published) return;
    await ensureSummary();
    final reviewReference = _reviews.doc(review.id);
    await _firestore.runTransaction((transaction) async {
      final reviewSnapshot = await transaction.get(reviewReference);
      if (!reviewSnapshot.exists) {
        throw StateError('This review is no longer available.');
      }
      final currentReview = CustomerReview.fromMap(
        reviewSnapshot.id,
        reviewSnapshot.data()!,
      );
      if (currentReview.published == published) return;

      final summarySnapshot = await transaction.get(_summary);
      final currentSummary = summarySnapshot.exists
          ? ReviewSummary.fromMap(summarySnapshot.data() ?? const {})
          : ReviewSummary.empty;
      final nextSummary = currentSummary.withPublishedReview(
        currentReview.rating,
        added: published,
      );
      transaction.update(reviewReference, {'published': published});
      transaction.set(_summary, _summaryData(nextSummary));
    });
  }

  Future<void> delete(String reviewId) async {
    await ensureSummary();
    final reviewReference = _reviews.doc(reviewId);
    await _firestore.runTransaction((transaction) async {
      final reviewSnapshot = await transaction.get(reviewReference);
      if (!reviewSnapshot.exists) return;
      final review = CustomerReview.fromMap(
        reviewSnapshot.id,
        reviewSnapshot.data()!,
      );
      if (review.published) {
        final summarySnapshot = await transaction.get(_summary);
        final summary = summarySnapshot.exists
            ? ReviewSummary.fromMap(summarySnapshot.data() ?? const {})
            : ReviewSummary.empty;
        transaction.set(
          _summary,
          _summaryData(
            summary.withPublishedReview(review.rating, added: false),
          ),
        );
      }
      transaction.delete(reviewReference);
    });
  }

  Future<void> ensureSummary() async {
    final snapshot = await _summary.get();
    if (!snapshot.exists) await rebuildSummary();
  }

  Future<void> rebuildSummary() async {
    final snapshot = await _publishedByDate().get();
    final reviews = _reviewsFromSnapshot(snapshot);
    await _summary.set(_summaryData(ReviewSummary.fromReviews(reviews)));
  }

  Query<Map<String, dynamic>> _publishedByDate() => _reviews
      .where('published', isEqualTo: true)
      .orderBy('createdAt', descending: true);

  Stream<List<CustomerReview>> _watch({bool publishedOnly = false}) {
    Query<Map<String, dynamic>> query = _reviews;
    if (publishedOnly) query = query.where('published', isEqualTo: true);
    return query.snapshots().map(_reviewsFromSnapshot);
  }

  List<CustomerReview> _reviewsFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
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
  }

  Map<String, Object> _summaryData(ReviewSummary summary) => {
    ...summary.toMap(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

class PublishedReviewsPage {
  const PublishedReviewsPage({
    required this.reviews,
    required this.hasMore,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
    List<CustomerReview>? fallbackReviews,
    int fallbackOffset = 0,
  }) : _lastDocument = lastDocument,
       _fallbackReviews = fallbackReviews,
       _fallbackOffset = fallbackOffset;

  final List<CustomerReview> reviews;
  final bool hasMore;
  final DocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  final List<CustomerReview>? _fallbackReviews;
  final int _fallbackOffset;
}
