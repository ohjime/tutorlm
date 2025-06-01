part of 'session_list_bloc.dart';

/// Represents the possible statuses for the session list state.
///
/// - [initial]: The initial state before any action has been taken.
/// - [loading]: Indicates that the session list is currently being loaded.
/// - [success]: Indicates that the session list has been successfully loaded.
/// - [failure]: Indicates that loading the session list has failed.
enum SessionListStatus { initial, loading, success, failure }

/// State for the session list BLoC.
///
/// Holds the current status, the list of sessions, and the applied filter.
final class SessionListState extends Equatable {
  /// Creates a new [SessionListState].
  ///
  /// [status] is the current status of the session list (default: [SessionListStatus.initial]).
  /// [sessions] is the list of sessions (default: empty list).
  /// [filter] is the filter applied to the session list (default: [SessionListFilter.empty]).
  const SessionListState({
    this.status = SessionListStatus.initial,
    this.sessions = const [],
    this.filter = SessionListFilter.empty,
  });

  /// The current status of the session list.
  final SessionListStatus status;

  /// The list of sessions currently in the state.
  final List<Session> sessions;

  /// The filter applied to the session list.
  final SessionListFilter filter;

  /// Returns the filtered list of sessions based on the current filter.
  List<Session> get filteredSessions {
    if (filter == SessionListFilter.empty) {
      return sessions;
    }
    return filter.apply(sessions).toList();
  }

  @override
  List<Object> get props => [status, sessions, filter];

  /// Returns a copy of this state with the given fields replaced by new values.
  ///
  /// [status]: The new status (optional).
  /// [sessions]: The new list of sessions (optional).
  /// [filter]: The new filter (optional).
  SessionListState copyWith({
    SessionListStatus? status,
    List<Session>? sessions,
    SessionListFilter? filter,
  }) {
    return SessionListState(
      status: status ?? this.status,
      sessions: sessions ?? this.sessions,
      filter: filter ?? this.filter,
    );
  }
}
