// A simple menu screen widget
import 'package:app/app/app.dart';
import 'package:app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:random_avatar/random_avatar.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Get user from AppBloc
    final credential = context.select<AppBloc, AuthCredential>((bloc) {
      final state = bloc.state;
      if (state is Authenticated) {
        return state.credential;
      } else {
        return AuthCredential.empty;
      }
    });
    final user = context.read<UserRepository>().getUser(credential.id);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 26, top: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/shared/logo.png',
                height: 80,
                width: 80,
              ),
              Text(
                'TutorLM',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 40,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.start,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Divider(
                height: 26,
                indent: 5,
                thickness: 3,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              FutureBuilder(
                future: user,
                initialData: User.empty,
                builder: (context, asyncSnapshot) {
                  return Card(
                    margin: const EdgeInsets.only(left: 8),
                    color: Theme.of(context).colorScheme.surfaceBright,
                    child: ListTile(
                      leading:
                          asyncSnapshot.data?.imageUrl != null &&
                              asyncSnapshot.data!.imageUrl!.isNotEmpty
                          ? CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage(
                                asyncSnapshot.data!.imageUrl!,
                              ),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                            )
                          : CircleAvatar(
                              radius: 28,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              child: RandomAvatar(
                                asyncSnapshot.data?.name ?? 'guest',
                                height: 50,
                              ),
                            ),
                      title: Text(
                        asyncSnapshot.data?.name ?? 'Guest',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      subtitle: Text(
                        asyncSnapshot.data?.role == null ||
                                asyncSnapshot.data!.role == UserRole.unknown
                            ? 'Unknown'
                            : asyncSnapshot.data!.role == UserRole.tutor
                            ? 'Tutor'
                            : asyncSnapshot.data!.role == UserRole.student
                            ? 'Student'
                            : asyncSnapshot.data!.role.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 14.0),
                child: AppButton.secondary(
                  text: 'Sign Out',
                  onPressed: () {
                    context.read<AppBloc>().add(LogoutPressed());
                  },
                  height: 46,
                  leadingIcon: Icons.logout,
                ),
              ),
              Expanded(
                child: ListView(
                  reverse: true,
                  children: <Widget>[
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      leading: Icon(
                        Icons.support_agent,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      title: Text(
                        'Contact Support',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      onTap: () async {
                        ZoomDrawer.of(context)?.close();
                        await Future.delayed(const Duration(milliseconds: 300));
                        Navigator.of(
                          context,
                        ).pushNamed('support'); // Navigate to Support Page
                      },
                    ),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      leading: Icon(
                        Icons.admin_panel_settings,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      title: Text(
                        'Admin Tools',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      onTap: () async {
                        ZoomDrawer.of(context)?.close();
                        await Future.delayed(const Duration(milliseconds: 300));
                        Navigator.of(
                          context,
                        ).pushNamed('admin'); // Navigate to Admin Page
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
