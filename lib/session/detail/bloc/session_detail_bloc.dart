import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:app/core/core.dart' as core;

part 'session_detail_event.dart';
part 'session_detail_state.dart';

/// Bloc that manages the state of session detail view
class SessionDetailBloc extends Bloc<SessionDetailEvent, SessionDetailState> {
  /// Creates an instance of [SessionDetailBloc].
  /// Requires a [sessionRepository] to fetch session data.
  SessionDetailBloc({required core.SessionRepository sessionRepository})
    : _sessionRepository = sessionRepository,
      super(SessionDetailInitial()) {
    on<SessionDetailRequested>(_onSessionDetailRequested);
    on<SessionDetailRefreshRequested>(_onSessionDetailRefreshRequested);
  }

  /// Repository for managing session-related operations.
  final core.SessionRepository _sessionRepository;

  /// Handles the [SessionDetailRequested] event.
  ///
  /// Fetches session details by sessionId and emits appropriate states.
  Future<void> _onSessionDetailRequested(
    SessionDetailRequested event,
    Emitter<SessionDetailState> emit,
  ) async {
    emit(SessionDetailLoading());

    try {
      final session = await _sessionRepository.getSessionById(event.sessionId);

      if (session != null) {
        emit(SessionDetailLoaded(session: session));
      } else {
        emit(SessionDetailError(error: 'Session not found'));
      }
    } catch (e) {
      emit(SessionDetailError(error: e.toString()));
    }
  }

  /// Handles the [SessionDetailRefreshRequested] event.
  ///
  /// Refreshes session details by sessionId.
  Future<void> _onSessionDetailRefreshRequested(
    SessionDetailRefreshRequested event,
    Emitter<SessionDetailState> emit,
  ) async {
    // Don't show loading state for refresh, just update the data
    try {
      final session = await _sessionRepository.getSessionById(event.sessionId);

      if (session != null) {
        emit(SessionDetailLoaded(session: session));
      } else {
        emit(SessionDetailError(error: 'Session not found'));
      }
    } catch (e) {
      emit(SessionDetailError(error: e.toString()));
    }
  }
}
