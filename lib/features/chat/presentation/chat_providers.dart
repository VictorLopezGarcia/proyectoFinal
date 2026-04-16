import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rent_my_stuff/features/chat/data/firestore_chat_repository.dart';
import 'package:rent_my_stuff/features/chat/data/chat_repository.dart';
import 'package:rent_my_stuff/features/chat/domain/chat.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return FirestoreChatRepository(ref.watch(firestoreProvider));
});

final userChatsProvider = StreamProvider.family<List<Chat>, String>((ref, userId) {
  return ref.watch(chatRepositoryProvider).getUserChats(userId);
});

final messagesProvider = StreamProvider.family<List<Message>, String>((ref, chatId) {
  return ref.watch(chatRepositoryProvider).getMessages(chatId);
});
