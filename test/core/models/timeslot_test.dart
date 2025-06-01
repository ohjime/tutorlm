import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/models/timeslot.dart';

void main() {
  group('TimeSlot', () {
    test(
      'equivalence: two TimeSlots are equal if and only if all properties match',
      () {
        final t1 = TimeSlot(
          id: '1',
          name: 'Slot 1',
          start: DateTime(2025, 5, 27, 10, 0),
          end: DateTime(2025, 5, 27, 11, 0),
        );
        final t2 = TimeSlot(
          id: '1',
          name: 'Slot 1',
          start: DateTime(2025, 5, 27, 10, 0),
          end: DateTime(2025, 5, 27, 11, 0),
        );
        final t3 = TimeSlot(
          id: '2',
          name: 'Slot 2',
          start: DateTime(2025, 5, 27, 10, 0),
          end: DateTime(2025, 5, 27, 11, 0),
        );
        final t4 = TimeSlot(
          id: '1',
          name: 'Slot 1',
          start: DateTime(2025, 5, 27, 10, 30),
          end: DateTime(2025, 5, 27, 11, 30),
        );
        expect(t1, equals(t2));
        expect(t1 == t2, isTrue);
        expect(t1 == t3, isFalse);
        expect(t1 == t4, isFalse);
      },
    );

    test('overlaps: returns true only if intervals share any instant', () {
      final a = TimeSlot(
        start: DateTime(2025, 5, 27, 9, 0),
        end: DateTime(2025, 5, 27, 10, 0),
      );
      final b = TimeSlot(
        start: DateTime(2025, 5, 27, 9, 30),
        end: DateTime(2025, 5, 27, 10, 30),
      );
      final c = TimeSlot(
        start: DateTime(2025, 5, 27, 10, 0),
        end: DateTime(2025, 5, 27, 11, 0),
      );
      final d = TimeSlot(
        start: DateTime(2025, 5, 27, 11, 0),
        end: DateTime(2025, 5, 27, 12, 0),
      );
      final e = TimeSlot(
        start: DateTime(2025, 5, 27, 8),
        end: DateTime(2025, 5, 27, 12),
      );
      expect(a.overlaps(b), isTrue); // overlap
      expect(a.overlaps(c), isFalse); // end meets start
      expect(a.overlaps(d), isFalse); // no overlap
      expect(b.overlaps(c), isTrue); // overlap
      expect(c.overlaps(d), isFalse); // end meets start
      expect(a.overlaps(e), isTrue); // e contains a
      expect(e.overlaps(a), isTrue); // a is contained in e
    });

    test('toJson and fromJson: round-trip preserves all properties', () {
      final slot = TimeSlot(
        id: 'abc',
        name: 'Test Slot',
        start: DateTime(2025, 5, 27, 14, 0, 1, 123),
        end: DateTime(2025, 5, 27, 15, 0, 2, 456),
      );
      final json = slot.toJson();
      expect(json['id'], equals('abc'));
      expect(json['name'], equals('Test Slot'));
      expect(json['start'], equals('2025-05-27T14:00:01.123'));
      expect(json['end'], equals('2025-05-27T15:00:02.456'));

      final fromJson = TimeSlot.fromJson(json);
      expect(fromJson, equals(slot));
    });

    test('fromJson throws if start or end is not a string', () {
      final badJson1 = {'start': 123, 'end': '2025-05-27T15:00:00'};
      final badJson2 = {'start': '2025-05-27T14:00:00', 'end': 456};
      expect(() => TimeSlot.fromJson(badJson1), throwsArgumentError);
      expect(() => TimeSlot.fromJson(badJson2), throwsArgumentError);
    });

    test('fromJson throws if start is not before end', () {
      final badJson = {
        'start': '2025-05-27T15:00:00',
        'end': '2025-05-27T14:00:00',
      };
      expect(() => TimeSlot.fromJson(badJson), throwsArgumentError);
    });
  });
}
