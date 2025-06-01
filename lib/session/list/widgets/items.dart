import 'package:app/core/core.dart'; // Assuming this is your project's core import
import 'package:app/session/session.dart'; // Assuming this is your project's session import
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class SessionListItems extends StatefulWidget {
  const SessionListItems({super.key});
  @override
  State<SessionListItems> createState() => _SessionListItemsState();
}

class _SessionListItemsState extends State<SessionListItems> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: BlocBuilder<SessionListBloc, SessionListState>(
          builder: (context, state) {
            final sessions = state.filteredSessions;

            if (state.status == SessionListStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == SessionListStatus.failure) {
              return const Center(
                child: Text(
                  'Failed to load sessions.',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              );
            }

            if (sessions.isEmpty) {
              return const Center(
                child: Text(
                  'No sessions available.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }
            return AnimationLimiter(
              child: ListView.builder(
                itemCount: sessions.length,
                itemBuilder: (BuildContext context, int index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: buildSessionTile(context, sessions[index]),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget buildSessionTile(BuildContext context, Session session) {
  return SizedBox(
    width: MediaQuery.of(context).size.width,
    child: Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        title: Text(
          session.id,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Instructor: ${session.tutorId}\n'
          'Time Slot: ${session.timeslot.toString().substring(0, 16)}',
        ),
        trailing: Text(
          session.status.toString().split('.').last,
          style: TextStyle(
            color: session.status == SessionStatus.completed
                ? Colors.green.shade700
                : session.status == SessionStatus.cancelled
                ? Colors.red.shade700
                : Colors.blue.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/session_detail',
            arguments: session.id,
          );
        },
      ),
    ),
  );
}
