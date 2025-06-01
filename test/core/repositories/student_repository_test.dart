import 'package:app/core/core.dart';
import 'package:app/core/repositories/student_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudentRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late StudentRepository studentRepository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      studentRepository = StudentRepository(firestore: fakeFirestore);
    });

    group('createStudent', () {
      test('should create a student document successfully', () async {
        const uid = 'student-uid';
        const student = Student(
          uid: uid,
          bio: 'High school student looking for math help',
          headline: 'Math Student',
          status: StudentStatus.active,
          courses: [
            Course(subjectType: Subject.math, generalLevel: Grade.eleven),
          ],
          gradeLevel: Grade.eleven,
          educationInstitute: 'Central High School',
        );

        await studentRepository.createStudent(uid, student);

        final doc = await fakeFirestore.collection('students').doc(uid).get();
        expect(doc.exists, isTrue);

        final data = doc.data()!;
        expect(data['uid'], equals(uid));
        expect(
          data['bio'],
          equals('High school student looking for math help'),
        );
        expect(data['headline'], equals('Math Student'));
        expect(data['status'], equals('active'));
        expect(data['gradeLevel'], equals('eleven'));
        expect(data['educationInstitute'], equals('Central High School'));
        expect(data['courses'], isA<List>());
      });

      test('should create empty student successfully', () async {
        const uid = 'empty-student-uid';
        const student = Student.empty;

        await studentRepository.createStudent(uid, student);

        final doc = await fakeFirestore.collection('students').doc(uid).get();
        expect(doc.exists, isTrue);

        final data = doc.data()!;
        expect(data['uid'], equals(''));
        expect(data['bio'], equals(''));
        expect(data['headline'], equals(''));
        expect(data['status'], equals('inactive'));
        expect(data['gradeLevel'], equals('unknown'));
        expect(data['educationInstitute'], equals(''));
        expect(data['courses'], isEmpty);
      });

      test('should create student with multiple courses', () async {
        const uid = 'multi-course-student';
        const student = Student(
          uid: uid,
          bio: 'Student studying multiple subjects',
          headline: 'Multi-Subject Student',
          status: StudentStatus.active,
          courses: [
            Course(subjectType: Subject.math, generalLevel: Grade.twelve),
            Course(subjectType: Subject.science, generalLevel: Grade.twelve),
            Course(subjectType: Subject.english, generalLevel: Grade.twelve),
          ],
          gradeLevel: Grade.twelve,
          educationInstitute: 'Downtown High School',
        );

        await studentRepository.createStudent(uid, student);

        final doc = await fakeFirestore.collection('students').doc(uid).get();
        expect(doc.exists, isTrue);

        final data = doc.data()!;
        expect(data['courses'], hasLength(3));
        expect(data['gradeLevel'], equals('twelve'));
      });
    });

    group('getStudent', () {
      test('should return student when document exists', () async {
        const uid = 'existing-student';
        final studentData = {
          'uid': uid,
          'bio': 'Dedicated student',
          'headline': 'Science Enthusiast',
          'status': 'active',
          'gradeLevel': 'undergraduate',
          'educationInstitute': 'State University',
          'courses': [
            {'subjectType': 'biology', 'generalLevel': 'undergraduate'},
            {'subjectType': 'chemistry', 'generalLevel': 'undergraduate'},
          ],
        };

        await fakeFirestore.collection('students').doc(uid).set(studentData);

        final student = await studentRepository.getStudent(uid);

        expect(student, isNotNull);
        expect(student!.uid, equals(uid));
        expect(student.bio, equals('Dedicated student'));
        expect(student.headline, equals('Science Enthusiast'));
        expect(student.status, equals(StudentStatus.active));
        expect(student.gradeLevel, equals(Grade.undergraduate));
        expect(student.educationInstitute, equals('State University'));
        expect(student.courses.length, equals(2));
        expect(
          student.courses.any((c) => c.subjectType == Subject.biology),
          isTrue,
        );
        expect(
          student.courses.any((c) => c.subjectType == Subject.chemistry),
          isTrue,
        );
      });

      test('should return null when document does not exist', () async {
        const uid = 'nonexistent-student';

        final student = await studentRepository.getStudent(uid);

        expect(student, isNull);
      });

      test('should handle student with minimal data', () async {
        const uid = 'minimal-student';
        final studentData = {
          'uid': uid,
          'bio': '',
          'headline': '',
          'status': 'inactive',
          'gradeLevel': 'unknown',
          'educationInstitute': '',
          'courses': <Map<String, dynamic>>[],
        };

        await fakeFirestore.collection('students').doc(uid).set(studentData);

        final student = await studentRepository.getStudent(uid);

        expect(student, isNotNull);
        expect(student!.uid, equals(uid));
        expect(student.bio, isEmpty);
        expect(student.headline, isEmpty);
        expect(student.status, equals(StudentStatus.inactive));
        expect(student.gradeLevel, equals(Grade.unknown));
        expect(student.educationInstitute, isEmpty);
        expect(student.courses, isEmpty);
      });

      test('should handle student with different grade levels', () async {
        const uid = 'grade-test-student';
        final studentData = {
          'uid': uid,
          'bio': 'High school senior',
          'headline': 'Senior Student',
          'status': 'active',
          'gradeLevel': 'twelve',
          'educationInstitute': 'High School',
          'courses': [
            {'subjectType': 'math', 'generalLevel': 'twelve'},
          ],
        };

        await fakeFirestore.collection('students').doc(uid).set(studentData);

        final student = await studentRepository.getStudent(uid);

        expect(student, isNotNull);
        expect(student!.gradeLevel, equals(Grade.twelve));
        expect(student.courses.first.generalLevel, equals(Grade.twelve));
      });

      test('should handle student with graduate level courses', () async {
        const uid = 'grad-student';
        final studentData = {
          'uid': uid,
          'bio': 'Graduate student in physics',
          'headline': 'Physics Graduate',
          'status': 'active',
          'gradeLevel': 'graduate',
          'educationInstitute': 'University of Science',
          'courses': [
            {'subjectType': 'physics', 'generalLevel': 'graduate'},
          ],
        };

        await fakeFirestore.collection('students').doc(uid).set(studentData);

        final student = await studentRepository.getStudent(uid);

        expect(student, isNotNull);
        expect(student!.gradeLevel, equals(Grade.graduate));
        expect(student.courses.first.subjectType, equals(Subject.physics));
        expect(student.courses.first.generalLevel, equals(Grade.graduate));
      });
    });
  });
}
