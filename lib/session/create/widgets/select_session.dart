import 'package:app/app/app.dart';
import 'package:app/session/create/bloc/session_create_bloc.dart';
import 'package:flip_card_swiper/flip_card_swiper.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:flutter/material.dart';
import 'package:app/core/core.dart' as core;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pretty_json/pretty_json.dart';

class SelectSessionStep extends StatelessWidget {
  const SelectSessionStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCreateBloc, SessionCreateState>(
      buildWhen: (previous, current) =>
          !(previous is SessionsLoaded && current is SessionsLoaded),
      builder: (context, state) {
        if (state is LoadingTutors) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 20,
              children: [
                CircularProgressIndicator(),
                Text(
                  'Searching for Available Tutors',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        } else if (state is LoadingTutorsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                Text(
                  'Error loading tutors: ${state.errorMessage}',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
                SizedBox(height: 20),
                core.AppButton.danger(
                  onPressed: () {
                    context.read<SessionCreateBloc>().add(Start());
                  },
                  text: "Retry",
                ),
              ],
            ),
          );
        } else {
          final tutorList = (state as SessionsLoaded).tutorData.entries
              .map((e) => e.value)
              .toList();
          return Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Select a Tutor',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AvailableTimeSlots(
                    selectedTutorUser: tutorList[0]['user'] as core.User,
                  ),
                ),
              ),
              TutorCards(tutorList: tutorList),
              SizedBox(height: 30),
            ],
          );
        }
      },
    );
  }
}

class TutorCards extends StatelessWidget {
  const TutorCards({super.key, required this.tutorList});

  final List<Map<String, dynamic>> tutorList;

  @override
  Widget build(BuildContext context) {
    return FlipCardSwiper(
      cardData: tutorList,
      onCardChange: (newIndex) {},
      onCardCollectionAnimationComplete: (value) {},
      cardBuilder: (cardContext, index, visibleIndex) {
        return InkWell(
          onTap: () {
            context.read<SessionCreateBloc>().add(
              ChangeTutor(tutorList[index]['tutor'].uid),
            );
            printPrettyJson((tutorList[index]['user'] as core.User).toJson());
          },
          // Optional: Add a splash color for visual feedback
          splashColor: Colors.red,
          // Optional: Customize the shape of the splash effect to match the container
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
              // You can add a shadow for a more "button-like" feel
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Removed the SizedBox(height: 12) as it might look odd
                // if you only have one Text widget and want it perfectly centered.
                // If you plan to add more widgets, you can add it back.
                Text(
                  (tutorList[index]['user'] as core.User).name,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AvailableTimeSlots extends StatelessWidget {
  const AvailableTimeSlots({required this.selectedTutorUser, super.key});
  final core.User selectedTutorUser;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCreateBloc, SessionCreateState>(
      buildWhen: (previous, current) =>
          previous is SessionsLoaded &&
          current is SessionsLoaded &&
          previous.selectedUser != current.selectedUser,
      builder: (context, state) {
        if (state is! SessionsLoaded) {
          return const SizedBox.shrink(); // Return empty widget if not SessionsLoaded
        }
        final List<core.TimeSlot> timeSlots =
            state.selectedUser.schedule?.slots ?? [];
        final List<Map<String, dynamic>> groupedTimeSlots = timeSlots.map((
          timeSlot,
        ) {
          final dayOnly = DateTime(
            timeSlot.start.year,
            timeSlot.start.month,
            timeSlot.start.day,
          );
          return {'timeSlot': timeSlot, 'group': dayOnly.toString()};
        }).toList();
        return Padding(
          padding: const EdgeInsets.only(bottom: 40.0, left: 16, right: 16),
          child: ShaderMask(
            shaderCallback: (Rect rect) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.purple,
                  Colors.transparent,
                  Colors.transparent,
                  Colors.purple,
                ],
                stops: [0.0, 0.1, 0.9, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.dstOut,
            child: GroupedListView<dynamic, String>(
              elements: groupedTimeSlots,
              groupBy: (element) => element['group'],
              groupComparator: (value1, value2) => value2.compareTo(value1),
              itemComparator: (item1, item2) =>
                  item1['timeSlot'].start.compareTo(item2['timeSlot'].start),
              order: GroupedListOrder.DESC,
              useStickyGroupSeparators: true,
              groupSeparatorBuilder: (String value) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _formatGroupDate(value),
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              itemBuilder: (c, element) {
                return Card(
                  elevation: 2.0,
                  child: SizedBox(
                    width: 40,
                    child: ListTile(
                      onTap: () {
                        context.read<SessionCreateBloc>().add(
                          SelectSession(
                            studentUid:
                                (context.read<AppBloc>().state as Authenticated)
                                    .credential
                                    .id,
                            tutorUid: state.selectedTutor.uid,
                            timeSlot: element['timeSlot'] as core.TimeSlot,
                          ),
                        );
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        // vertical: 10.0,
                      ),
                      leading: Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                      title: Text(_formatTimeSlot(element['timeSlot'])),
                      trailing: const Icon(Icons.arrow_forward),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  String _formatTimeSlot(core.TimeSlot timeSlot) {
    final DateFormat timeFormat = DateFormat('h:mm a');
    final String startTime = timeFormat.format(timeSlot.start);
    final String endTime = timeFormat.format(timeSlot.end);
    return '$startTime - $endTime';
  }

  String _formatGroupDate(String dateString) {
    final DateTime date = DateTime.parse(dateString);
    final DateFormat dateFormat = DateFormat('EEEE, MM dd, yyyy');
    return dateFormat.format(date);
  }
}
