part of 'session_detail_bloc.dart';

/// Base class for all states in the [SessionDetailBloc].
sealed class SessionDetailState extends Equatable {
  /// Default constructor for [SessionDetailState].
  const SessionDetailState();

  @override
  List<Object?> get props => [];
}

/// Represents the initial state of the session detail view.
final class SessionDetailInitial extends SessionDetailState {
  /// Default constructor for [SessionDetailInitial].
  const SessionDetailInitial();
}

/// Represents the loading state when fetching session details.
final class SessionDetailLoading extends SessionDetailState {
  /// Default constructor for [SessionDetailLoading].
  const SessionDetailLoading();
}

/// Represents the state when session details are successfully loaded.
final class SessionDetailLoaded extends SessionDetailState {
  /// Creates a [SessionDetailLoaded] state.
  const SessionDetailLoaded({required this.session});

  /// The loaded session data.
  final core.Session session;

  @override
  List<Object?> get props => [session];
}

/// Represents the error state when loading session details fails.
final class SessionDetailError extends SessionDetailState {
  /// Creates a [SessionDetailError] state.
  const SessionDetailError({required this.error});

  /// The error message.
  final String error;

  @override
  List<Object?> get props => [error];
}
