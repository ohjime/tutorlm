import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/models/schedule.dart';
import 'package:app/core/models/timeslot.dart';

void main() {
  group('Month enum', () {
    test('should have correct month numbers', () {
      expect(Month.january.monthNumber, equals(1));
      expect(Month.february.monthNumber, equals(2));
      expect(Month.march.monthNumber, equals(3));
      expect(Month.april.monthNumber, equals(4));
      expect(Month.may.monthNumber, equals(5));
      expect(Month.june.monthNumber, equals(6));
      expect(Month.july.monthNumber, equals(7));
      expect(Month.august.monthNumber, equals(8));
      expect(Month.september.monthNumber, equals(9));
      expect(Month.october.monthNumber, equals(10));
      expect(Month.november.monthNumber, equals(11));
      expect(Month.december.monthNumber, equals(12));
    });

    test('date() should return correct DateTime for given year', () {
      expect(Month.january.date(year: 2025), equals(DateTime(2025, 1, 1)));
      expect(Month.june.date(year: 2024), equals(DateTime(2024, 6, 1)));
      expect(Month.december.date(year: 2023), equals(DateTime(2023, 12, 1)));
    });
  });

  group('Schedule', () {
    late TimeSlot validSlot1;
    late TimeSlot validSlot2;
    late TimeSlot invalidSlot;
    late DateTime mayInput;

    setUp(() {
      mayInput = DateTime(2025, 5, 15); // May 2025
      validSlot1 = TimeSlot(
        id: 'slot1',
        name: 'Morning Session',
        start: DateTime(2025, 5, 10, 9, 0), // Valid: within May 2025
        end: DateTime(2025, 5, 10, 10, 0),
      );
      validSlot2 = TimeSlot(
        id: 'slot2',
        name: 'Afternoon Session',
        start: DateTime(2025, 5, 15, 14, 0), // Valid: within May 2025
        end: DateTime(2025, 5, 15, 15, 30),
      );
      invalidSlot = TimeSlot(
        id: 'invalid',
        name: 'Invalid Slot',
        start: DateTime(2025, 6, 1, 9, 0), // Invalid: June (outside May)
        end: DateTime(2025, 6, 1, 10, 0),
      );
    });

    group('constructor', () {
      test('should create schedule with correct year and month', () {
        final schedule = Schedule(monthInput: mayInput);

        expect(schedule.year, equals(2025));
        expect(schedule.month, equals(Month.may));
        expect(schedule.slots, isEmpty);
      });

      test('should create schedule with valid initial slots', () {
        final schedule = Schedule(
          monthInput: mayInput,
          initialSlots: [validSlot1, validSlot2],
        );

        expect(schedule.slots.length, equals(2));
        expect(schedule.slots, contains(validSlot1));
        expect(schedule.slots, contains(validSlot2));
      });

      test('should throw assertion error with invalid slot', () {
        expect(
          () => Schedule(monthInput: mayInput, initialSlots: [invalidSlot]),
          throwsA(isA<AssertionError>()),
        );
      });

      test('should handle December to January transition correctly', () {
        final decemberInput = DateTime(2025, 12, 15);
        final validDecSlot = TimeSlot(
          start: DateTime(2025, 12, 20, 9, 0),
          end: DateTime(2025, 12, 20, 10, 0),
        );

        final schedule = Schedule(
          monthInput: decemberInput,
          initialSlots: [validDecSlot],
        );

        expect(schedule.year, equals(2025));
        expect(schedule.month, equals(Month.december));
        expect(schedule.slots, contains(validDecSlot));
      });
    });

    group('addSlot', () {
      late Schedule schedule;

      setUp(() {
        schedule = Schedule(monthInput: mayInput);
      });

      test('should add valid slot successfully', () {
        schedule.addSlot(validSlot1);

        expect(schedule.slots.length, equals(1));
        expect(schedule.slots, contains(validSlot1));
      });

      test('should throw ArgumentError for slot outside month', () {
        expect(() => schedule.addSlot(invalidSlot), throwsArgumentError);
      });

      test('should throw ArgumentError for overlapping slots', () {
        final overlappingSlot = TimeSlot(
          id: 'overlap',
          name: 'Overlapping',
          start: DateTime(2025, 5, 10, 9, 30), // Overlaps with validSlot1
          end: DateTime(2025, 5, 10, 10, 30),
        );

        schedule.addSlot(validSlot1);

        expect(() => schedule.addSlot(overlappingSlot), throwsArgumentError);
      });

      test('should allow adjacent (non-overlapping) slots', () {
        final adjacentSlot = TimeSlot(
          id: 'adjacent',
          name: 'Adjacent',
          start: DateTime(2025, 5, 10, 10, 0), // Starts when validSlot1 ends
          end: DateTime(2025, 5, 10, 11, 0),
        );

        schedule.addSlot(validSlot1);
        schedule.addSlot(adjacentSlot);

        expect(schedule.slots.length, equals(2));
        expect(schedule.slots, contains(validSlot1));
        expect(schedule.slots, contains(adjacentSlot));
      });
    });

    group('copyWith', () {
      test(
        'should create copy with same values when no parameters provided',
        () {
          final originalSchedule = Schedule(
            monthInput: mayInput,
            initialSlots: [validSlot1],
          );

          final copiedSchedule = originalSchedule.copyWith();

          expect(copiedSchedule.year, equals(originalSchedule.year));
          expect(copiedSchedule.month, equals(originalSchedule.month));
          expect(copiedSchedule.slots, equals(originalSchedule.slots));
          expect(
            copiedSchedule,
            isNot(same(originalSchedule)),
          ); // Different instance
        },
      );

      test('should create copy with new month when monthInput provided', () {
        final originalSchedule = Schedule(monthInput: mayInput);
        final newMonthInput = DateTime(2024, 8, 10); // August 2024

        final copiedSchedule = originalSchedule.copyWith(
          monthInput: newMonthInput,
        );

        expect(copiedSchedule.year, equals(2024));
        expect(copiedSchedule.month, equals(Month.august));
      });

      test('should create copy with new slots when initialSlots provided', () {
        final originalSchedule = Schedule(monthInput: mayInput);
        final newSlots = [validSlot2];

        final copiedSchedule = originalSchedule.copyWith(
          initialSlots: newSlots,
        );

        expect(copiedSchedule.slots, equals(newSlots));
        expect(copiedSchedule.year, equals(originalSchedule.year));
        expect(copiedSchedule.month, equals(originalSchedule.month));
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final schedule = Schedule(
          monthInput: mayInput,
          initialSlots: [validSlot1, validSlot2],
        );

        final json = schedule.toJson();

        expect(json['year'], equals(2025));
        expect(json['month'], equals(5));
        expect(json['slots'], isA<List>());
        expect(json['slots'].length, equals(2));
      });

      test('should deserialize from JSON correctly', () {
        final originalSchedule = Schedule(
          monthInput: mayInput,
          initialSlots: [validSlot1],
        );
        final json = originalSchedule.toJson();

        final deserializedSchedule = Schedule.fromJson(json);

        expect(deserializedSchedule.year, equals(originalSchedule.year));
        expect(deserializedSchedule.month, equals(originalSchedule.month));
        expect(
          deserializedSchedule.slots.length,
          equals(originalSchedule.slots.length),
        );
      });

      test(
        'should maintain data integrity through serialization round-trip',
        () {
          final originalSchedule = Schedule(
            monthInput: mayInput,
            initialSlots: [validSlot1, validSlot2],
          );

          final json = originalSchedule.toJson();
          final deserializedSchedule = Schedule.fromJson(json);

          expect(deserializedSchedule, equals(originalSchedule));
        },
      );
    });

    group('empty factory', () {
      test('should create empty schedule for current month', () {
        final emptySchedule = Schedule.empty;
        final now = DateTime.now();

        expect(emptySchedule.year, equals(now.year));
        expect(emptySchedule.month.monthNumber, equals(now.month));
        expect(emptySchedule.slots, isEmpty);
      });
    });

    group('slots getter', () {
      test('should return unmodifiable list', () {
        final schedule = Schedule(
          monthInput: mayInput,
          initialSlots: [validSlot1],
        );

        final slots = schedule.slots;

        expect(() => slots.add(validSlot2), throwsUnsupportedError);
        expect(() => slots.clear(), throwsUnsupportedError);
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all properties match', () {
        final schedule1 = Schedule(
          monthInput: mayInput,
          initialSlots: [validSlot1],
        );
        final schedule2 = Schedule(
          monthInput: mayInput,
          initialSlots: [validSlot1],
        );

        expect(schedule1, equals(schedule2));
        expect(schedule1.hashCode, equals(schedule2.hashCode));
      });
      test('should not be equal when properties differ', () {
        final schedule1 = Schedule(
          monthInput: mayInput,
          initialSlots: [validSlot1],
        );
        final schedule2 = Schedule(
          monthInput: DateTime(2024, 5, 15), // Different year
          initialSlots: [
            TimeSlot(
              id: 'slot1',
              name: 'Morning Session',
              start: DateTime(2024, 5, 10, 9, 0), // Match the 2024 year
              end: DateTime(2024, 5, 10, 10, 0),
            ),
          ],
        );

        expect(schedule1, isNot(equals(schedule2)));
      });
    });

    group('toString', () {
      test('should return meaningful string representation', () {
        final schedule = Schedule(
          monthInput: mayInput,
          initialSlots: [validSlot1],
        );

        final stringRep = schedule.toString();

        expect(stringRep, contains('Schedule'));
        expect(stringRep, contains('2025'));
        expect(stringRep, contains('may'));
      });
    });

    group('edge cases', () {
      test('should handle slot that spans entire month', () {
        final entireMonthSlot = TimeSlot(
          id: 'entire',
          name: 'Entire Month',
          start: DateTime(2025, 5, 1, 0, 0),
          end: DateTime(2025, 5, 31, 23, 59),
        );

        final schedule = Schedule(
          monthInput: mayInput,
          initialSlots: [entireMonthSlot],
        );

        expect(schedule.slots, contains(entireMonthSlot));
      });

      test('should handle slot at exact month boundary', () {
        final boundarySlot = TimeSlot(
          id: 'boundary',
          name: 'Boundary',
          start: DateTime(2025, 5, 1, 0, 0), // Exact start of month
          end: DateTime(2025, 5, 1, 1, 0),
        );

        final schedule = Schedule(
          monthInput: mayInput,
          initialSlots: [boundarySlot],
        );

        expect(schedule.slots, contains(boundarySlot));
      });

      test('should reject slot that starts before month', () {
        final earlySlot = TimeSlot(
          start: DateTime(2025, 4, 30, 23, 0), // April 30th
          end: DateTime(2025, 5, 1, 1, 0),
        );

        expect(
          () => Schedule(monthInput: mayInput, initialSlots: [earlySlot]),
          throwsA(isA<AssertionError>()),
        );
      });

      test('should reject slot that ends after month', () {
        final lateSlot = TimeSlot(
          start: DateTime(2025, 5, 31, 23, 0),
          end: DateTime(2025, 6, 1, 1, 0), // June 1st
        );

        expect(
          () => Schedule(monthInput: mayInput, initialSlots: [lateSlot]),
          throwsA(isA<AssertionError>()),
        );
      });
    });
  });
}
