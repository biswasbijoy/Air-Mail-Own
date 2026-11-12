import 'package:airmail/DesignUI/empty_state.dart';
import 'package:flutter/material.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.call_outlined,
      title: 'Start a call from a chat',
      subtitle:
          'Open a conversation and tap the phone icon to make an audio call.',
    );
  }
}
