import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/core/core.dart' as core;
import 'package:app/session/detail/bloc/session_detail_bloc.dart';
import 'simple_audio_recorder.dart';

/// Page that displays detailed information about a specific session.
class SessionDetailPage extends StatelessWidget {
  /// Creates a [SessionDetailPage].
  const SessionDetailPage({required this.sessionId, super.key});

  /// The ID of the session to display details for.
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SessionDetailBloc(
        sessionRepository: context.read<core.SessionRepository>(),
      )..add(SessionDetailRequested(sessionId: sessionId)),
      child: SessionDetailView(sessionId: sessionId),
    );
  }
}

/// The main view for displaying session details.
class SessionDetailView extends StatelessWidget {
  /// Creates a [SessionDetailView].
  const SessionDetailView({required this.sessionId, super.key});

  /// The ID of the session being displayed.
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Details'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          BlocBuilder<SessionDetailBloc, SessionDetailState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<SessionDetailBloc>().add(
                    SessionDetailRefreshRequested(sessionId: sessionId),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<SessionDetailBloc, SessionDetailState>(
        builder: (context, state) {
          return switch (state) {
            SessionDetailInitial() => const Center(
              child: Text('Initializing...'),
            ),
            SessionDetailLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            SessionDetailLoaded() => _SessionDetailContent(
              session: state.session,
            ),
            SessionDetailError() => _ErrorView(
              error: state.error,
              onRetry: () {
                context.read<SessionDetailBloc>().add(
                  SessionDetailRequested(sessionId: sessionId),
                );
              },
            ),
          };
        },
      ),
    );
  }
}

/// Widget that displays the actual session content when loaded.
class _SessionDetailContent extends StatelessWidget {
  const _SessionDetailContent({required this.session});

  final core.Session session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<SessionDetailBloc>().add(
          SessionDetailRefreshRequested(sessionId: session.id),
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session ID Card
            _InfoCard(
              title: 'Session Information',
              children: [
                _InfoRow(
                  label: 'Session ID',
                  value: session.id,
                  icon: Icons.fingerprint,
                ),
                _InfoRow(
                  label: 'Status',
                  value: _getStatusDisplayName(session.status),
                  icon: _getStatusIcon(session.status),
                  valueColor: _getStatusColor(context, session.status),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Participants Card
            _InfoCard(
              title: 'Participants',
              children: [
                _InfoRow(
                  label: 'Tutor ID',
                  value: session.tutorId,
                  icon: Icons.school,
                ),
                _InfoRow(
                  label: 'Student ID',
                  value: session.studentId,
                  icon: Icons.person,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Time Information Card
            if (session.timeslot != null) ...[
              _InfoCard(
                title: 'Schedule',
                children: [
                  _InfoRow(
                    label: 'Start Time',
                    value: _formatDateTime(session.timeslot!.start),
                    icon: Icons.schedule,
                  ),
                  _InfoRow(
                    label: 'End Time',
                    value: _formatDateTime(session.timeslot!.end),
                    icon: Icons.schedule_outlined,
                  ),
                  _InfoRow(
                    label: 'Duration',
                    value: _formatDuration(
                      session.timeslot!.end.difference(session.timeslot!.start),
                    ),
                    icon: Icons.timer,
                  ),
                  if (session.timeslot!.name != null) ...[
                    _InfoRow(
                      label: 'Session Name',
                      value: session.timeslot!.name!,
                      icon: Icons.label,
                    ),
                  ],
                ],
              ),
            ] else ...[
              _InfoCard(
                title: 'Schedule',
                children: [
                  _InfoRow(
                    label: 'Time Slot',
                    value: 'Not scheduled',
                    icon: Icons.schedule_outlined,
                    valueColor: theme.colorScheme.error,
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons (placeholder for future functionality)
            _ActionButtonsSection(session: session),
          ],
        ),
      ),
    );
  }

  String _getStatusDisplayName(core.SessionStatus status) {
    switch (status) {
      case core.SessionStatus.scheduled:
        return 'Scheduled';
      case core.SessionStatus.inProgress:
        return 'In Progress';
      case core.SessionStatus.completed:
        return 'Completed';
      case core.SessionStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData _getStatusIcon(core.SessionStatus status) {
    switch (status) {
      case core.SessionStatus.scheduled:
        return Icons.event;
      case core.SessionStatus.inProgress:
        return Icons.play_circle;
      case core.SessionStatus.completed:
        return Icons.check_circle;
      case core.SessionStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(BuildContext context, core.SessionStatus status) {
    final theme = Theme.of(context);
    switch (status) {
      case core.SessionStatus.scheduled:
        return theme.colorScheme.primary;
      case core.SessionStatus.inProgress:
        return Colors.orange;
      case core.SessionStatus.completed:
        return Colors.green;
      case core.SessionStatus.cancelled:
        return theme.colorScheme.error;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

/// Reusable card widget for displaying information sections.
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying a labeled information row with an icon.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: valueColor ?? theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Section with action buttons for session management.
class _ActionButtonsSection extends StatefulWidget {
  const _ActionButtonsSection({required this.session});
  final core.Session session;
  @override
  State<_ActionButtonsSection> createState() => _ActionButtonsSectionState();
}

class _ActionButtonsSectionState extends State<_ActionButtonsSection> {
  late final SimpleAudioRecorder _audioRecorder;
  bool _isRecording = false;
  List<int>? _audioBytes;

  @override
  void initState() {
    super.initState();
    _audioRecorder = SimpleAudioRecorder();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _audioBytes = _audioRecorder.lastRecording;
      });
    } else {
      await _audioRecorder.start();
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _saveAudioFile() async {
    if (_audioBytes == null) return;

    final success = await _audioRecorder.saveToFile();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Audio file saved successfully!'
                : 'Failed to save audio file',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (widget.session.status == core.SessionStatus.scheduled) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement start session functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Start session functionality coming soon!',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Session'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement cancel session functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Cancel session functionality coming soon!',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                  ),
                ],
                if (widget.session.status == core.SessionStatus.inProgress) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement end session functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'End session functionality coming soon!',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('End Session'),
                  ),
                ],
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement edit session functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Edit session functionality coming soon!',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                ElevatedButton.icon(
                  onPressed: _toggleRecording,
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  label: Text(_isRecording ? 'Stop Recording' : 'Record'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? Colors.red : null,
                  ),
                ),
                if (_audioBytes != null) ...[
                  const Text('Audio recorded and stored in memory.'),
                  OutlinedButton.icon(
                    onPressed: _saveAudioFile,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Audio'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget displayed when there's an error loading session details.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load session details',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
