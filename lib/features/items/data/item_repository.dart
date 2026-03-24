import '../domain/item.dart';

abstract class ItemRepository {
  Stream<List<Item>> getItems({String? category, double? maxPrice});
  Stream<List<Item>> getItemsByOwner(String ownerId);
  Future<Item?> getItemById(String itemId);
  Future<String> createItem(Item item);
  Future<void> updateItem(Item item);
  Future<void> deleteItem(String itemId);
}
