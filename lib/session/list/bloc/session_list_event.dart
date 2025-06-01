part of 'session_list_bloc.dart';

/// Base class for all session list events.
///
/// Extend this class to define events that can be dispatched to the SessionListBloc.
sealed class SessionListEvent extends Equatable {
  /// Creates a new [SessionListEvent].
  const SessionListEvent();

  @override
  List<Object> get props => [];
}

/// Event to request a subscription to the session list stream.
///
/// Typically dispatched when the session list should start listening for updates.
final class SessionListSubscriptionRequested extends SessionListEvent {
  /// Creates a new [SessionListSubscriptionRequested] event.
  const SessionListSubscriptionRequested();
}

/// Event to change the filter applied to the session list.
///
/// [filter] is the new filter to apply to the session list.
final class SessionListFilterChanged extends SessionListEvent {
  /// Creates a new [SessionListFilterChanged] event with the given [filter].
  const SessionListFilterChanged(this.filter);

  /// The new filter to apply to the session list.
  final SessionListFilter filter;

  @override
  List<Object> get props => [filter];
}
