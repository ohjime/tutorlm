import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/core/core.dart' as core;

/// Repository for managing chat-related operations with Firestore.
class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Send a message to a chat room.
  Future<void> sendMessage(String chatRoomId, core.Message message) async {
    await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(message.toJson());

    // Update the chat room's last message and timestamp
    await _firestore.collection('chatRooms').doc(chatRoomId).update({
      'lastMessage': message.content,
      'lastMessageTimestamp': Timestamp.fromDate(message.timestamp),
      'lastMessageSenderId': message.senderId,
    });
  }

  /// Create a new chat room.
  Future<String> createChatRoom(core.ChatRoom chatRoom) async {
    final docRef = await _firestore
        .collection('chatRooms')
        .add(chatRoom.toJson());
    return docRef.id;
  }

  /// Get a specific chat room by ID.
  Future<core.ChatRoom?> getChatRoom(String chatRoomId) async {
    final doc = await _firestore.collection('chatRooms').doc(chatRoomId).get();

    if (doc.exists && doc.data() != null) {
      return core.ChatRoom.fromJson(doc.data()!, doc.id);
    }
    return null;
  }

  /// Mark messages as read for a specific user in a chat room.
  Future<void> markMessagesAsRead(String chatRoomId, String userId) async {
    final messagesQuery = await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('senderId', isNotEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in messagesQuery.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// Get all messages for a chat room, ordered by timestamp ascending.
  Future<List<core.Message>> getMessages(String chatRoomId) async {
    final querySnapshot = await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp')
        .get();
    return querySnapshot.docs
        .map((doc) => core.Message.fromJson(doc.data(), doc.id))
        .toList();
  }
}
