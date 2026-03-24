import 'package:flutter_test/flutter_test.dart';
import 'package:rent_my_stuff/features/items/domain/item.dart';

void main() {
  group('Item domain model', () {
    test('copyWith updates specified fields', () {
      final item = Item(
        id: '1',
        title: 'Taladro',
        description: 'Potente',
        pricePerDay: 15.0,
        category: 'herramientas',
        ownerId: 'user1',
        approximateLat: 40.0,
        approximateLng: -3.0,
        exactLat: 40.01,
        exactLng: -3.01,
      );

      final updatedItem = item.copyWith(
        title: 'Taladro Bosch',
        pricePerDay: 12.0,
      );

      expect(updatedItem.title, 'Taladro Bosch');
      expect(updatedItem.pricePerDay, 12.0);
      expect(updatedItem.id, '1');
    });

    test('toFirestore creates valid map', () {
      final item = Item(
        id: '1',
        title: 'Taladro',
        description: 'Potente',
        pricePerDay: 15.0,
        category: 'herramientas',
        ownerId: 'user1',
        status: 'available',
        approximateLat: 40.0,
        approximateLng: -3.0,
        exactLat: 40.01,
        exactLng: -3.01,
      );

      final map = item.toFirestore();

      expect(map['title'], 'Taladro');
      expect(map['pricePerDay'], 15.0);
      expect(map['status'], 'available');
      expect((map['approximateLocation'] as Map)['lat'], 40.0);
      expect((map['exactLocation'] as Map)['lng'], -3.01);
      expect(map.containsKey('createdAt'), isTrue);
    });
  });
}
