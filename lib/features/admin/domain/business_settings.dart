class BusinessSettings {
  const BusinessSettings({
    required this.businessName,
    required this.description,
    required this.phoneNumber,
    required this.whatsAppNumber,
    required this.address,
    required this.openingHours,
    required this.socialLinks,
    required this.logoUrl,
    required this.heroImageUrl,
  });

  final String businessName;
  final String description;
  final String phoneNumber;
  final String whatsAppNumber;
  final String address;
  final Map<String, String> openingHours;
  final Map<String, String> socialLinks;
  final String logoUrl;
  final String heroImageUrl;

  factory BusinessSettings.fromMap(Map<String, dynamic> data) {
    return BusinessSettings(
      businessName: data['businessName'] as String? ?? '',
      description: data['description'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      whatsAppNumber: data['whatsAppNumber'] as String? ?? '',
      address: data['address'] as String? ?? '',
      openingHours: _stringMap(data['openingHours']),
      socialLinks: _stringMap(data['socialLinks']),
      logoUrl: data['logoUrl'] as String? ?? '',
      heroImageUrl: data['heroImageUrl'] as String? ?? '',
    );
  }

  static Map<String, String> _stringMap(Object? value) {
    if (value is! Map) return const {};
    return Map<String, String>.fromEntries(
      value.entries
          .where((entry) => entry.key is String && entry.value is String)
          .map((entry) => MapEntry(entry.key as String, entry.value as String)),
    );
  }
}
