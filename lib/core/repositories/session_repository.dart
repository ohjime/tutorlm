import 'package:app/core/core.dart' as core;
import 'package:cloud_firestore/cloud_firestore.dart';

class SessionRepository {
  final FirebaseFirestore _firestore;

  SessionRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Returns a stream of session lists from Firestore.
  Stream<List<core.Session>> getSessions() {
    return _firestore.collection('sessions').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return core.Session(
          id: doc.id, // Use document ID as session ID
          timeslot: core.TimeSlot.fromJson(
            data['timeslot'] as Map<String, dynamic>,
          ),
          tutorId: data['tutorId'] as String,
          studentId: data['studentId'] as String,
          status: core.SessionStatus.values.firstWhere(
            (e) => e.name == data['status'],
            orElse: () => core.SessionStatus.scheduled,
          ),
        );
      }).toList();
    });
  }

  /// Creates a new session in Firestore.
  Future<void> create(core.Session session) async {
    final sessionData = session.toJson();
    await _firestore.collection('sessions').add(sessionData);
  }

  /// Retrieves a specific session by its ID from Firestore.
  Future<core.Session?> getSessionById(String sessionId) async {
    try {
      final doc = await _firestore.collection('sessions').doc(sessionId).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return core.Session(
          id: doc.id,
          timeslot: data['timeslot'] != null
              ? core.TimeSlot.fromJson(data['timeslot'] as Map<String, dynamic>)
              : null,
          tutorId: data['tutorId'] as String,
          studentId: data['studentId'] as String,
          status: core.SessionStatus.values.firstWhere(
            (e) => e.name == data['status'],
            orElse: () => core.SessionStatus.scheduled,
          ),
        );
      }
      return null;
    } catch (e) {
      print('Error getting session by ID: $e');
      throw Exception('Failed to get session: $e');
    }
  }
}
