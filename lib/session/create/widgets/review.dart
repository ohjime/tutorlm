import 'package:app/session/create/bloc/session_create_bloc.dart';
import 'package:app/session/list/widgets/items.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReviewSessionStep extends StatelessWidget {
  const ReviewSessionStep({super.key});

  @override
  Widget build(BuildContext context) {
    final session =
        (context.read<SessionCreateBloc>().state as SessionReviewState).session;
    return Column(
      children: [
        const SizedBox(height: 20),
        buildSessionTile(context, session),
        Text(
          'This is your Session',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: () {
            context.read<SessionCreateBloc>().add(Submit(session));
          },
          child: const Text('Submit Session'),
        ),
      ],
    );
  }
}
