import 'dart:async';

import 'package:flutter/material.dart';

import '../DesignUI/app_avatar.dart';
import '../DesignUI/empty_state.dart';
import '../Model/call_record_model.dart';
import '../Model/chat_model.dart';
import '../services/api_service.dart';
import '../services/call_history_store.dart';
import '../services/call_service.dart';
import '../services/realtime_service.dart';
import '../services/session.dart';
import '../theme/app_colors.dart';
import '../utils/time_format.dart';
import 'select_contact_page.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key, required this.session});

  final Session session;

  @override
  CallScreenState createState() => CallScreenState();
}

class CallScreenState extends State<CallScreen> {
  final List<CallRecordModel> _records = [];
  StreamSubscription<CallRecordModel>? _historySubscription;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _historySubscription =
        RealtimeService.instance.callHistory.listen(_handleNewCallRecord);
    _loadHistory();
  }

  @override
  void dispose() {
    _historySubscription?.cancel();
    super.dispose();
  }

  void _handleNewCallRecord(CallRecordModel record) {
    if (!mounted) return;
    setState(() {
      _records.removeWhere((r) => CallHistoryStore.isSameCall(r, record));
      _records.insert(0, record);
    });
  }

  Future<void> refresh() => _loadHistory();

  Future<void> _loadHistory() async {
    // 1. Load locally cached records first for zero-latency display
    final cached = await CallHistoryStore.load(widget.session.userId);
    if (mounted && cached.isNotEmpty && _records.isEmpty) {
      setState(() {
        _records
          ..clear()
          ..addAll(cached);
        _loading = false;
      });
    }

    // 2. Fetch fresh records from the server
    try {
      final remote = await ApiService(token: widget.session.token)
          .fetchCallHistory();
      if (!mounted) return;

      // Merge remote with any un-synced local records with strict deduplication
      final List<CallRecordModel> combinedList = [];
      for (final r in remote) {
        if (!combinedList.any((existing) => CallHistoryStore.isSameCall(existing, r))) {
          combinedList.add(r);
        }
      }
      for (final r in cached) {
        if (!combinedList.any((existing) => CallHistoryStore.isSameCall(existing, r))) {
          combinedList.add(r);
        }
      }

      combinedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      await CallHistoryStore.save(widget.session.userId, combinedList);

      if (!mounted) return;
      setState(() {
        _records
          ..clear()
          ..addAll(combinedList);
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (_records.isEmpty) {
          _error = 'Could not load call history.';
        }
      });
    }
  }

  Future<void> _startCall(ChatModel peer) async {
    final success = await CallService.instance.startCall(peer);
    if (!success && mounted) {
      final err = CallService.instance.lastError ?? 'Could not start call.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
    }
  }

  void _openContactPicker() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SelectContact(
          session: widget.session,
          embedded: false,
          forCall: true,
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '0s';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes == 0) return '${remainingSeconds}s';
    return '${minutes}m ${remainingSeconds}s';
  }

  Widget _buildStatusIcon(CallRecordModel record, ColorScheme scheme) {
    switch (record.status) {
      case CallStatus.missed:
        return const Icon(
          Icons.call_missed_rounded,
          color: Color(0xFFEF4444),
          size: 16,
        );
      case CallStatus.declined:
        return const Icon(
          Icons.call_end_rounded,
          color: Color(0xFFEF4444),
          size: 16,
        );
      case CallStatus.cancelled:
        return Icon(
          Icons.call_made_rounded,
          color: scheme.onSurfaceVariant,
          size: 16,
        );
      case CallStatus.completed:
        return Icon(
          record.direction == CallDirection.incoming
              ? Icons.call_received_rounded
              : Icons.call_made_rounded,
          color: record.direction == CallDirection.incoming
              ? const Color(0xFF10B981)
              : scheme.primary,
          size: 16,
        );
      case CallStatus.failed:
        return const Icon(
          Icons.error_outline_rounded,
          color: Color(0xFFEF4444),
          size: 16,
        );
    }
  }

  String _statusLabel(CallRecordModel record) {
    switch (record.status) {
      case CallStatus.completed:
        return _formatDuration(record.duration);
      case CallStatus.missed:
        return 'Missed';
      case CallStatus.declined:
        return 'Declined';
      case CallStatus.cancelled:
        return 'Cancelled';
      case CallStatus.failed:
        return 'Failed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (_loading && _records.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_records.isEmpty) {
      return EmptyState(
        icon: Icons.phone_in_talk_rounded,
        title: 'No recent calls',
        subtitle:
            'Start a crystal-clear audio call with any of your AirMail contacts.',
        buttonLabel: 'Start a call',
        onPressed: _openContactPicker,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: scheme.primary,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _records.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 82,
          endIndent: 16,
          color: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
        itemBuilder: (context, index) {
          final record = _records[index];
          final peerName = record.peer.name?.isNotEmpty == true
              ? record.peer.name!
              : (record.peer.email ?? 'Unknown');
          final isMissed = record.status == CallStatus.missed ||
              record.status == CallStatus.declined;

          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: AppAvatar(
              userId: record.peer.id,
              name: peerName,
              size: 50,
              online: RealtimeService.instance.isOnline(record.peer.id),
            ),
            title: Text(
              peerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: -0.2,
                color: isMissed ? const Color(0xFFEF4444) : scheme.onSurface,
              ),
            ),
            subtitle: Row(
              children: [
                _buildStatusIcon(record, scheme),
                const SizedBox(width: 5),
                Text(
                  _statusLabel(record),
                  style: TextStyle(
                    fontSize: 13,
                    color: isMissed
                        ? const Color(0xFFEF4444)
                        : scheme.onSurfaceVariant,
                    fontWeight: isMissed ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                Text(
                  ' • ',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                Text(
                  formatTimestamp(record.createdAt),
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            trailing: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                tooltip: 'Call $peerName',
                icon: Icon(
                  Icons.call_rounded,
                  size: 19,
                  color: scheme.primary,
                ),
                onPressed: () => _startCall(record.peer),
              ),
            ),
            onTap: () => _startCall(record.peer),
          );
        },
      ),
    );
  }
}
