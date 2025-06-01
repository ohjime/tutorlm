part of 'session_create_bloc.dart';

abstract class SessionCreateState extends Equatable {
  final int currentStep;
  const SessionCreateState({this.currentStep = 0});

  @override
  List<Object?> get props => [currentStep];
}

abstract class InitialState extends SessionCreateState {
  const InitialState() : super(currentStep: 0);
}

abstract class SelectSessionState extends SessionCreateState {
  final Map<String, Map<String, dynamic>> tutorData;
  const SelectSessionState({this.tutorData = const {}}) : super(currentStep: 1);
  @override
  List<Object?> get props => [tutorData];
}

abstract class SessionDetailsState extends SessionCreateState {
  final core.Session session;
  const SessionDetailsState({required this.session}) : super(currentStep: 2);

  @override
  List<Object?> get props => [session];
}

abstract class SessionReviewState extends SessionCreateState {
  final core.Session session;
  const SessionReviewState({required this.session}) : super(currentStep: 3);

  @override
  List<Object?> get props => [session];
}

abstract class SubmissionSuccess extends SessionCreateState {
  const SubmissionSuccess();
}

class Initial extends InitialState {
  const Initial();
}

class LoadingTutors extends SelectSessionState {
  const LoadingTutors();
}

class LoadingTutorsError extends SelectSessionState {
  final String errorMessage;
  const LoadingTutorsError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class SessionsLoaded extends SelectSessionState {
  final Map<String, Map<String, dynamic>> tutorData;
  final core.Tutor selectedTutor;
  final core.User selectedUser;
  const SessionsLoaded({
    this.tutorData = const {},
    required this.selectedTutor,
    required this.selectedUser,
  });

  @override
  List<Object?> get props => [selectedTutor, selectedUser, tutorData];

  SessionsLoaded copyWith({
    Map<String, Map<String, dynamic>>? tutorData,
    core.Tutor? selectedTutor,
    core.User? selectedUser,
  }) {
    return SessionsLoaded(
      tutorData: tutorData ?? this.tutorData,
      selectedTutor: selectedTutor ?? this.selectedTutor,
      selectedUser: selectedUser ?? this.selectedUser,
    );
  }
}

class ProvidingDetails extends SessionDetailsState {
  const ProvidingDetails({required super.session});
}

class UnSubmitted extends SessionReviewState {
  const UnSubmitted({required super.session});
}

class Submitting extends SessionReviewState {
  const Submitting({required super.session});
}

class SubmissionError extends SessionReviewState {
  final String errorMessage;
  const SubmissionError({required this.errorMessage, required super.session});

  @override
  List<Object?> get props => [errorMessage];
}

class Success extends SessionCreateState {
  const Success({super.currentStep = 4});
  @override
  List<Object?> get props => [currentStep];
}
