class Program {
  final String id;
  final String universityId;
  final String name;
  final String degreeLevel;
  final String duration;
  final double tuitionFee;
  final String feePeriod;
  final double? registrationFee;
  final DateTime? deadline;
  final String? eligibility;
  final String sourceLink;
  final DateTime lastVerified;
  final String status;

  Program({
    required this.id,
    required this.universityId,
    required this.name,
    required this.degreeLevel,
    required this.duration,
    required this.tuitionFee,
    required this.feePeriod,
    this.registrationFee,
    this.deadline,
    this.eligibility,
    required this.sourceLink,
    required this.lastVerified,
    required this.status,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id'] as String,
      universityId: json['university_id'] as String,
      name: json['name'] as String,
      degreeLevel: json['degree_level'] as String,
      duration: json['duration'] as String,
      tuitionFee: (json['tuition_fee'] as num).toDouble(),
      feePeriod: json['fee_period'] as String,
      registrationFee: json['registration_fee'] != null
          ? (json['registration_fee'] as num).toDouble()
          : null,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      eligibility: json['eligibility'] as String?,
      sourceLink: json['source_link'] as String,
      lastVerified: DateTime.parse(json['last_verified'] as String),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'university_id': universityId,
      'name': name,
      'degree_level': degreeLevel,
      'duration': duration,
      'tuition_fee': tuitionFee,
      'fee_period': feePeriod,
      'registration_fee': registrationFee,
      'deadline': deadline?.toIso8601String(),
      'eligibility': eligibility,
      'source_link': sourceLink,
      'last_verified': lastVerified.toIso8601String(),
      'status': status,
    };
  }
}
