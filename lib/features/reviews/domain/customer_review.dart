import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerReview {
  const CustomerReview({
    required this.id,
    required this.rating,
    required this.review,
    required this.displayName,
    required this.published,
    this.createdAt,
  });

  final String id;
  final int rating;
  final String review;
  final String displayName;
  final bool published;
  final DateTime? createdAt;

  factory CustomerReview.fromMap(String id, Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    return CustomerReview(
      id: id,
      rating: data['rating'] as int? ?? 0,
      review: data['review'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      published: data['published'] as bool? ?? false,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
    );
  }
}
