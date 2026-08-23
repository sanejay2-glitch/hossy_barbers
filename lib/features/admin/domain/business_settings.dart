class BusinessSettings {
  const BusinessSettings({
    required this.businessName,
    required this.shortTagline,
    required this.description,
    required this.phoneNumber,
    required this.whatsAppNumber,
    required this.address,
    required this.openingHours,
    required this.socialLinks,
    required this.logoUrl,
    required this.heroImageUrl,
    required this.heroEyebrow,
    required this.heroHeadline,
    required this.heroDescription,
    required this.heroCtaText,
    required this.aboutHeading,
    required this.seoTitle,
    required this.seoDescription,
  });

  final String businessName;
  final String shortTagline;
  final String description;
  final String phoneNumber;
  final String whatsAppNumber;
  final String address;
  final Map<String, String> openingHours;
  final Map<String, String> socialLinks;
  final String logoUrl;
  final String heroImageUrl;
  final String heroEyebrow;
  final String heroHeadline;
  final String heroDescription;
  final String heroCtaText;
  final String aboutHeading;
  final String seoTitle;
  final String seoDescription;

  factory BusinessSettings.fromMap(Map<String, dynamic> data) {
    return BusinessSettings(
      businessName: data['businessName'] as String? ?? '',
      shortTagline: data['shortTagline'] as String? ?? '',
      description: data['description'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      whatsAppNumber: data['whatsAppNumber'] as String? ?? '',
      address: data['address'] as String? ?? '',
      openingHours: _stringMap(data['openingHours']),
      socialLinks: _stringMap(data['socialLinks']),
      logoUrl: data['logoUrl'] as String? ?? '',
      heroImageUrl: data['heroImageUrl'] as String? ?? '',
      heroEyebrow: data['heroEyebrow'] as String? ?? '',
      heroHeadline: data['heroHeadline'] as String? ?? '',
      heroDescription: data['heroDescription'] as String? ?? '',
      heroCtaText: data['heroCtaText'] as String? ?? '',
      aboutHeading: data['aboutHeading'] as String? ?? '',
      seoTitle: data['seoTitle'] as String? ?? '',
      seoDescription: data['seoDescription'] as String? ?? '',
    );
  }

  Map<String, Object> toMap() => {
    'businessName': businessName,
    'shortTagline': shortTagline,
    'description': description,
    'phoneNumber': phoneNumber,
    'whatsAppNumber': whatsAppNumber,
    'address': address,
    'openingHours': openingHours,
    'socialLinks': socialLinks,
    'logoUrl': logoUrl,
    'heroImageUrl': heroImageUrl,
    'heroEyebrow': heroEyebrow,
    'heroHeadline': heroHeadline,
    'heroDescription': heroDescription,
    'heroCtaText': heroCtaText,
    'aboutHeading': aboutHeading,
    'seoTitle': seoTitle,
    'seoDescription': seoDescription,
  };

  static Map<String, String> _stringMap(Object? value) {
    if (value is! Map) return const {};
    return Map<String, String>.fromEntries(
      value.entries
          .where((entry) => entry.key is String && entry.value is String)
          .map((entry) => MapEntry(entry.key as String, entry.value as String)),
    );
  }
}
