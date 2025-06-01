import 'package:app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:app/settings/widgets/settings_options_row.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: SecondaryAppbar(
          pageTitle: 'Settings',
          pageSubtitle: 'Manage your preferences',
          color: colorScheme.primary,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsOptionsRow(color: Theme.of(context).colorScheme.primary),
            // Spacer to push content to top
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
