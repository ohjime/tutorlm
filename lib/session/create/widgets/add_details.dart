import 'package:app/core/core.dart';
import 'package:app/session/create/bloc/session_create_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddDetailsStep extends StatelessWidget {
  const AddDetailsStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'There are no extra details to add',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            'You can proceed without adding any additional information.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          AppButton.tertiary(
            text: 'Proceed to Submission',
            onPressed: () {
              context.read<SessionCreateBloc>().add(
                ProvideDetails(
                  (context.read<SessionCreateBloc>().state
                          as SessionDetailsState)
                      .session,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
