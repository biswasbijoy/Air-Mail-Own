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
      _records.removeWhere((r) => r.id == record.id && r.id.isNotEmpty);
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

      // Merge remote with any un-synced local records
      final Map<String, CallRecordModel> merged = {};
      for (final r in remote) {
        if (r.id.isNotEmpty) merged[r.id] = r;
      }
      for (final r in cached) {
        if (r.id.isNotEmpty && !merged.containsKey(r.id)) {
          merged[r.id] = r;
        }
      }

      final combined = merged.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      await CallHistoryStore.save(widget.session.userId, combined);

      if (!mounted) return;
      setState(() {
        _records
          ..clear()
          ..addAll(combined);
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
        builder: (_) => SelectContact(session: widget.session, embedded: false),
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
          Icons.call_missed,
          color: Color(0xFFE5484D),
          size: 16,
        );
      case CallStatus.declined:
        return const Icon(
          Icons.call_end,
          color: Color(0xFFE5484D),
          size: 16,
        );
      case CallStatus.cancelled:
        return Icon(
          Icons.call_made,
          color: scheme.onSurfaceVariant,
          size: 16,
        );
      case CallStatus.completed:
        return Icon(
          record.direction == CallDirection.incoming
              ? Icons.call_received
              : Icons.call_made,
          color: AppColors.primary,
          size: 16,
        );
      case CallStatus.failed:
        return const Icon(
          Icons.error_outline,
          color: Color(0xFFE5484D),
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
        icon: Icons.call_outlined,
        title: 'No recent calls',
        subtitle:
            'When you make or receive audio calls, they will appear here.',
        onPressed: _openContactPicker,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _records.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 76,
          endIndent: 16,
          color: scheme.outlineVariant.withValues(alpha: 0.25),
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
              name: peerName,
              size: 48,
              online: RealtimeService.instance.isOnline(record.peer.id),
            ),
            title: Text(
              peerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: isMissed ? const Color(0xFFE5484D) : scheme.onSurface,
              ),
            ),
            subtitle: Row(
              children: [
                _buildStatusIcon(record, scheme),
                const SizedBox(width: 4),
                Text(
                  _statusLabel(record),
                  style: TextStyle(
                    fontSize: 13,
                    color: isMissed
                        ? const Color(0xFFE5484D)
                        : scheme.onSurfaceVariant,
                    fontWeight: isMissed ? FontWeight.w500 : FontWeight.normal,
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
            trailing: IconButton(
              tooltip: 'Call $peerName',
              icon: const Icon(
                Icons.call_outlined,
                color: AppColors.primary,
              ),
              onPressed: () => _startCall(record.peer),
            ),
            onTap: () => _startCall(record.peer),
          );
        },
      ),
    );
  }
}
