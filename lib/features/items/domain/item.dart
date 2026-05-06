import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<String> photos;
  final double pricePerDay;
  final String category;
  final String ownerId;
  final String status;
  final DateTime createdAt;
  final String? locationName;
  final double? lat;
  final double? lng;

  const Item({
    required this.id,
    required this.title,
    required this.description,
    required this.photos,
    required this.pricePerDay,
    required this.category,
    required this.ownerId,
    required this.status,
    required this.createdAt,
    this.locationName,
    this.lat,
    this.lng,
  });

  factory Item.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Item(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
      pricePerDay: (data['pricePerDay'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      ownerId: data['ownerId'] ?? '',
      status: data['status'] ?? 'available',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      locationName: data['locationName'] as String?,
      lat: (data['lat'] as num?)?.toDouble(),
      lng: (data['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'photos': photos,
      'pricePerDay': pricePerDay,
      'category': category,
      'ownerId': ownerId,
      'status': status,
      'createdAt': createdAt,
      if (locationName != null) 'locationName': locationName,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    };
  }

  Item copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? photos,
    double? pricePerDay,
    String? category,
    String? ownerId,
    String? status,
    DateTime? createdAt,
    String? locationName,
    double? lat,
    double? lng,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      photos: photos ?? this.photos,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      category: category ?? this.category,
      ownerId: ownerId ?? this.ownerId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      locationName: locationName ?? this.locationName,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        photos,
        pricePerDay,
        category,
        ownerId,
        status,
        createdAt,
        locationName,
        lat,
        lng,
      ];
}
