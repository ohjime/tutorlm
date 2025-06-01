import 'package:app/session/create/bloc/session_create_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InitialStep extends StatelessWidget {
  const InitialStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 30,
        children: [
          Text(
            'Initial Step',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          ElevatedButton(
            onPressed: () {
              context.read<SessionCreateBloc>().add(const Start());
            },
            child: Text('Next Step'),
          ),
        ],
      ),
    );
  }
}
