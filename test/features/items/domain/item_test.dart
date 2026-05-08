import 'package:flutter_test/flutter_test.dart';
import 'package:rent_my_stuff/features/items/domain/item.dart';

void main() {
  group('Item domain model', () {
    test('copyWith updates specified fields', () {
      final item = Item(
        id: '1',
        title: 'Taladro',
        description: 'Potente',
        photos: [],
        pricePerDay: 15.0,
        category: 'herramientas',
        ownerId: 'user1',
        status: 'available',
        createdAt: DateTime.now(),
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
        photos: [],
        pricePerDay: 15.0,
        category: 'herramientas',
        ownerId: 'user1',
        status: 'available',
        createdAt: DateTime.now(),
      );

      final map = item.toFirestore();

      expect(map['title'], 'Taladro');
      expect(map['pricePerDay'], 15.0);
      expect(map['status'], 'available');
      expect(map.containsKey('createdAt'), isTrue);
    });

    test('toFirestore includes location when provided', () {
      final item = Item(
        id: '1',
        title: 'Bicicleta',
        description: 'Montaña',
        photos: [],
        pricePerDay: 20.0,
        category: 'deportes',
        ownerId: 'user1',
        status: 'available',
        createdAt: DateTime.now(),
        locationName: 'Madrid, España',
        lat: 40.4168,
        lng: -3.7038,
      );

      final map = item.toFirestore();

      expect(map['locationName'], 'Madrid, España');
      expect(map['lat'], 40.4168);
      expect(map['lng'], -3.7038);
    });

    test('toFirestore excludes location when null', () {
      final item = Item(
        id: '1',
        title: 'Mesa',
        description: 'De madera',
        photos: [],
        pricePerDay: 5.0,
        category: 'hogar',
        ownerId: 'user1',
        status: 'available',
        createdAt: DateTime.now(),
      );

      final map = item.toFirestore();

      expect(map.containsKey('locationName'), isFalse);
      expect(map.containsKey('lat'), isFalse);
      expect(map.containsKey('lng'), isFalse);
    });
  });
}
