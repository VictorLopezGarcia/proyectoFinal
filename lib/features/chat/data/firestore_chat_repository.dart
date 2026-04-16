import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_my_stuff/core/constants/firebase_constants.dart';
import 'package:rent_my_stuff/features/chat/data/chat_repository.dart';
import 'package:rent_my_stuff/features/chat/domain/chat.dart';

class FirestoreChatRepository implements ChatRepository {
  final FirebaseFirestore _firestore;

  FirestoreChatRepository(this._firestore);

  @override
  Future<String> createChat(List<String> participants) async {
    final chatId = participants..sort();
    final chatDoc = _firestore
        .collection(FirebaseConstants.chatsCollection)
        .doc(chatId.join('_'));

    final doc = await chatDoc.get();
    if (!doc.exists) {
      await chatDoc.set({
        'participants': participants,
        'lastMessage': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    return chatDoc.id;
  }

  @override
  Future<void> sendMessage(String chatId, Message message) async {
    await _firestore
        .collection(FirebaseConstants.chatsCollection)
        .doc(chatId)
        .collection(FirebaseConstants.messagesSubcollection)
        .add(message.toFirestore());

    await _firestore
        .collection(FirebaseConstants.chatsCollection)
        .doc(chatId)
        .update({
          'lastMessage': message.text,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection(FirebaseConstants.chatsCollection)
        .doc(chatId)
        .collection(FirebaseConstants.messagesSubcollection)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  @override
  Stream<List<Chat>> getUserChats(String userId) {
    return _firestore
        .collection(FirebaseConstants.chatsCollection)
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Chat.fromFirestore(doc.id, doc.data()))
            .toList());
  }
}
