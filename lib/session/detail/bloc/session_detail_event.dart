part of 'session_detail_bloc.dart';

/// Base class for all events in the [SessionDetailBloc].
sealed class SessionDetailEvent extends Equatable {
  /// Default constructor for [SessionDetailEvent].
  const SessionDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Event to request session details for a specific session ID.
final class SessionDetailRequested extends SessionDetailEvent {
  /// Creates a [SessionDetailRequested] event.
  const SessionDetailRequested({required this.sessionId});

  /// The ID of the session to fetch details for.
  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}

/// Event to refresh session details for a specific session ID.
final class SessionDetailRefreshRequested extends SessionDetailEvent {
  /// Creates a [SessionDetailRefreshRequested] event.
  const SessionDetailRefreshRequested({required this.sessionId});

  /// The ID of the session to refresh details for.
  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}
