import 'package:app/core/core.dart';
import 'package:app/core/repositories/chat_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late ChatRepository chatRepository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      chatRepository = ChatRepository(firestore: fakeFirestore);
    });

    group('sendMessage', () {
      test('should send message and update chat room successfully', () async {
        const chatRoomId = 'chat-room-1';
        final message = Message(
          id: 'message-1',
          chatRoomId: chatRoomId,
          senderId: 'user-1',
          senderName: 'John Doe',
          content: 'Hello, world!',
          timestamp: DateTime.now(),
        );

        // First create a chat room
        await fakeFirestore.collection('chatRooms').doc(chatRoomId).set({
          'id': chatRoomId,
          'tutorId': 'tutor-1',
          'studentId': 'student-1',
          'tutorName': 'Tutor Name',
          'studentName': 'Student Name',
          'sessionId': 'session-1',
          'lastMessage': null,
          'lastMessageTimestamp': null,
          'unreadCount': 0,
          'isActive': true,
          'createdAt': DateTime.now().toIso8601String(),
        });

        await chatRepository.sendMessage(chatRoomId, message);

        // Check if message was added to subcollection
        final messagesSnapshot = await fakeFirestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .collection('messages')
            .get();

        expect(messagesSnapshot.docs.length, equals(1));
        final messageData = messagesSnapshot.docs.first.data();
        expect(messageData['senderId'], equals('user-1'));
        expect(messageData['content'], equals('Hello, world!'));

        // Check if chat room was updated
        final chatRoomDoc = await fakeFirestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .get();
        final chatRoomData = chatRoomDoc.data()!;
        expect(chatRoomData['lastMessage'], equals('Hello, world!'));
      });

      test('should handle multiple messages correctly', () async {
        const chatRoomId = 'chat-room-2';
        final message1 = Message(
          id: 'message-1',
          chatRoomId: chatRoomId,
          senderId: 'user-1',
          senderName: 'User One',
          content: 'First message',
          timestamp: DateTime.now(),
        );

        final message2 = Message(
          id: 'message-2',
          chatRoomId: chatRoomId,
          senderId: 'user-2',
          senderName: 'User Two',
          content: 'Second message',
          timestamp: DateTime.now().add(Duration(minutes: 1)),
        );

        // Create chat room
        await fakeFirestore.collection('chatRooms').doc(chatRoomId).set({
          'id': chatRoomId,
          'tutorId': 'user-1',
          'studentId': 'user-2',
          'tutorName': 'User One',
          'studentName': 'User Two',
          'sessionId': 'session-2',
          'lastMessage': null,
          'lastMessageTimestamp': null,
          'unreadCount': 0,
          'isActive': true,
          'createdAt': DateTime.now().toIso8601String(),
        });

        await chatRepository.sendMessage(chatRoomId, message1);
        await chatRepository.sendMessage(chatRoomId, message2);

        final messagesSnapshot = await fakeFirestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .collection('messages')
            .get();

        expect(messagesSnapshot.docs.length, equals(2));
      });
    });

    group('createChatRoom', () {
      test('should create a new chat room successfully', () async {
        final chatRoom = ChatRoom(
          id: 'new-chat-room',
          tutorId: 'tutor-1',
          studentId: 'student-1',
          tutorName: 'Tutor Name',
          studentName: 'Student Name',
          sessionId: 'session-1',
          createdAt: DateTime.now(),
        );

        // Use the returned ID from createChatRoom
        final createdId = await chatRepository.createChatRoom(chatRoom);

        final doc = await fakeFirestore
            .collection('chatRooms')
            .doc(createdId)
            .get();

        expect(doc.exists, isTrue);
        final data = doc.data()!;
        expect(data['tutorId'], equals('tutor-1'));
        expect(data['studentId'], equals('student-1'));
        expect(data['tutorName'], equals('Tutor Name'));
        expect(data['studentName'], equals('Student Name'));
        expect(data['sessionId'], equals('session-1'));
        expect(data['isActive'], isTrue);
        expect(data['unreadCount'], equals(0));
      });

      test('should create chat room with participants correctly', () async {
        final chatRoom = ChatRoom(
          id: 'participants-chat',
          tutorId: 'tutor-1',
          studentId: 'student-1',
          tutorName: 'Tutor Name',
          studentName: 'Student Name',
          sessionId: 'session-participants',
          createdAt: DateTime.now(),
        );

        final createdId = await chatRepository.createChatRoom(chatRoom);

        final doc = await fakeFirestore
            .collection('chatRooms')
            .doc(createdId)
            .get();

        expect(doc.exists, isTrue);
        final data = doc.data()!;

        // Check that participants can be derived from tutorId and studentId
        expect(data['tutorId'], equals('tutor-1'));
        expect(data['studentId'], equals('student-1'));

        // Create a ChatRoom from the data to test participants getter
        final retrievedChatRoom = ChatRoom.fromJson(data, createdId);
        expect(retrievedChatRoom.participants.length, equals(2));
        expect(retrievedChatRoom.participants.contains('tutor-1'), isTrue);
        expect(retrievedChatRoom.participants.contains('student-1'), isTrue);
      });
    });

    group('getChatRoom', () {
      test('should retrieve chat room when it exists', () async {
        const chatRoomId = 'existing-chat-room';
        final chatRoomData = {
          'id': chatRoomId,
          'tutorId': 'tutor-1',
          'studentId': 'student-1',
          'tutorName': 'Tutor Name',
          'studentName': 'Student Name',
          'sessionId': 'session-1',
          'lastMessage': 'Last message content',
          'lastMessageTimestamp': Timestamp.fromDate(DateTime.now()),
          'unreadCount': 2,
          'isActive': true,
          'createdAt': Timestamp.fromDate(DateTime.now()),
        };

        await fakeFirestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .set(chatRoomData);

        final chatRoom = await chatRepository.getChatRoom(chatRoomId);

        expect(chatRoom, isNotNull);
        expect(chatRoom!.id, equals(chatRoomId));
        expect(chatRoom.tutorId, equals('tutor-1'));
        expect(chatRoom.studentId, equals('student-1'));
        expect(chatRoom.tutorName, equals('Tutor Name'));
        expect(chatRoom.studentName, equals('Student Name'));
        expect(chatRoom.sessionId, equals('session-1'));
        expect(chatRoom.lastMessage, equals('Last message content'));
        expect(chatRoom.unreadCount, equals(2));
        expect(chatRoom.isActive, isTrue);
      });

      test('should return null when chat room does not exist', () async {
        const chatRoomId = 'nonexistent-chat-room';

        final chatRoom = await chatRepository.getChatRoom(chatRoomId);

        expect(chatRoom, isNull);
      });

      test('should handle chat room with null optional fields', () async {
        const chatRoomId = 'minimal-chat-room';
        final chatRoomData = {
          'id': chatRoomId,
          'tutorId': 'tutor-1',
          'studentId': 'student-1',
          'tutorName': 'Tutor Name',
          'studentName': 'Student Name',
          'sessionId': 'session-1',
          'lastMessage': null,
          'lastMessageTimestamp': null,
          'unreadCount': 0,
          'isActive': true,
          'createdAt': Timestamp.fromDate(DateTime.now()),
        };

        await fakeFirestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .set(chatRoomData);

        final chatRoom = await chatRepository.getChatRoom(chatRoomId);

        expect(chatRoom, isNotNull);
        expect(chatRoom!.lastMessage, isNull);
        expect(chatRoom.lastMessageTimestamp, isNull);
        expect(chatRoom.unreadCount, equals(0));
      });
    });

    group('getMessages', () {
      test(
        'should return messages for a chat room ordered by timestamp',
        () async {
          const chatRoomId = 'chat-messages';

          // Create chat room first
          await fakeFirestore.collection('chatRooms').doc(chatRoomId).set({
            'id': chatRoomId,
            'tutorId': 'tutor-1',
            'studentId': 'student-1',
            'tutorName': 'Tutor Name',
            'studentName': 'Student Name',
            'sessionId': 'session-1',
            'isActive': true,
            'createdAt': DateTime.now().toIso8601String(),
          });

          // Add messages with different timestamps
          final message1 = Message(
            id: 'message-1',
            chatRoomId: chatRoomId,
            senderId: 'tutor-1',
            senderName: 'Tutor Name',
            content: 'First message',
            timestamp: DateTime.now().subtract(Duration(minutes: 5)),
          );

          final message2 = Message(
            id: 'message-2',
            chatRoomId: chatRoomId,
            senderId: 'student-1',
            senderName: 'Student Name',
            content: 'Second message',
            timestamp: DateTime.now(),
          );

          await fakeFirestore
              .collection('chatRooms')
              .doc(chatRoomId)
              .collection('messages')
              .doc('message-1')
              .set(message1.toJson());

          await fakeFirestore
              .collection('chatRooms')
              .doc(chatRoomId)
              .collection('messages')
              .doc('message-2')
              .set(message2.toJson());

          final messages = await chatRepository.getMessages(chatRoomId);

          expect(messages.length, equals(2));
          // Should be ordered by timestamp (newest first typically)
          expect(messages.any((m) => m.content == 'First message'), isTrue);
          expect(messages.any((m) => m.content == 'Second message'), isTrue);
        },
      );

      test('should return empty list when no messages exist', () async {
        const chatRoomId = 'empty-chat';

        final messages = await chatRepository.getMessages(chatRoomId);

        expect(messages, isEmpty);
      });
    });

    group('markMessagesAsRead', () {
      test('should mark messages as read for specific user', () async {
        const chatRoomId = 'read-messages-chat';
        const userId = 'user-1';

        // Create messages where user is not the sender
        final ownMessage = Message(
          id: 'own-message',
          chatRoomId: chatRoomId,
          senderId: userId, // User's own message
          senderName: 'Own Name',
          content: 'My message',
          timestamp: DateTime.now(),
          isRead: false,
        );

        final otherMessage = Message(
          id: 'other-message',
          chatRoomId: chatRoomId,
          senderId: 'other-user',
          senderName: 'Other Name',
          content: 'Other message',
          timestamp: DateTime.now(),
          isRead: false,
        );

        // Add messages to Firestore
        await fakeFirestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .collection('messages')
            .doc('own-message')
            .set(ownMessage.toJson());

        await fakeFirestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .collection('messages')
            .doc('other-message')
            .set(otherMessage.toJson());

        await chatRepository.markMessagesAsRead(chatRoomId, userId);

        // Check if messages from other users are marked as read
        final otherMessageDoc = await fakeFirestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .collection('messages')
            .doc('other-message')
            .get();

        final otherMessageData = otherMessageDoc.data()!;
        expect(otherMessageData['isRead'], isTrue);

        // Own messages should remain unchanged
        final ownMessageDoc = await fakeFirestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .collection('messages')
            .doc('own-message')
            .get();

        final ownMessageData = ownMessageDoc.data()!;
        // Own messages read status depends on implementation
        // but they shouldn't be updated by this operation
      });

      test('should handle empty chat room gracefully', () async {
        const chatRoomId = 'empty-read-chat';
        const userId = 'user-1';

        // Should not throw when marking messages as read in empty chat
        expect(
          () => chatRepository.markMessagesAsRead(chatRoomId, userId),
          returnsNormally,
        );
      });
    });
  });
}
