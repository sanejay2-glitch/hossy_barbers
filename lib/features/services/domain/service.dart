class Service {
  const Service({
    required this.id,
    required this.name,
    required this.description,
    this.price,
    this.duration,
    this.isActive = true,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final String description;
  final String? price;
  final String? duration;
  final bool isActive;
  final int sortOrder;

  factory Service.fromMap(String id, Map<String, dynamic> data) => Service(
    id: id,
    name: data['name'] as String? ?? '',
    description: data['description'] as String? ?? '',
    price: data['price'] as String?,
    duration: data['duration'] as String?,
    isActive: data['isActive'] as bool? ?? false,
    sortOrder: data['sortOrder'] as int? ?? 0,
  );

  Map<String, Object?> toMap() => {
    'name': name,
    'description': description,
    'price': price,
    'duration': duration,
    'isActive': isActive,
    'sortOrder': sortOrder,
  };
}
