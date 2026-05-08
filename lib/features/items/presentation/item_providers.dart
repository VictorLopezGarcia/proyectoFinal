import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/item_repository.dart';
import '../data/firestore_item_repository.dart';
import '../domain/item.dart';

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return FirestoreItemRepository();
});

final itemsStreamProvider = StreamProvider.family<List<Item>, ItemFilter>(
  (ref, filter) {
    final repo = ref.watch(itemRepositoryProvider);
    return repo.getItems(
      category: filter.category,
      maxPrice: filter.maxPrice,
      searchQuery: filter.searchQuery,
    );
  },
);

final myItemsStreamProvider = StreamProvider.family<List<Item>, String>(
  (ref, ownerId) {
    final repo = ref.watch(itemRepositoryProvider);
    return repo.getItemsByOwner(ownerId);
  },
);

final itemDetailProvider = FutureProvider.family<Item?, String>(
  (ref, itemId) {
    final repo = ref.watch(itemRepositoryProvider);
    return repo.getItemById(itemId);
  },
);

class ItemFilter extends Equatable {
  final String? category;
  final double? maxPrice;
  final String? searchQuery;

  const ItemFilter({this.category, this.maxPrice, this.searchQuery});

  @override
  List<Object?> get props => [category, maxPrice, searchQuery];
}
