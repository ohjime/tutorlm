import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Message model representing a chat message between tutor and student
class Message extends Equatable {
  const Message({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.messageType = MessageType.text,
  });

  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final MessageType messageType;

  @override
  List<Object?> get props => [
    id,
    chatRoomId,
    senderId,
    senderName,
    content,
    timestamp,
    isRead,
    messageType,
  ];

  /// Converts this Message to a JSON-friendly map for Firestore
  Map<String, dynamic> toJson() => {
    'id': id,
    'chatRoomId': chatRoomId,
    'senderId': senderId,
    'senderName': senderName,
    'content': content,
    'timestamp': Timestamp.fromDate(timestamp),
    'isRead': isRead,
    'messageType': messageType.name,
  };

  /// Creates a Message from a Firestore document
  factory Message.fromJson(Map<String, dynamic> map, String documentId) {
    final timestamp = map['timestamp'] as Timestamp?;
    return Message(
      id: documentId,
      chatRoomId: map['chatRoomId'] as String,
      senderId: map['senderId'] as String,
      senderName: map['senderName'] as String,
      content: map['content'] as String,
      timestamp: timestamp?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] as bool? ?? false,
      messageType: MessageType.values.firstWhere(
        (e) => e.name == map['messageType'],
        orElse: () => MessageType.text,
      ),
    );
  }

  /// Creates a copy of this Message with the given fields replaced
  Message copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    MessageType? messageType,
  }) {
    return Message(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      messageType: messageType ?? this.messageType,
    );
  }

  /// Empty message for initial state
  static final Message empty = Message(
    id: '',
    chatRoomId: '',
    senderId: '',
    senderName: '',
    content: '',
    timestamp: DateTime.fromMillisecondsSinceEpoch(0),
  );

  /// Whether this message is empty
  bool get isEmpty => this == Message.empty;

  /// Whether this message is not empty
  bool get isNotEmpty => this != Message.empty;
}

/// Enum representing different types of messages
enum MessageType { text, image, file, system }
