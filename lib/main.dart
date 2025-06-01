import 'package:app/home/home.dart';
import 'package:app/session/session.dart';
import 'package:app/chat/exports.dart';
import 'package:app/settings/settings.dart';
import 'package:chiclet/chiclet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app/firebase_options.dart';
import 'package:app/core/core.dart';
import 'package:app/app/app.dart';
import 'package:app/login/login.dart';
import 'package:app/signup/signup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize the Bloc Observer for our Application
  // Bloc.observer = CoreObserver();

  // Initialize Authentication Repository and wait for the first user's credentials
  // to be emitted.
  final authenticationRepository = AuthenticationRepository();
  await authenticationRepository.credential.first;

  // Initialize User Repository
  final userRepository = UserRepository();

  // Initialize Session Repository
  final sessionRepository = SessionRepository();

  // Initialize Chat Repository
  final chatRepository = ChatRepository();

  // Initialize the Tutor Repository
  final tutorRepository = TutorRepository();

  // Initialize the student repository
  final studentRepository = StudentRepository();

  runApp(
    App(
      authenticationRepository: authenticationRepository,
      userRepository: userRepository,
      sessionRepository: sessionRepository,
      chatRepository: chatRepository,
      tutorRepository: tutorRepository,
      studentRepository: studentRepository,
    ),
  );
}

class App extends StatelessWidget {
  const App({
    required AuthenticationRepository authenticationRepository,
    required UserRepository userRepository,
    required SessionRepository sessionRepository,
    required ChatRepository chatRepository,
    required TutorRepository tutorRepository,
    required StudentRepository studentRepository,
    super.key,
  }) : _authenticationRepository = authenticationRepository,
       _userRepository = userRepository,
       _sessionRepository = sessionRepository,
       _chatRepository = chatRepository,
       _tutorRepository = tutorRepository,
       _studentRepository = studentRepository;

  final AuthenticationRepository _authenticationRepository;
  final UserRepository _userRepository;
  final SessionRepository _sessionRepository;
  final ChatRepository _chatRepository;
  final TutorRepository _tutorRepository;
  final StudentRepository _studentRepository;
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case '/welcome':
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case '/session_detail':
        final sessionId = settings.arguments as String?;
        if (sessionId == null) {
          return null; // Invalid route if no session ID provided
        }
        return MaterialPageRoute(
          builder: (_) => SessionDetailPage(sessionId: sessionId),
        );
      case '/home':
        return MaterialPageRoute(
          builder: (_) => HomePage(
            tabs: [
              HomeTab(
                tabBody: SessionListView(),
                tabTitle: 'Sessions',
                tabAction: (context) => ChicletAnimatedButton(
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    showModalBottomSheet(
                      useSafeArea: true,
                      isScrollControlled: true,

                      enableDrag: false,
                      context: context,
                      builder: (context) => const SessionCreateModal(),
                    );
                  },
                  height: 28,
                  width: 130,
                  borderRadius: 10,
                  buttonHeight: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, size: 14),
                      const SizedBox(width: 4),
                      Text('New Session'),
                    ],
                  ),
                ),
                tabIcon: Icon(Icons.list),
              ),
              HomeTab(
                tabBody: MessagesPage(),
                tabTitle: 'Message',
                tabAction: (context) => ChicletAnimatedButton(
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    await Future.delayed(const Duration(milliseconds: 60));
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => NewChatPage()),
                    );
                  },
                  height: 28,
                  width: 130,
                  borderRadius: 10,
                  buttonHeight: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, size: 14),
                      const SizedBox(width: 4),
                      Text('New Message'),
                    ],
                  ),
                ),
                tabIcon: Icon(Icons.message),
              ),
            ],
          ),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDark = brightness == Brightness.dark;
    final colorScheme = isDark ? darkTheme.colorScheme : lightTheme.colorScheme;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: colorScheme.primary,
        systemNavigationBarColor: colorScheme.surface,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authenticationRepository),
        RepositoryProvider.value(value: _userRepository),
        RepositoryProvider.value(value: _sessionRepository),
        RepositoryProvider.value(value: _chatRepository),
        RepositoryProvider.value(value: _tutorRepository),
        RepositoryProvider.value(value: _studentRepository),
      ],
      child: AppView(onGenerateRoute: _onGenerateRoute),
    );
  }
}
