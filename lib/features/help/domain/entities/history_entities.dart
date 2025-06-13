import 'dart:convert';

class HistoryModel {
  int? id;
  final String imageLink;
  final String? description;
  final String name;
  final String scientificName;
  final double probability;
  final String createdAt;
  final List<String>? treatments;
  bool? isNew;
  bool? uploading;

  HistoryModel({
    this.id,
    required this.imageLink,
    this.description,
    required this.name,
    required this.scientificName,
    required this.probability,
    required this.createdAt,
    this.treatments,
    this.isNew,
    this.uploading,
  });

  factory HistoryModel.fromMap(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'],
      imageLink: json['imageLink'],
      description: json['description'],
      name: json['name'],
      scientificName: json['scientificName'],
      probability: json['probability'],
      createdAt: json['createdAt'],
      isNew: json['isNew'] ?? false,
      uploading: json['uploading'] ?? false,
      treatments: (json['treatments'] != null && json['treatments'] is String)
          ? List<String>.from(jsonDecode(json['treatments']))
          : null,
    );
  }
  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'],
      imageLink: json['image_link'],
      description: json['description'],
      name: json['name'],
      scientificName: json['scientific_name'],
      probability: (json['probability'] as num).toDouble(),
      createdAt: json['createdAt'] ?? DateTime.now().toString(),
      isNew: json['isNew'] ?? false,
      uploading: json['uploading'] ?? false,
      treatments: json['treatments'] != null
          ? List<String>.from(json['treatments'] as List)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'imageLink': imageLink,
        'description': description,
        'name': name,
        'scientificName': scientificName,
        'probability': probability,
        'createdAt': createdAt,
        'treatments': treatments != null ? jsonEncode(treatments) : null,
      };
}
