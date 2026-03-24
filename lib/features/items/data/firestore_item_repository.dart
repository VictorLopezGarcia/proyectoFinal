import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firebase_constants.dart';
import '../domain/item.dart';
import 'item_repository.dart';

class FirestoreItemRepository implements ItemRepository {
  final FirebaseFirestore _firestore;

  FirestoreItemRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _itemsRef =>
      _firestore.collection(FirebaseConstants.itemsCollection);

  @override
  Stream<List<Item>> getItems({String? category, double? maxPrice}) {
    Query query = _itemsRef.where('status', isEqualTo: 'available');

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    if (maxPrice != null) {
      query = query.where('pricePerDay', isLessThanOrEqualTo: maxPrice);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Item.fromFirestore(doc)).toList());
  }

  @override
  Stream<List<Item>> getItemsByOwner(String ownerId) {
    return _itemsRef
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Item.fromFirestore(doc)).toList());
  }

  @override
  Future<Item?> getItemById(String itemId) async {
    final doc = await _itemsRef.doc(itemId).get();
    if (!doc.exists) return null;
    return Item.fromFirestore(doc);
  }

  @override
  Future<String> createItem(Item item) async {
    final docRef = await _itemsRef.add(item.toFirestore());
    return docRef.id;
  }

  @override
  Future<void> updateItem(Item item) async {
    await _itemsRef.doc(item.id).update(item.toFirestore());
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await _itemsRef.doc(itemId).delete();
  }
}
