import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/core/core.dart' as core; // For core.Tutor model

class TutorRepository {
  final FirebaseFirestore _firestore;

  TutorRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Creates a new tutor document in Firestore.
  ///
  /// [uid] is the unique ID of the user (and tutor).
  /// [tutor] is the Tutor object containing the data to be saved.
  /// Assumes that the [core.Tutor] model has a `toJson()` method.
  Future<void> createTutor(String uid, core.Tutor tutor) async {
    try {
      await _firestore.collection('tutors').doc(uid).set(tutor.toJson());
    } on FirebaseException catch (e) {
      print('Firebase Firestore Error (createTutor): ${e.code} - ${e.message}');
      throw Exception('Error creating tutor profile: ${e.message}');
    } catch (e) {
      print('Unexpected error creating tutor (createTutor): $e');
      throw Exception(
        'An unexpected error occurred while creating the tutor profile.',
      );
    }
  }

  /// Retrieve a List of tutors from Firestore.
  Future<List<core.Tutor>> getTutors() async {
    try {
      final snapshot = await _firestore.collection('tutors').get();
      return snapshot.docs
          .map((doc) => core.Tutor.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      print('Firebase Firestore Error (getTutors): ${e.code} - ${e.message}');
      throw Exception('Error retrieving tutors: ${e.message}');
    } catch (e) {
      print('Unexpected error retrieving tutors (getTutors): $e');
      throw Exception(
        'An unexpected error occurred while retrieving the tutors.',
      );
    }
  }

  /// Retrieves a single tutor by UID from Firestore.
  Future<core.Tutor?> getTutor(String uid) async {
    try {
      final doc = await _firestore.collection('tutors').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return core.Tutor.fromJson(doc.data()!);
      }
      return null;
    } on FirebaseException catch (e) {
      print('Firebase Firestore Error (getTutor): ${e.code} - ${e.message}');
      throw Exception('Error retrieving tutor: ${e.message}');
    } catch (e) {
      print('Unexpected error retrieving tutor (getTutor): $e');
      throw Exception(
        'An unexpected error occurred while retrieving the tutor.',
      );
    }
  }
}
