import 'package:rent_my_stuff/features/chat/domain/chat.dart';

abstract class ChatRepository {
  Future<String> createChat(List<String> participants);
  Future<void> sendMessage(String chatId, Message message);
  Stream<List<Message>> getMessages(String chatId);
  Stream<List<Chat>> getUserChats(String userId);
}
