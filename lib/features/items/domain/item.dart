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
  final double approximateLat;
  final double approximateLng;
  final double exactLat;
  final double exactLng;
  final DateTime? createdAt;

  const Item({
    required this.id,
    required this.title,
    required this.description,
    this.photos = const [],
    required this.pricePerDay,
    required this.category,
    required this.ownerId,
    this.status = 'available',
    required this.approximateLat,
    required this.approximateLng,
    required this.exactLat,
    required this.exactLng,
    this.createdAt,
  });

  factory Item.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final approxLocation = data['approximateLocation'] as Map<String, dynamic>?;
    final exactLocation = data['exactLocation'] as Map<String, dynamic>?;
    return Item(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
      pricePerDay: (data['pricePerDay'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      ownerId: data['ownerId'] ?? '',
      status: data['status'] ?? 'available',
      approximateLat: (approxLocation?['lat'] ?? 0).toDouble(),
      approximateLng: (approxLocation?['lng'] ?? 0).toDouble(),
      exactLat: (exactLocation?['lat'] ?? 0).toDouble(),
      exactLng: (exactLocation?['lng'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
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
      'approximateLocation': {'lat': approximateLat, 'lng': approximateLng},
      'exactLocation': {'lat': exactLat, 'lng': exactLng},
      'createdAt': FieldValue.serverTimestamp(),
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
    double? approximateLat,
    double? approximateLng,
    double? exactLat,
    double? exactLng,
    DateTime? createdAt,
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
      approximateLat: approximateLat ?? this.approximateLat,
      approximateLng: approximateLng ?? this.approximateLng,
      exactLat: exactLat ?? this.exactLat,
      exactLng: exactLng ?? this.exactLng,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id];
}
