import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/core/core.dart' as core; // For core.Student model

class StudentRepository {
  final FirebaseFirestore _firestore;

  StudentRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Creates a new student document in Firestore.
  ///
  /// [uid] is the unique ID of the user (and student).
  /// [student] is the Student object containing the data to be saved.
  /// Assumes that the [core.Student] model has a `toJson()` method.
  Future<void> createStudent(String uid, core.Student student) async {
    try {
      await _firestore.collection('students').doc(uid).set(student.toJson());
    } on FirebaseException catch (e) {
      print(
        'Firebase Firestore Error (createStudent): ${e.code} - ${e.message}',
      );
      throw Exception('Error creating student profile: ${e.message}');
    } catch (e) {
      print('Unexpected error creating student (createStudent): $e');
      throw Exception(
        'An unexpected error occurred while creating the student profile.',
      );
    }
  }

  /// Retrieves a single student by UID from Firestore.
  Future<core.Student?> getStudent(String uid) async {
    try {
      final doc = await _firestore.collection('students').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return core.Student.fromJson(doc.data()!);
      }
      return null;
    } on FirebaseException catch (e) {
      print('Firebase Firestore Error (getStudent): ${e.code} - ${e.message}');
      throw Exception('Error retrieving student: ${e.message}');
    } catch (e) {
      print('Unexpected error retrieving student (getStudent): $e');
      throw Exception(
        'An unexpected error occurred while retrieving the student.',
      );
    }
  }
}
