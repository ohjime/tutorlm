part of 'settings_cubit.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();

  @override
  List<Object?> get props => [];
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();

  @override
  List<Object?> get props => [];
}

class SettingsLoaded extends SettingsState {
  const SettingsLoaded({
    required this.user,
    this.tutor,
    this.student,
    this.selectedOption,
  });

  final User user;
  final Tutor? tutor;
  final Student? student;
  final String? selectedOption;

  SettingsLoaded copyWith({
    User? user,
    Tutor? tutor,
    Student? student,
    String? selectedOption,
  }) {
    return SettingsLoaded(
      user: user ?? this.user,
      tutor: tutor ?? this.tutor,
      student: student ?? this.student,
      selectedOption: selectedOption ?? this.selectedOption,
    );
  }

  @override
  List<Object?> get props => [user, tutor, student, selectedOption];
}

class SettingsError extends SettingsState {
  const SettingsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
