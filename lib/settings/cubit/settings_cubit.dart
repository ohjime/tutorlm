import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:app/core/core.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required AuthenticationRepository authenticationRepository,
    required UserRepository userRepository,
    required TutorRepository tutorRepository,
    required StudentRepository studentRepository,
  }) : _authenticationRepository = authenticationRepository,
       _userRepository = userRepository,
       _tutorRepository = tutorRepository,
       _studentRepository = studentRepository,
       super(const SettingsInitial());

  final AuthenticationRepository _authenticationRepository;
  final UserRepository _userRepository;
  final TutorRepository _tutorRepository;
  final StudentRepository _studentRepository;

  /// Load user data and role-specific information on initialization
  Future<void> loadSettings() async {
    emit(const SettingsLoading());

    try {
      // Get current user credential
      final credential = _authenticationRepository.currentCredential;
      if (credential.isEmpty) {
        emit(const SettingsError('No authenticated user found'));
        return;
      }

      // Get user data
      final user = await _userRepository.getUser(credential.id);
      if (user.isEmpty) {
        emit(const SettingsError('User data not found'));
        return;
      }

      // Load role-specific data based on user role
      Tutor? tutor;
      Student? student;

      if (user.role == UserRole.tutor) {
        tutor = await _tutorRepository.getTutor(credential.id);
      } else if (user.role == UserRole.student) {
        student = await _studentRepository.getStudent(credential.id);
      }

      emit(SettingsLoaded(user: user, tutor: tutor, student: student));
    } catch (e) {
      emit(SettingsError('Failed to load settings: ${e.toString()}'));
    }
  }

  /// Update selected option while preserving loaded data
  void selectOption(String option) {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      emit(currentState.copyWith(selectedOption: option));
    }
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    await loadSettings();
  }
}
