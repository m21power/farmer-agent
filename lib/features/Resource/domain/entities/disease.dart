class Disease {
  final String id;
  final String name;
  final String signs;
  final String treatments;
  final String prevention;
  final String description;
  final DateTime createdAt;

  Disease({
    required this.id,
    required this.name,
    required this.signs,
    required this.treatments,
    required this.prevention,
    required this.createdAt,
    required this.description,
  });

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      id: json['_id'],
      name: json['name'],
      signs: json['signs'],
      treatments: json['treatments'],
      prevention: json['prevention'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'signs': signs,
      'treatments': treatments,
      'prevention': prevention,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
