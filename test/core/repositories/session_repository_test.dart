import 'package:app/core/core.dart' as core;
import 'package:app/core/repositories/session_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SessionRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late SessionRepository sessionRepository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      sessionRepository = SessionRepository(firestore: fakeFirestore);
    });

    group('getSessions', () {
      test('should return an empty list when no sessions exist', () {
        final stream = sessionRepository.getSessions();
        expectLater(stream, emits([]));
      });

      test('should return a list of sessions when sessions exist', () async {
        final now = DateTime.now();
        final timeslot1 = core.TimeSlot(
          start: now,
          end: now.add(const Duration(hours: 1)),
        );
        final timeslot2 = core.TimeSlot(
          start: now.add(const Duration(days: 1)),
          end: now.add(const Duration(days: 1, hours: 1)),
        );

        final sessionData1 = {
          'timeslot': timeslot1.toJson(),
          'tutorId': 'tutor1',
          'studentId': 'student1',
          'status': core.SessionStatus.scheduled.name,
        };
        final sessionData2 = {
          'timeslot': timeslot2.toJson(),
          'tutorId': 'tutor2',
          'studentId': 'student2',
          'status': core.SessionStatus.completed.name,
        };

        final docRef1 = await fakeFirestore
            .collection('sessions')
            .add(sessionData1);
        final docRef2 = await fakeFirestore
            .collection('sessions')
            .add(sessionData2);

        final stream = sessionRepository.getSessions();

        expectLater(
          stream,
          emitsInOrder([
            [
              isA<core.Session>()
                  .having((s) => s.id, 'id', docRef1.id)
                  .having((s) => s.tutorId, 'tutorId', 'tutor1')
                  .having((s) => s.studentId, 'studentId', 'student1')
                  .having(
                    (s) => s.status,
                    'status',
                    core.SessionStatus.scheduled,
                  )
                  .having(
                    (s) => s.timeslot!.start.toIso8601String(),
                    'timeslot.start',
                    timeslot1.start.toIso8601String(),
                  )
                  .having(
                    (s) => s.timeslot!.end.toIso8601String(),
                    'timeslot.end',
                    timeslot1.end.toIso8601String(),
                  ),
              isA<core.Session>()
                  .having((s) => s.id, 'id', docRef2.id)
                  .having((s) => s.tutorId, 'tutorId', 'tutor2')
                  .having((s) => s.studentId, 'studentId', 'student2')
                  .having(
                    (s) => s.status,
                    'status',
                    core.SessionStatus.completed,
                  )
                  .having(
                    (s) => s.timeslot!.start.toIso8601String(),
                    'timeslot.start',
                    timeslot2.start.toIso8601String(),
                  )
                  .having(
                    (s) => s.timeslot!.end.toIso8601String(),
                    'timeslot.end',
                    timeslot2.end.toIso8601String(),
                  ),
            ],
          ]),
        );
      });

      test(
        'should default to scheduled status if status is missing or invalid',
        () async {
          final now = DateTime.now();
          final timeslot = core.TimeSlot(
            start: now,
            end: now.add(const Duration(hours: 1)),
          );

          final sessionDataMissingStatus = {
            'timeslot': timeslot.toJson(),
            'tutorId': 'tutor1',
            'studentId': 'student1',
            // 'status': core.SessionStatus.scheduled.name, // Status missing
          };
          final sessionDataInvalidStatus = {
            'timeslot': timeslot.toJson(),
            'tutorId': 'tutor2',
            'studentId': 'student2',
            'status': 'invalid_status_value',
          };

          final docRef1 = await fakeFirestore
              .collection('sessions')
              .add(sessionDataMissingStatus);
          final docRef2 = await fakeFirestore
              .collection('sessions')
              .add(sessionDataInvalidStatus);

          final stream = sessionRepository.getSessions();

          expectLater(
            stream,
            emitsInOrder([
              [
                isA<core.Session>()
                    .having((s) => s.id, 'id', docRef1.id)
                    .having(
                      (s) => s.status,
                      'status',
                      core.SessionStatus.scheduled,
                    ),
                isA<core.Session>()
                    .having((s) => s.id, 'id', docRef2.id)
                    .having(
                      (s) => s.status,
                      'status',
                      core.SessionStatus.scheduled,
                    ),
              ],
            ]),
          );
        },
      );
    });

    group('create', () {
      test('should create a new session in Firestore', () async {
        final now = DateTime.now();
        final timeslot = core.TimeSlot(
          start: now,
          end: now.add(const Duration(hours: 1)),
        );
        final session = core.Session(
          id: 'testId', // ID is ignored by create, Firestore generates it
          timeslot: timeslot,
          tutorId: 'tutorNew',
          studentId: 'studentNew',
          status: core.SessionStatus.scheduled,
        );

        await sessionRepository.create(session);

        final snapshot = await fakeFirestore.collection('sessions').get();
        expect(snapshot.docs.length, 1);

        final doc = snapshot.docs.first;
        final data = doc.data();

        expect(data['tutorId'], 'tutorNew');
        expect(data['studentId'], 'studentNew');
        expect(data['status'], core.SessionStatus.scheduled.name);

        // Firestore stores Timestamps, so we compare epoch milliseconds
        final expectedTimeslotJson = timeslot.toJson();
        final actualTimeslotJson = data['timeslot'] as Map<String, dynamic>;

        expect(
          DateTime.parse(actualTimeslotJson['start']).millisecondsSinceEpoch,
          DateTime.parse(expectedTimeslotJson['start']).millisecondsSinceEpoch,
        );
        expect(
          DateTime.parse(actualTimeslotJson['end']).millisecondsSinceEpoch,
          DateTime.parse(expectedTimeslotJson['end']).millisecondsSinceEpoch,
        );
      });
    });
  });
}
