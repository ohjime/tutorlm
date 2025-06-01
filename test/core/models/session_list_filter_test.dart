import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/models/session_list_filter.dart';
import 'package:app/core/core.dart' as core;

void main() {
  group('SessionListFilter', () {
    test('empty filter equality', () {
      expect(SessionListFilter.empty, equals(SessionListFilter()));
    });

    test(
      'filters are equal if all fields match (order-insensitive for lists, date only to day)',
      () {
        final date1 = DateTime(2025, 5, 27, 10, 30);
        final date2 = DateTime(2025, 5, 27, 23, 59, 59);
        final f1 = SessionListFilter(
          selectedDate: date1,
          statuses: {
            core.SessionStatus.completed,
            core.SessionStatus.scheduled,
          },
          searchStrings: {'abc', 'def'},
        );
        final f2 = SessionListFilter(
          selectedDate: date2,
          statuses: {
            core.SessionStatus.scheduled,
            core.SessionStatus.completed,
          },
          searchStrings: {'def', 'abc'},
        );
        // This will fail with the current implementation, as props does not normalize date or sort lists.
        // This test is here to show the intended behavior.
        expect(
          f1,
          equals(f2),
          reason:
              'Should be equal if date is same day and lists have same elements',
        );
      },
    );

    test('filters are not equal if any field differs', () {
      final date = DateTime(2025, 5, 27);
      final f1 = SessionListFilter(
        selectedDate: date,
        statuses: {core.SessionStatus.completed},
        searchStrings: {'abc'},
      );
      final f2 = SessionListFilter(
        selectedDate: date,
        statuses: {core.SessionStatus.scheduled},
        searchStrings: {'abc'},
      );
      final f3 = SessionListFilter(
        selectedDate: date,
        statuses: {core.SessionStatus.completed},
        searchStrings: {'xyz'},
      );
      final f4 = SessionListFilter(
        selectedDate: DateTime(2025, 5, 28),
        statuses: {core.SessionStatus.completed},
        searchStrings: {'abc'},
      );
      expect(f1 == f2, isFalse);
      expect(f1 == f3, isFalse);
      expect(f1 == f4, isFalse);
    });
  });
}
