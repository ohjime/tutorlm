import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// ChatRoom model representing a chat session between tutor and student
class ChatRoom extends Equatable {
  const ChatRoom({
    required this.id,
    required this.tutorId,
    required this.studentId,
    required this.tutorName,
    required this.studentName,
    required this.sessionId,
    this.lastMessage,
    this.lastMessageTimestamp,
    this.unreadCount = 0,
    this.isActive = true,
    required this.createdAt,
  });

  final String id;
  final String tutorId;
  final String studentId;
  final String tutorName;
  final String studentName;
  final String sessionId;
  final String? lastMessage;
  final DateTime? lastMessageTimestamp;
  final int unreadCount;
  final bool isActive;
  final DateTime createdAt;

  /// List of participant user IDs (tutor and student)
  List<String> get participants => [tutorId, studentId];

  @override
  List<Object?> get props => [
    id,
    tutorId,
    studentId,
    tutorName,
    studentName,
    sessionId,
    lastMessage,
    lastMessageTimestamp,
    unreadCount,
    isActive,
    createdAt,
  ];

  /// Converts this ChatRoom to a JSON-friendly map for Firestore
  Map<String, dynamic> toJson() => {
    'id': id,
    'tutorId': tutorId,
    'studentId': studentId,
    'tutorName': tutorName,
    'studentName': studentName,
    'sessionId': sessionId,
    'participants': participants,
    'lastMessage': lastMessage,
    'lastMessageTimestamp': lastMessageTimestamp != null
        ? Timestamp.fromDate(lastMessageTimestamp!)
        : null,
    'unreadCount': unreadCount,
    'isActive': isActive,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  /// Creates a ChatRoom from a Firestore document
  factory ChatRoom.fromJson(Map<String, dynamic> map, String documentId) {
    final lastMessageTimestamp = map['lastMessageTimestamp'] as Timestamp?;
    final createdAt = map['createdAt'] as Timestamp?;

    return ChatRoom(
      id: documentId,
      tutorId: map['tutorId'] as String,
      studentId: map['studentId'] as String,
      tutorName: map['tutorName'] as String,
      studentName: map['studentName'] as String,
      sessionId: map['sessionId'] as String,
      lastMessage: map['lastMessage'] as String?,
      lastMessageTimestamp: lastMessageTimestamp?.toDate(),
      unreadCount: map['unreadCount'] as int? ?? 0,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: createdAt?.toDate() ?? DateTime.now(),
    );
  }

  /// Creates a copy of this ChatRoom with the given fields replaced
  ChatRoom copyWith({
    String? id,
    String? tutorId,
    String? studentId,
    String? tutorName,
    String? studentName,
    String? sessionId,
    String? lastMessage,
    DateTime? lastMessageTimestamp,
    int? unreadCount,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      tutorId: tutorId ?? this.tutorId,
      studentId: studentId ?? this.studentId,
      tutorName: tutorName ?? this.tutorName,
      studentName: studentName ?? this.studentName,
      sessionId: sessionId ?? this.sessionId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Empty chat room for initial state
  static final ChatRoom empty = ChatRoom(
    id: '',
    tutorId: '',
    studentId: '',
    tutorName: '',
    studentName: '',
    sessionId: '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  /// Whether this chat room is empty
  bool get isEmpty => this == ChatRoom.empty;

  /// Whether this chat room is not empty
  bool get isNotEmpty => this != ChatRoom.empty;

  /// Get the other participant's name based on current user ID
  String getOtherParticipantName(String currentUserId) {
    return currentUserId == tutorId ? studentName : tutorName;
  }

  /// Get the other participant's ID based on current user ID
  String getOtherParticipantId(String currentUserId) {
    return currentUserId == tutorId ? studentId : tutorId;
  }
}
