class Disease {
  final String id;
  final String name;
  final String signs;
  final String treatments;
  final String prevention;
  final DateTime createdAt;

  Disease({
    required this.id,
    required this.name,
    required this.signs,
    required this.treatments,
    required this.prevention,
    required this.createdAt,
  });

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      id: json['_id'],
      name: json['name'],
      signs: json['signs'],
      treatments: json['treatments'],
      prevention: json['prevention'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
