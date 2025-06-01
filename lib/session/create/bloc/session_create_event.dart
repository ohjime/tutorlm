part of 'session_create_bloc.dart';

abstract class SessionCreateEvent extends Equatable {
  const SessionCreateEvent();

  @override
  List<Object?> get props => [];
}

class Start extends SessionCreateEvent {
  const Start();

  get tutorRepository => null;
}

class ChangeTutor extends SessionCreateEvent {
  final String selectedTutorUid;
  const ChangeTutor(this.selectedTutorUid);

  @override
  List<Object?> get props => [selectedTutorUid];
}

class SelectSession extends SessionCreateEvent {
  final String studentUid;
  final String tutorUid;
  final core.TimeSlot timeSlot;
  const SelectSession({
    required this.studentUid,
    required this.timeSlot,
    required this.tutorUid,
  });

  @override
  List<Object?> get props => [studentUid, timeSlot, tutorUid];
}

class ProvideDetails extends SessionCreateEvent {
  final core.Session session;
  const ProvideDetails(this.session);

  @override
  List<Object?> get props => [session];
}

class Submit extends SessionCreateEvent {
  final core.Session session;
  const Submit(this.session);

  @override
  List<Object?> get props => [session];
}

class Back extends SessionCreateEvent {
  final String? selectedTutorUid;
  final core.TimeSlot? selectedTimeSlot;

  const Back({this.selectedTutorUid, this.selectedTimeSlot});
}
