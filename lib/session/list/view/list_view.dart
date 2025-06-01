import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/core/core.dart';
import 'package:app/session/session.dart';

class SessionListView extends StatelessWidget {
  const SessionListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SessionListBloc(
        sessionRepository: RepositoryProvider.of<SessionRepository>(context),
      )..add(const SessionListSubscriptionRequested()),
      child: const _SessionListContent(),
    );
  }
}

class _SessionListContent extends StatelessWidget {
  const _SessionListContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SessionListFilters(
          onChanged: (filter) {
            context.read<SessionListBloc>().add(
              SessionListFilterChanged(filter),
            );
          },
        ),
        const SessionListItems(),
      ],
    );
  }
}
