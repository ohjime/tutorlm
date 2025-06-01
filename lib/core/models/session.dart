import 'package:app/core/core.dart' as core;
import 'package:equatable/equatable.dart';

/// SessionModel is a class that represents a session.
class Session extends Equatable {
  const Session({
    required this.id,
    this.timeslot,
    required this.tutorId,
    required this.studentId,
    required this.status,
  });

  final String id;
  final core.TimeSlot? timeslot;
  final String tutorId;
  final String studentId;
  final SessionStatus status;

  @override
  List<Object?> get props => [id, timeslot, tutorId, studentId, status];

  /// Converts this Session to a JSON-friendly map (for Firestore or API).
  Map<String, dynamic> toJson() => {
    'id': id,
    'timeslot': timeslot?.toJson(),
    'tutorId': tutorId,
    'studentId': studentId,
    'status': status.name, // Store enum as string
  };

  /// Creates a Session from a JSON map.
  factory Session.fromJson(Map<String, dynamic> map) {
    return Session(
      id: map['id'] as String,
      timeslot: core.TimeSlot.fromJson(map['timeslot'] as Map<String, dynamic>),
      tutorId: map['tutorId'] as String,
      studentId: map['studentId'] as String,
      status: SessionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SessionStatus.scheduled,
      ),
    );
  }

  /// Creates a copy of this Session with the given fields replaced.
  Session copyWith({
    String? id,
    core.TimeSlot? timeslot,
    String? tutorId,
    String? studentId,
    SessionStatus? status,
  }) {
    return Session(
      id: id ?? this.id,
      timeslot: timeslot ?? this.timeslot,
      tutorId: tutorId ?? this.tutorId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
    );
  }
}

/// SessionStatus is an enum that represents the status of a session.
enum SessionStatus { scheduled, inProgress, completed, cancelled }
