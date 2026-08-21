class Service {
  const Service({
    required this.id,
    required this.name,
    required this.description,
    this.price,
    this.duration,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String description;
  final String? price;
  final String? duration;
  final bool isActive;
}
