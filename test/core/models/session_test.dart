import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/models/session.dart';
import 'package:app/core/core.dart' as core;

void main() {
  group('Session', () {
    test(
      'equivalence: two Sessions are equal if and only if all properties match',
      () {
        final slot1 = core.TimeSlot(
          id: 'slot1',
          name: 'Morning',
          start: DateTime(2025, 5, 27, 9, 0),
          end: DateTime(2025, 5, 27, 10, 0),
        );
        final slot2 = core.TimeSlot(
          id: 'slot1',
          name: 'Morning',
          start: DateTime(2025, 5, 27, 8, 0),
          end: DateTime(2025, 5, 27, 10, 0),
        );
        final s1 = Session(
          id: 'sess1',
          timeslot: slot1,
          tutorId: 'tutorA',
          studentId: 'studentB',
          status: SessionStatus.scheduled,
        );
        final s2 = Session(
          id: 'sess1',
          timeslot: slot1,
          tutorId: 'tutorA',
          studentId: 'studentB',
          status: SessionStatus.scheduled,
        );
        final s3 = Session(
          id: 'sess2',
          timeslot: slot2,
          tutorId: 'tutorA',
          studentId: 'studentB',
          status: SessionStatus.scheduled,
        );
        final s4 = Session(
          id: 'sess1',
          timeslot: slot2,
          tutorId: 'tutorA',
          studentId: 'studentB',
          status: SessionStatus.scheduled,
        );
        final s5 = Session(
          id: 'sess1',
          timeslot: slot1,
          tutorId: 'tutorA',
          studentId: 'studentB',
          status: SessionStatus.completed,
        );
        expect(s1, equals(s2));
        expect(s1 == s2, isTrue);
        expect(s1 == s3, isFalse);
        expect(s1 == s4, isFalse);
        expect(s1 == s5, isFalse);
      },
    );
    test('toJson and fromJson: round-trip preserves all properties', () {
      final slot = core.TimeSlot(
        id: 'abc',
        name: 'Test Slot',
        start: DateTime(2025, 5, 27, 14, 0, 1, 123),
        end: DateTime(2025, 5, 27, 15, 0, 2, 456),
      );
      final session = Session(
        id: 'sess1',
        timeslot: slot,
        tutorId: 'tutorA',
        studentId: 'studentB',
        status: SessionStatus.completed,
      );
      final json = session.toJson();
      expect(json['id'], equals('sess1'));
      expect(json['timeslot'], isA<Map<String, dynamic>>());
      expect(json['tutorId'], equals('tutorA'));
      expect(json['studentId'], equals('studentB'));
      expect(json['status'], equals('completed'));

      final fromJson = Session.fromJson(json);
      expect(fromJson, equals(session));
    });

    test('fromJson throws if status is invalid', () {
      final slot = core.TimeSlot(
        id: 'abc',
        name: 'Test Slot',
        start: DateTime(2025, 5, 27, 14, 0),
        end: DateTime(2025, 5, 27, 15, 0),
      );
      final json = Session(
        id: 'sess1',
        timeslot: slot,
        tutorId: 'tutorA',
        studentId: 'studentB',
        status: SessionStatus.completed,
      ).toJson();
      json['status'] = 'notAStatus';
      final result = Session.fromJson(json);
      expect(result.status, SessionStatus.scheduled);
    });
  });
}
