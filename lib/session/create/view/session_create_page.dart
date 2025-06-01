import 'package:app/core/core.dart';
import 'package:app/session/create/bloc/session_create_bloc.dart';
import 'package:app/session/session.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_indicator/loading_indicator.dart';

class SessionCreateModal extends StatelessWidget {
  const SessionCreateModal({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SessionCreateBloc(
        context.read<TutorRepository>(),
        context.read<UserRepository>(),
        context.read<SessionRepository>(),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SessionCreateView(),
        ),
      ),
    );
  }
}

class SessionCreateView extends StatefulWidget {
  const SessionCreateView({super.key});

  @override
  State<SessionCreateView> createState() => _SessionCreateViewState();
}

class _SessionCreateViewState extends State<SessionCreateView> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionCreateBloc, SessionCreateState>(
      listener: (context, state) {},
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          shadowColor: Colors.transparent,
          leading: BlocBuilder<SessionCreateBloc, SessionCreateState>(
            builder: (context, state) {
              if (state is LoadingTutors || state is Submitting) {
                return Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: DelayedDisplay(
                    delay: const Duration(milliseconds: 10),
                    fadingDuration: const Duration(milliseconds: 400),
                    slidingBeginOffset: Offset(0, 0),
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballPulseSync,
                    ),
                  ),
                );
              }
              if (state is Success) {
                return Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: DelayedDisplay(
                    delay: const Duration(milliseconds: 10),
                    fadingDuration: const Duration(milliseconds: 400),
                    slidingBeginOffset: Offset(0, 0),
                    child: IconButton(
                      icon: const Icon(Icons.check_circle_rounded),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                );
              }
              return DelayedDisplay(
                delay: const Duration(milliseconds: 10),
                fadingDuration: const Duration(milliseconds: 400),
                slidingBeginOffset: Offset(0, 0),
                child: IconButton(
                  icon: state.currentStep > 0
                      ? const Icon(Icons.arrow_back_ios_new_rounded)
                      : const Icon(Icons.close_rounded),
                  onPressed: () {
                    if (state.currentStep > 0) {
                      setState(() {
                        context.read<SessionCreateBloc>().add(Back());
                      });
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              );
            },
          ),
          title: BlocBuilder<SessionCreateBloc, SessionCreateState>(
            builder: (context, state) {
              return SessionCreateProgressBar(
                currentStep: state.currentStep,
                totalSteps: 5,
                context: context,
              );
            },
          ),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchOutCurve: Curves.easeIn,
          switchInCurve: Curves.easeIn,
          layoutBuilder: (currentChild, previousChildren) => Stack(
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          ),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.03),
                  end: const Offset(0, 0),
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: BlocBuilder<SessionCreateBloc, SessionCreateState>(
            buildWhen: (previous, current) =>
                previous.currentStep != current.currentStep,
            builder: (context, state) {
              final Widget step;
              switch (state) {
                case Initial():
                  step = InitialStep();
                  break;
                case SelectSessionState():
                  step = SelectSessionStep();
                  break;
                case SessionDetailsState():
                  step = AddDetailsStep();
                  break;
                case SessionReviewState():
                  step = ReviewSessionStep();
                  break;
                case Success():
                  step = SessionCreated();
                  break;
                default:
                  step = Container();
              }
              return Container(
                key: ValueKey(state.currentStep),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: DelayedDisplay(
                  delay: const Duration(milliseconds: 400),
                  fadingDuration: const Duration(milliseconds: 400),
                  fadeIn: true,
                  slidingBeginOffset: const Offset(0, 0.03),
                  child: step,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
