import 'package:app/core/core.dart';
import 'package:app/core/repositories/tutor_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TutorRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late TutorRepository tutorRepository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      tutorRepository = TutorRepository(firestore: fakeFirestore);
    });

    group('createTutor', () {
      test('should create a tutor document successfully', () async {
        const uid = 'tutor-uid';
        final tutor = Tutor(
          uid: uid,
          bio: 'Experienced math tutor',
          headline: 'Math Expert',
          courses: [
            Course(subjectType: Subject.math, generalLevel: Grade.twelve),
          ],
          tutorStatus: TutorStatus.active,
          academicCredentials: [
            AcademicCredential(
              institution: 'University of Example',
              level: AcademicCredentialLevel.bachelor,
              fieldOfStudy: 'Mathematics',
              focus: 'Applied Mathematics',
              dateIssued: DateTime(2020, 5, 15),
              imageUrl: 'https://example.com/credential.jpg',
            ),
          ],
        );

        await tutorRepository.createTutor(uid, tutor);

        final doc = await fakeFirestore.collection('tutors').doc(uid).get();
        expect(doc.exists, isTrue);

        final data = doc.data()!;
        expect(data['uid'], equals(uid));
        expect(data['bio'], equals('Experienced math tutor'));
        expect(data['headline'], equals('Math Expert'));
        expect(data['tutorStatus'], equals('active'));
        expect(data['courses'], isA<List>());
        expect(data['academicCredentials'], isA<List>());
      });

      test('should create empty tutor successfully', () async {
        const uid = 'empty-tutor-uid';
        const tutor = Tutor.empty;

        await tutorRepository.createTutor(uid, tutor);

        final doc = await fakeFirestore.collection('tutors').doc(uid).get();
        expect(doc.exists, isTrue);

        final data = doc.data()!;
        expect(data['uid'], equals(''));
        expect(data['bio'], equals(''));
        expect(data['headline'], equals(''));
        expect(data['tutorStatus'], equals('inactive'));
        expect(data['courses'], isEmpty);
        expect(data['academicCredentials'], isEmpty);
      });
    });

    group('getTutors', () {
      test('should return empty list when no tutors exist', () async {
        final tutors = await tutorRepository.getTutors();
        expect(tutors, isEmpty);
      });

      test('should return all tutors when multiple tutors exist', () async {
        final tutorData1 = {
          'uid': 'tutor1',
          'bio': 'Math tutor',
          'headline': 'Math Expert',
          'tutorStatus': 'active',
          'courses': [
            {'subjectType': 'math', 'generalLevel': 'twelve'},
          ],
          'academicCredentials': [
            {
              'institution': 'University A',
              'level': 'bachelor',
              'fieldOfStudy': 'Mathematics',
              'focus': 'Pure Mathematics',
              'dateIssued': '2020-05-15T00:00:00.000Z',
              'imageUrl': 'https://example.com/cred1.jpg',
            },
          ],
        };

        final tutorData2 = {
          'uid': 'tutor2',
          'bio': 'Science tutor',
          'headline': 'Science Guru',
          'tutorStatus': 'active',
          'courses': [
            {'subjectType': 'science', 'generalLevel': 'eleven'},
          ],
          'academicCredentials': [
            {
              'institution': 'University B',
              'level': 'masters',
              'fieldOfStudy': 'Physics',
              'focus': 'Quantum Physics',
              'dateIssued': '2018-06-30T00:00:00.000Z',
              'imageUrl': 'https://example.com/cred2.jpg',
            },
          ],
        };

        await fakeFirestore.collection('tutors').doc('tutor1').set(tutorData1);
        await fakeFirestore.collection('tutors').doc('tutor2').set(tutorData2);

        final tutors = await tutorRepository.getTutors();

        expect(tutors.length, equals(2));
        expect(tutors.any((t) => t.uid == 'tutor1'), isTrue);
        expect(tutors.any((t) => t.uid == 'tutor2'), isTrue);
        expect(tutors.any((t) => t.bio == 'Math tutor'), isTrue);
        expect(tutors.any((t) => t.bio == 'Science tutor'), isTrue);
      });

      test('should parse tutors with complex data correctly', () async {
        final tutorData = {
          'uid': 'complex-tutor',
          'bio': 'Multi-subject tutor with extensive experience',
          'headline': 'Multi-Subject Expert',
          'tutorStatus': 'active',
          'courses': [
            {'subjectType': 'math', 'generalLevel': 'twelve'},
            {'subjectType': 'physics', 'generalLevel': 'undergraduate'},
          ],
          'academicCredentials': [
            {
              'institution': 'Harvard University',
              'level': 'doctorate',
              'fieldOfStudy': 'Applied Mathematics',
              'focus': 'Mathematical Modeling',
              'dateIssued': '2015-05-15T00:00:00.000Z',
              'imageUrl': 'https://example.com/phd.jpg',
            },
            {
              'institution': 'MIT',
              'level': 'masters',
              'fieldOfStudy': 'Physics',
              'focus': 'Theoretical Physics',
              'dateIssued': '2012-06-30T00:00:00.000Z',
              'imageUrl': 'https://example.com/masters.jpg',
            },
          ],
        };

        await fakeFirestore
            .collection('tutors')
            .doc('complex-tutor')
            .set(tutorData);

        final tutors = await tutorRepository.getTutors();

        expect(tutors.length, equals(1));
        final tutor = tutors.first;
        expect(tutor.uid, equals('complex-tutor'));
        expect(tutor.courses.length, equals(2));
        expect(tutor.academicCredentials.length, equals(2));
        expect(tutor.tutorStatus, equals(TutorStatus.active));
      });
    });

    group('getTutor', () {
      test('should return tutor when document exists', () async {
        const uid = 'existing-tutor';
        final tutorData = {
          'uid': uid,
          'bio': 'Experienced tutor',
          'headline': 'Expert Tutor',
          'tutorStatus': 'active',
          'courses': [
            {'subjectType': 'english', 'generalLevel': 'ten'},
          ],
          'academicCredentials': [
            {
              'institution': 'Oxford University',
              'level': 'masters',
              'fieldOfStudy': 'English Literature',
              'focus': 'Modern Literature',
              'dateIssued': '2019-07-01T00:00:00.000Z',
              'imageUrl': 'https://example.com/oxford.jpg',
            },
          ],
        };

        await fakeFirestore.collection('tutors').doc(uid).set(tutorData);

        final tutor = await tutorRepository.getTutor(uid);

        expect(tutor, isNotNull);
        expect(tutor!.uid, equals(uid));
        expect(tutor.bio, equals('Experienced tutor'));
        expect(tutor.headline, equals('Expert Tutor'));
        expect(tutor.tutorStatus, equals(TutorStatus.active));
        expect(tutor.courses.length, equals(1));
        expect(tutor.courses.first.subjectType, equals(Subject.english));
        expect(tutor.academicCredentials.length, equals(1));
      });

      test('should return null when document does not exist', () async {
        const uid = 'nonexistent-tutor';

        final tutor = await tutorRepository.getTutor(uid);

        expect(tutor, isNull);
      });

      test('should handle tutor with minimal data', () async {
        const uid = 'minimal-tutor';
        final tutorData = {
          'uid': uid,
          'bio': '',
          'headline': '',
          'tutorStatus': 'inactive',
          'courses': <Map<String, dynamic>>[],
          'academicCredentials': <Map<String, dynamic>>[],
        };

        await fakeFirestore.collection('tutors').doc(uid).set(tutorData);

        final tutor = await tutorRepository.getTutor(uid);

        expect(tutor, isNotNull);
        expect(tutor!.uid, equals(uid));
        expect(tutor.bio, isEmpty);
        expect(tutor.headline, isEmpty);
        expect(tutor.tutorStatus, equals(TutorStatus.inactive));
        expect(tutor.courses, isEmpty);
        expect(tutor.academicCredentials, isEmpty);
      });
    });
  });
}
