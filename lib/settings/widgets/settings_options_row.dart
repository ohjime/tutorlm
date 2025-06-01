import 'package:app/app/app.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/core/core.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class SettingsOptionsRow extends StatelessWidget {
  const SettingsOptionsRow({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const SizedBox.shrink();
        }

        return FutureBuilder<User>(
          future: context.read<UserRepository>().getUser(state.credential.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox.shrink();
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const SizedBox(
                height: 30,
                child: DelayedDisplay(
                  delay: Duration(milliseconds: 100),
                  slidingBeginOffset: Offset(0.0, 0.2),
                  fadingDuration: Duration(milliseconds: 200),
                  child: Center(child: Text('Error loading settings options')),
                ),
              );
            }

            final user = snapshot.data!;
            final settingsOptions = _getSettingsOptions(context, user);

            return Theme(
              data: Theme.of(context).copyWith(
                iconTheme: IconThemeData(color: color),
                cardColor: Colors.transparent,
                textTheme: Theme.of(context).textTheme.copyWith(
                  bodyMedium: TextStyle(color: color.withValues(alpha: 0.7)),
                ),
              ),
              child: DelayedDisplay(
                delay: const Duration(milliseconds: 100),
                slidingBeginOffset: const Offset(0.0, 0.2),
                fadingDuration: const Duration(milliseconds: 200),
                child: SizedBox(
                  height: 30,
                  child: AnimationLimiter(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      itemCount: settingsOptions.length,
                      itemBuilder: (context, index) {
                        final option = settingsOptions[index];
                        return AnimationConfiguration.staggeredList(
                          delay: Duration(milliseconds: index * 50),
                          position: index,
                          duration: const Duration(milliseconds: 300),
                          child: SlideAnimation(
                            horizontalOffset: 40,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => option.onTap(context),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 100,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.03,
                                          ),
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(option.icon, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          option.title,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<SettingsOption> _getSettingsOptions(BuildContext context, User user) {
    final List<SettingsOption> options = [
      // Common options for all users
      SettingsOption(
        title: 'Personal Info',
        icon: Icons.person,
        onTap: (context) => _showPersonalInfoDialog(context),
      ),
      SettingsOption(
        title: 'Account',
        icon: Icons.account_circle,
        onTap: (context) => _showAccountDialog(context),
      ),
      SettingsOption(
        title: 'Schedule',
        icon: Icons.schedule,
        onTap: (context) => _showScheduleDialog(context),
      ),
    ];

    // Add role-specific options
    if (user.role == UserRole.tutor) {
      options.addAll([
        SettingsOption(
          title: 'Credentials',
          icon: Icons.school,
          onTap: (context) => _showCredentialsDialog(context),
        ),
        SettingsOption(
          title: 'Courses',
          icon: Icons.book,
          onTap: (context) => _showCoursesDialog(context),
        ),
        SettingsOption(
          title: 'Tutor Status',
          icon: Icons.verified,
          onTap: (context) => _showTutorStatusDialog(context),
        ),
      ]);
    } else if (user.role == UserRole.student) {
      options.addAll([
        SettingsOption(
          title: 'Education',
          icon: Icons.school,
          onTap: (context) => _showEducationDialog(context),
        ),
        SettingsOption(
          title: 'Subjects',
          icon: Icons.book,
          onTap: (context) => _showSubjectsDialog(context),
        ),
      ]);
    }

    options.add(
      SettingsOption(
        title: 'App Settings',
        icon: Icons.settings,
        onTap: (context) => _showAppSettingsDialog(context),
      ),
    );

    return options;
  }

  void _showPersonalInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Personal Information'),
        content: const Text(
          'This will open personal information settings where you can edit your name, profile picture, and bio.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Settings'),
        content: const Text(
          'This will open account settings where you can manage your email, password, and account preferences.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Settings'),
        content: const Text(
          'This will open schedule settings where you can update your availability.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCredentialsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Academic Credentials'),
        content: const Text(
          'This will open credentials management where you can add, edit, or remove your academic credentials.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCoursesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Courses & Subjects'),
        content: const Text(
          'This will open course management where you can update the subjects and grades you teach.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTutorStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tutor Status'),
        content: const Text(
          'This will open tutor status settings where you can manage your availability for new students.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEducationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Education Information'),
        content: const Text(
          'This will open education settings where you can update your school and grade level.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSubjectsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subjects of Interest'),
        content: const Text(
          'This will open subject settings where you can update the subjects you need help with.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAppSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Settings'),
        content: const Text(
          'This will open general app settings including notifications, privacy, and logout options.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class SettingsOption {
  final String title;
  final IconData icon;
  final void Function(BuildContext context) onTap;

  SettingsOption({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}
