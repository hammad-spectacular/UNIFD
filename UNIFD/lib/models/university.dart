class University {
  final String id;
  final String name;
  final String city;
  final String type;
  final String website;
  final String? logoUrl;
  final String sourceLink;
  final DateTime lastVerified;

  University({
    required this.id,
    required this.name,
    required this.city,
    required this.type,
    required this.website,
    this.logoUrl,
    required this.sourceLink,
    required this.lastVerified,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      type: json['type'] as String,
      website: json['website'] as String,
      logoUrl: json['logo_url'] as String?,
      sourceLink: json['source_link'] as String,
      lastVerified: DateTime.parse(json['last_verified'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'type': type,
      'website': website,
      'logo_url': logoUrl,
      'source_link': sourceLink,
      'last_verified': lastVerified.toIso8601String(),
    };
  }
}
