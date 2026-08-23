import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryItem {
  const GalleryItem({
    required this.id,
    required this.imageUrl,
    required this.caption,
    required this.isPublished,
    required this.sortOrder,
    this.createdAt,
  });

  final String id;
  final String imageUrl;
  final String caption;
  final bool isPublished;
  final int sortOrder;
  final DateTime? createdAt;

  factory GalleryItem.fromMap(String id, Map<String, dynamic> data) {
    final timestamp = data['createdAt'];
    return GalleryItem(
      id: id,
      imageUrl: data['imageUrl'] as String? ?? '',
      caption: data['caption'] as String? ?? '',
      isPublished: data['isPublished'] as bool? ?? false,
      sortOrder: data['sortOrder'] as int? ?? 0,
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }

  Map<String, Object> toMap() => {
    'imageUrl': imageUrl,
    'caption': caption,
    'isPublished': isPublished,
    'sortOrder': sortOrder,
  };
}
