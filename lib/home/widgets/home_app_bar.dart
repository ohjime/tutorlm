import 'package:chiclet/chiclet.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    super.key,
    required this.tabTitle,
    required this.tabSubtitle,
    required this.onPressed,
    required this.color,
  });

  final String tabTitle;
  final String tabSubtitle;
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
              // Drawer menu button
              ChicletAnimatedButton(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  await Future.delayed(const Duration(milliseconds: 60));
                  onPressed();
                },
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerLow,
                foregroundColor: color,
                buttonHeight: 6,
                buttonColor: color,
                child: const Icon(Icons.menu, size: 28),
              ),
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
                          Text(
                            tabSubtitle,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 3,
                                ),
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
