import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';

class SecondaryAppbar extends StatelessWidget {
  const SecondaryAppbar({
    super.key,
    required this.pageTitle,
    required this.pageSubtitle,
    this.pageAction,
    required this.color,
  });

  final String pageTitle;
  final String pageSubtitle;
  final Widget? pageAction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 100,
      automaticallyImplyLeading: false,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.of(context).pop(),
                color: color,
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    key: ValueKey<String>(pageTitle),
                    child: DelayedDisplay(
                      slidingBeginOffset: Offset(0.0, 0.1),
                      delay: const Duration(milliseconds: 100),
                      fadingDuration: const Duration(milliseconds: 200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pageTitle,
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pageSubtitle,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: color.withValues(alpha: 0.7)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
