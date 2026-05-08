import 'package:cloud_firestore/cloud_firestore.dart';

enum ReservationStatus { pending, confirmed, rejected, cancelled, completed }

class Reservation {
  final String id;
  final String itemId;
  final String itemTitle;
  final String ownerId;
  final String renterId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final ReservationStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Reservation({
    required this.id,
    required this.itemId,
    required this.itemTitle,
    required this.ownerId,
    required this.renterId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory Reservation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reservation(
      id: doc.id,
      itemId: data['itemId'] as String? ?? '',
      itemTitle: data['itemTitle'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      renterId: data['renterId'] as String? ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: ReservationStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? ''),
        orElse: () => ReservationStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'itemId': itemId,
      'itemTitle': itemTitle,
      'ownerId': ownerId,
      'renterId': renterId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'totalPrice': totalPrice,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  Reservation copyWith({
    String? id,
    String? itemId,
    String? itemTitle,
    String? ownerId,
    String? renterId,
    DateTime? startDate,
    DateTime? endDate,
    double? totalPrice,
    ReservationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reservation(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemTitle: itemTitle ?? this.itemTitle,
      ownerId: ownerId ?? this.ownerId,
      renterId: renterId ?? this.renterId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool overlapsWith(Reservation other) {
    return startDate.isBefore(other.endDate) && endDate.isAfter(other.startDate);
  }
}
