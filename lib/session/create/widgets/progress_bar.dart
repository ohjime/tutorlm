import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class SessionCreateProgressBar extends StatelessWidget {
  const SessionCreateProgressBar({
    super.key,
    required int currentStep,
    required int totalSteps,
    required this.context,
  }) : _currentStep = currentStep,
       _totalSteps = totalSteps;
  final int _currentStep;
  final int _totalSteps;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(7.0),
      child: LinearPercentIndicator(
        // strip out all padding so it hugs the edges
        padding: EdgeInsets.zero,
        // make it as tall as you like
        lineHeight: 16.0,
        // animate whenever percent changes
        animation: true,
        animationDuration: 600,
        animateFromLastPercent: true,
        percent: _currentStep == 0
            ? 0.05
            : (_currentStep) / (_totalSteps - 1) - 0.1,
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        progressColor: Theme.of(context).colorScheme.primary,
        // round off the ends if you like
        barRadius: const Radius.circular(30),
      ),
    );
  }
}
