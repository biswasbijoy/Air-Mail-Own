import 'dart:async';

import 'package:airmail/DesignUI/app_avatar.dart';
import 'package:airmail/services/call_service.dart';
import 'package:airmail/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CallPage extends StatefulWidget {
  const CallPage({super.key});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final CallService _calls = CallService.instance;
  Timer? _durationTimer;
  Timer? _exitTimer;

  @override
  void initState() {
    super.initState();
    _calls.addListener(_handleCallChanged);
    _syncDurationTimer();
    _handleIdleState();
  }

  @override
  void dispose() {
    _calls.removeListener(_handleCallChanged);
    _durationTimer?.cancel();
    _exitTimer?.cancel();
    super.dispose();
  }

  void _handleCallChanged() {
    if (!mounted) return;
    if (_calls.state != CallState.idle) {
      _exitTimer?.cancel();
      _exitTimer = null;
    }
    setState(_syncDurationTimer);
    _handleIdleState();
  }

  void _syncDurationTimer() {
    if (_calls.state == CallState.active) {
      _durationTimer ??= Timer.periodic(
        const Duration(seconds: 1),
        (_) {
          if (mounted) setState(() {});
        },
      );
    } else {
      _durationTimer?.cancel();
      _durationTimer = null;
    }
  }

  void _handleIdleState() {
    if (_calls.state != CallState.idle || _exitTimer != null) return;
    _exitTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      Navigator.of(context).maybePop();
    });
  }

  String _statusText() {
    switch (_calls.state) {
      case CallState.outgoing:
        return 'Calling...';
      case CallState.incoming:
        return 'Incoming audio call';
      case CallState.connecting:
        return 'Connecting...';
      case CallState.active:
        return _formatDuration(_callDuration());
      case CallState.idle:
        final error = _calls.lastError;
        if (error != null && error.isNotEmpty) return error;
        return _calls.lastEndReason ?? 'Call ended';
    }
  }

  Duration _callDuration() {
    final startedAt = _calls.connectedAt;
    if (startedAt == null) return Duration.zero;
    return DateTime.now().difference(startedAt);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final peer = _calls.peer;
    final isIncoming = _calls.state == CallState.incoming;

    return PopScope(
      canPop: _calls.state == CallState.idle,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _calls.state != CallState.idle) {
          unawaited(_calls.endCall());
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scheme.surface,
                AppColors.primary.withValues(alpha: 0.14),
                scheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip: isIncoming ? 'Decline' : 'End call',
                      onPressed: () {
                        if (isIncoming) {
                          unawaited(_calls.declineCall());
                        } else {
                          unawaited(_calls.endCall());
                        }
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ),
                  const Spacer(),
                  AppAvatar(name: peer?.name, size: 124),
                  const SizedBox(height: 28),
                  Text(
                    peer?.name ?? 'Unknown caller',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if ((peer?.email ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      peer!.email!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Text(
                    _statusText(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _calls.state == CallState.idle
                              ? scheme.onSurfaceVariant
                              : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  if (isIncoming)
                    _buildIncomingControls()
                  else
                    _buildActiveControls(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIncomingControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _CallAction(
          icon: Icons.call_end,
          label: 'Decline',
          background: const Color(0xFFE5484D),
          onPressed: () => unawaited(_calls.declineCall()),
        ),
        _CallAction(
          icon: Icons.call,
          label: 'Accept',
          background: AppColors.primary,
          foreground: AppColors.onPrimary,
          onPressed: () => unawaited(_calls.acceptCall()),
        ),
      ],
    );
  }

  Widget _buildActiveControls() {
    final enabled = _calls.state != CallState.idle;
    final isOutgoing = _calls.state == CallState.outgoing;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _CallAction(
              icon: _calls.muted ? Icons.mic_off : Icons.mic,
              label: _calls.muted ? 'Unmute' : 'Mute',
              background: _calls.muted
                  ? AppColors.primary.withValues(alpha: 0.24)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              foreground: _calls.muted
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.onSurface,
              onPressed: enabled ? () => unawaited(_calls.toggleMute()) : null,
            ),
            _CallAction(
              icon: _calls.speakerOn
                  ? Icons.volume_up
                  : Icons.volume_down_outlined,
              label: 'Speaker',
              background: _calls.speakerOn
                  ? AppColors.primary.withValues(alpha: 0.24)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              foreground: _calls.speakerOn
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.onSurface,
              onPressed:
                  enabled ? () => unawaited(_calls.toggleSpeaker()) : null,
            ),
          ],
        ),
        const SizedBox(height: 28),
        _CallAction(
          icon: Icons.call_end,
          label: isOutgoing ? 'Cancel' : 'End',
          background: const Color(0xFFE5484D),
          onPressed: enabled ? () => unawaited(_calls.endCall()) : null,
        ),
      ],
    );
  }
}

class _CallAction extends StatelessWidget {
  const _CallAction({
    required this.icon,
    required this.label,
    required this.background,
    required this.onPressed,
    this.foreground = Colors.white,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 68,
          height: 68,
          child: IconButton.filled(
            onPressed: onPressed,
            style: IconButton.styleFrom(
              backgroundColor: background,
              foregroundColor: foreground,
            ),
            icon: Icon(icon, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }
}
