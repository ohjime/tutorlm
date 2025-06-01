import 'package:app/core/core.dart' as core;
import 'package:app/core/models/session.dart';
import 'package:equatable/equatable.dart';

/// SessionListFilter should be composed of 3 things:
/// - List<[SessionStatus]> statuses
/// - DateTime selectedDate
/// - List<[String]> searchStrings
/// SessionListFilter can be empty using SessionListFilter.empty
/// Two different SessionListFilter should be equal iff:
/// - their selectedDates are equal up to the month, day and year.
/// - Their list of statuses contain the same elements (order does not matter)
/// - Their list of searchStrings contain the same elements (order does not matter)
/// Notes that SessionListStatus is an enum, and SessionListFilter is a class so SessionListFilter should extend equatable if it will help make the comparison easier.
class SessionListFilter extends Equatable {
  const SessionListFilter({
    this.selectedDate,
    this.statuses = const {},
    this.searchStrings = const {},
  });

  final DateTime? selectedDate;
  final Set<core.SessionStatus> statuses;
  final Set<String> searchStrings;

  static const empty = SessionListFilter();

  @override
  List<Object?> get props => [
    selectedDate == null
        ? null
        : DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day),
    statuses,
    searchStrings,
  ];

  /// Filters the given list of Session objects according to the filter's criteria.
  Iterable<Session> apply(Iterable<Session> sessions) {
    return sessions.where((session) {
      // Status filter
      if (statuses.isNotEmpty && !statuses.contains(session.status)) {
        return false;
      }
      if (session.timeslot == null) {
        // If the session has no timeslot, we can't filter by date
        return false;
      }
      // Date filter (compare only year, month, day)
      if (selectedDate != null) {
        final sessionDate = session.timeslot!.start;
        if (sessionDate.year != selectedDate!.year ||
            sessionDate.month != selectedDate!.month ||
            sessionDate.day != selectedDate!.day) {
          return false;
        }
      }
      // Search string filter (all searchStrings must be present)
      if (searchStrings.isNotEmpty) {
        // We'll use the session id as a fallback for search, or you can add more fields
        final searchTarget = session.id.toLowerCase();
        for (final s in searchStrings) {
          if (!searchTarget.contains(s.toLowerCase())) {
            return false;
          }
        }
      }
      return true;
    });
  }
}
