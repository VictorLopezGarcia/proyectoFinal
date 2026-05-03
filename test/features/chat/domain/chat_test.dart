import 'package:flutter_test/flutter_test.dart';
import 'package:rent_my_stuff/features/chat/domain/chat.dart';

void main() {
  group('Chat domain model', () {
    test('toFirestore serializes participants and lastMessage', () {
      final chat = Chat(
        id: 'chat_01',
        participants: ['user_a', 'user_b'],
        lastMessage: '¡Hola!',
        updatedAt: DateTime(2026, 4, 18, 12, 30),
      );

      final map = chat.toFirestore();

      expect(map['participants'], ['user_a', 'user_b']);
      expect(map['lastMessage'], '¡Hola!');
      expect(map['updatedAt'], isA<DateTime>());
    });
  });

  group('Message domain model', () {
    test('toFirestore serializes senderId, text and timestamp', () {
      final message = Message(
        id: 'msg_01',
        senderId: 'user_a',
        text: '¿Está disponible?',
        timestamp: DateTime(2026, 4, 18, 12, 35),
      );

      final map = message.toFirestore();

      expect(map['senderId'], 'user_a');
      expect(map['text'], '¿Está disponible?');
      expect(map['timestamp'], isA<DateTime>());
    });
  });
}
