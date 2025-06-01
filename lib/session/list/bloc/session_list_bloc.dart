import 'package:app/core/core.dart';
import 'package:app/core/models/session.dart';
import 'package:app/core/repositories/session_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'session_list_event.dart';
part 'session_list_state.dart';

/// BLoC for managing the state and events of the session list.
///
/// Handles subscription to the session list and applying filters. Responds to
/// [SessionListSubscriptionRequested] and [SessionListFilterChanged] events.
class SessionListBloc extends Bloc<SessionListEvent, SessionListState> {
  final SessionRepository _sessionRepository;

  /// Creates a new [SessionListBloc] with the initial state.
  ///
  /// Registers event handlers for subscription requests and filter changes.
  SessionListBloc({SessionRepository? sessionRepository})
    : _sessionRepository = sessionRepository ?? SessionRepository(),
      super(const SessionListState()) {
    on<SessionListSubscriptionRequested>(_onSubscriptionRequested);
    on<SessionListFilterChanged>(_onFilterChanged);
  }

  /// Handles [SessionListSubscriptionRequested] events.
  ///
  /// This method should implement logic to subscribe to the session list stream
  /// and emit new states as sessions are loaded or updated.
  Future<void> _onSubscriptionRequested(
    SessionListSubscriptionRequested event,
    Emitter<SessionListState> emit,
  ) async {
    emit(state.copyWith(status: SessionListStatus.loading));
    await emit.forEach<List<Session>>(
      _sessionRepository.getSessions(),
      onData: (sessions) =>
          state.copyWith(status: SessionListStatus.success, sessions: sessions),
      onError: (_, __) => state.copyWith(status: SessionListStatus.failure),
    );
  }

  /// Handles [SessionListFilterChanged] events.
  ///
  /// This method should implement logic to update the session list filter and
  /// emit the filtered session list state.
  Future<void> _onFilterChanged(
    SessionListFilterChanged event,
    Emitter<SessionListState> emit,
  ) async {
    emit(state.copyWith(filter: event.filter));
  }
}
