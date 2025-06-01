import 'package:app/core/core.dart' as core;
import 'package:app/core/repositories/repositories.dart';
import 'package:app/core/repositories/tutor_repository.dart';
import 'package:app/core/repositories/user_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'session_create_event.dart';
part 'session_create_state.dart';

class SessionCreateBloc extends Bloc<SessionCreateEvent, SessionCreateState> {
  SessionCreateBloc(
    TutorRepository? tutorRepository,
    UserRepository? userRepository,
    SessionRepository? sessionRepository,
  ) : _tutorRepository = tutorRepository ?? TutorRepository(),
      _userRepository = userRepository ?? UserRepository(),
      _sessionRepository = sessionRepository ?? SessionRepository(),
      super(const Initial()) {
    on<Start>(_onStart);
    on<ChangeTutor>(_onChangeTutor);
    on<SelectSession>(_onSelectSession);
    on<ProvideDetails>(_onProvideDetails);
    on<Submit>(_onSubmit);
    on<Back>(_onBack);
  }
  final TutorRepository _tutorRepository;
  final UserRepository _userRepository;
  final SessionRepository _sessionRepository;

  void _onStart(Start event, Emitter<SessionCreateState> emit) async {
    if (state is LoadingTutorsError) {
      emit(const Initial());
    }
    if (state is Initial) {
      emit(const LoadingTutors());
      await Future.delayed(const Duration(milliseconds: 300));
      try {
        final tutors = await _tutorRepository.getTutors();
        final tutorData = <String, Map<String, dynamic>>{};
        for (var tutor in tutors) {
          final user = await _userRepository.getUser(tutor.uid);
          print(user.schedule);
          tutorData[tutor.uid] = {'tutor': tutor, 'user': user};
        }
        emit(
          SessionsLoaded(
            tutorData: tutorData,
            selectedTutor: tutorData.values.first['tutor'] as core.Tutor,
            selectedUser: tutorData.values.first['user'] as core.User,
          ),
        );
      } catch (e) {
        emit(LoadingTutorsError(errorMessage: e.toString()));
      }
    }
  }

  void _onChangeTutor(ChangeTutor event, Emitter<SessionCreateState> emit) {
    if ((state as SessionsLoaded).tutorData[event.selectedTutorUid] != null) {
      emit(
        (state as SessionsLoaded).copyWith(
          selectedTutor:
              (state as SessionsLoaded).tutorData[event
                      .selectedTutorUid]!['tutor']
                  as core.Tutor,
          selectedUser:
              (state as SessionsLoaded).tutorData[event
                      .selectedTutorUid]!['user']
                  as core.User,
        ),
      );
    }
  }

  void _onSelectSession(SelectSession event, Emitter<SessionCreateState> emit) {
    emit(
      ProvidingDetails(
        session: core.Session(
          id: '',
          status: core.SessionStatus.scheduled,
          studentId: event.studentUid,
          tutorId: event.tutorUid,
          timeslot: event.timeSlot,
        ),
      ),
    );
  }

  void _onProvideDetails(
    ProvideDetails event,
    Emitter<SessionCreateState> emit,
  ) {
    emit(UnSubmitted(session: event.session));
  }

  void _onSubmit(Submit event, Emitter<SessionCreateState> emit) {
    emit(Submitting(session: event.session));
    try {
      _sessionRepository.create(event.session);
      emit(Success());
    } catch (e) {
      emit(
        SubmissionError(
          errorMessage: 'Booking Failed: $e',
          session: event.session,
        ),
      );
    }
  }

  void _onBack(Back event, Emitter<SessionCreateState> emit) {
    switch (state) {
      case SessionReviewState():
        emit(ProvidingDetails(session: (state as SessionReviewState).session));
        break;
      case SessionDetailsState():
        emit(LoadingTutors());
        break;
      case SelectSessionState():
        emit(Initial());
        break;
    }
  }
}
