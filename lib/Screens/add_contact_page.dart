import 'package:airmail/DesignUI/app_avatar.dart';
import 'package:airmail/services/api_service.dart';
import 'package:airmail/services/realtime_service.dart';
import 'package:airmail/services/session.dart';
import 'package:flutter/material.dart';

class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key, required this.session});

  final Session session;

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final TextEditingController _emailController = TextEditingController();

  ContactLookup? _result;
  bool _searching = false;
  bool _adding = false;
  bool _searched = false;
  bool _alreadyContact = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _error = 'Enter an email address.';
        _result = null;
        _searched = false;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _searching = true;
      _searched = true;
      _error = null;
      _result = null;
      _alreadyContact = false;
    });

    try {
      final result =
          await ApiService(token: widget.session.token).searchContact(email);
      if (!mounted) return;
      RealtimeService.instance.updateOnlineStatuses([result.user]);
      setState(() {
        _result = result;
        _alreadyContact = result.isContact;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not search for that user.');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _add() async {
    final result = _result;
    if (result == null || _adding) return;

    setState(() {
      _adding = true;
      _error = null;
    });

    try {
      final contact = await ApiService(token: widget.session.token)
          .addContact(result.user.email ?? _emailController.text.trim());
      if (!mounted) return;
      RealtimeService.instance.updateOnlineStatuses([contact]);
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        if (error.message.toLowerCase().contains('already')) {
          _alreadyContact = true;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not add that contact.');
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  Widget _buildResult() {
    final result = _result;
    if (result == null) return const SizedBox.shrink();

    final user = result.user;

    return ValueListenableBuilder<Set<String>>(
      valueListenable: RealtimeService.instance.onlineUsers,
      builder: (context, _, __) {
        final isOnline = RealtimeService.instance.effectiveOnline(
          user.id,
          fallback: user.status == 'online',
        );
        final scheme = Theme.of(context).colorScheme;

        return Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              AppAvatar(name: user.name, size: 48, online: isOnline),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name ?? 'Unknown',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (_alreadyContact)
                Text(
                  'Already added',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              else
                FilledButton(
                  onPressed: _adding ? null : _add,
                  child: _adding
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add'),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Add contact')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Find someone on AirMail',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Search for an existing user by their email address, then add them to your contacts.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.search,
                autocorrect: false,
                onSubmitted: (_) => _search(),
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _searching || _adding ? null : _search,
                icon: _searching
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: Text(_searching ? 'Searching...' : 'Search'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: TextStyle(color: scheme.error),
                ),
              ],
              if (_searched && _result == null && _error == null)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('No matching user found.'),
                ),
              _buildResult(),
            ],
          ),
        ),
      ),
    );
  }
}
