# Settings Cubit

The `SettingsCubit` manages user settings and loads the current authenticated user's data along with their role-specific information (tutor or student data).

## Usage

### Basic Setup

To use the `SettingsCubit`, you need to provide it with the required repositories:

```dart
// In your widget where you want to provide the SettingsCubit
BlocProvider(
  create: (context) => SettingsCubit(
    authenticationRepository: context.read<AuthenticationRepository>(),
    userRepository: context.read<UserRepository>(),
    tutorRepository: context.read<TutorRepository>(),
    studentRepository: context.read<StudentRepository>(),
  )..loadSettings(), // Call loadSettings() immediately to load user data
  child: YourWidget(),
)
```

### Loading User Data

The cubit automatically loads user data when `loadSettings()` is called. This method:

1. Gets the current authenticated user's credential
2. Fetches the user data from Firestore
3. Based on the user's role, fetches either tutor or student specific data
4. Emits a `SettingsLoaded` state with all the data

### Listening to States

```dart
BlocBuilder<SettingsCubit, SettingsState>(
  builder: (context, state) {
    if (state is SettingsLoading) {
      return const CircularProgressIndicator();
    } else if (state is SettingsLoaded) {
      final user = state.user;
      final tutor = state.tutor; // Will be null if user is not a tutor
      final student = state.student; // Will be null if user is not a student
      
      return Column(
        children: [
          Text('Welcome ${user.name}'),
          Text('Email: ${user.email}'),
          Text('Role: ${user.role.name}'),
          if (tutor != null) ...[
            Text('Tutor Bio: ${tutor.bio}'),
            Text('Tutor Headline: ${tutor.headline}'),
          ],
          if (student != null) ...[
            Text('Student Bio: ${student.bio}'),
            Text('Grade Level: ${student.gradeLevel.name}'),
          ],
        ],
      );
    } else if (state is SettingsError) {
      return Text('Error: ${state.message}');
    } else {
      return const Text('Settings not loaded');
    }
  },
)
```

### Available Methods

- `loadSettings()`: Load user data and role-specific information
- `refreshUserData()`: Reload all user data (alias for loadSettings)
- `selectOption(String option)`: Update the selected option while preserving loaded data

### State Types

- `SettingsInitial`: Initial state before any data is loaded
- `SettingsLoading`: State while loading user data
- `SettingsLoaded`: State when data is successfully loaded
  - Contains `user`, `tutor?`, `student?`, and `selectedOption?`
- `SettingsError`: State when an error occurs during loading

## Example Integration

Here's how you might integrate this into a settings page:

```dart
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(
        authenticationRepository: context.read<AuthenticationRepository>(),
        userRepository: context.read<UserRepository>(),
        tutorRepository: context.read<TutorRepository>(),
        studentRepository: context.read<StudentRepository>(),
      )..loadSettings(),
      child: SettingsView(),
    );
  }
}

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SettingsLoaded) {
            return SettingsContent(
              user: state.user,
              tutor: state.tutor,
              student: state.student,
            );
          } else if (state is SettingsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  ElevatedButton(
                    onPressed: () => context.read<SettingsCubit>().refreshUserData(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

## Notes

- The cubit requires all four repositories to be provided
- User data is loaded based on the current authenticated credential
- Role-specific data (tutor/student) is only loaded if the user has that role
- The cubit handles error states gracefully and provides meaningful error messages
- All data loading is asynchronous and the UI can respond to loading states appropriately
