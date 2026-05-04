import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String reservationId;
  final double score;
  final String comment;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.reservationId,
    required this.score,
    required this.comment,
    required this.createdAt,
  });

  factory Rating.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Rating(
      id: doc.id,
      fromUserId: data['fromUserId'] as String? ?? '',
      toUserId: data['toUserId'] as String? ?? '',
      reservationId: data['reservationId'] as String? ?? '',
      score: (data['score'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'reservationId': reservationId,
      'score': score,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
