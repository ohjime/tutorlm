import 'package:flutter/material.dart';
import 'package:app/core/widgets/user_avatar.dart';
import 'package:delayed_display/delayed_display.dart';

class PrimaryAppBar extends StatelessWidget {
  const PrimaryAppBar({
    super.key,
    required this.tabTitle,
    required this.tabAction,
    required this.onPressed,
    required this.color,
  });

  final String tabTitle;
  final Widget tabAction;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 100,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(onPressed: onPressed),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  child: Align(
                    alignment: Alignment.centerRight,
                    key: ValueKey<String>(tabTitle),
                    child: DelayedDisplay(
                      slidingBeginOffset: Offset(0.0, 0.1),
                      delay: const Duration(milliseconds: 100),
                      fadingDuration: const Duration(milliseconds: 200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            tabTitle,
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          tabAction,
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
