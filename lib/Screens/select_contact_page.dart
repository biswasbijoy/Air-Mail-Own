import 'package:airmail/DesignUI/contact_card.dart';
import 'package:airmail/DesignUI/empty_state.dart';
import 'package:airmail/Model/chat_model.dart';
import 'package:airmail/Screens/add_contact_page.dart';
import 'package:airmail/Screens/indivisual_page.dart';
import 'package:airmail/services/api_service.dart';
import 'package:airmail/services/call_service.dart';
import 'package:airmail/services/realtime_service.dart';
import 'package:airmail/services/session.dart';
import 'package:airmail/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SelectContact extends StatefulWidget {
  const SelectContact({
    super.key,
    required this.session,
    this.embedded = true,
    this.forCall = false,
  });

  final Session session;
  final bool embedded;
  final bool forCall;

  @override
  State<SelectContact> createState() => _SelectContactState();
}

class _SelectContactState extends State<SelectContact> {
  final List<ChatModel> _contacts = [];
  bool _loading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final contacts =
          await ApiService(token: widget.session.token).fetchContacts();
      if (!mounted) return;
      RealtimeService.instance.updateOnlineStatuses(contacts);
      setState(() {
        _contacts
          ..clear()
          ..addAll(contacts);
        _loading = false;
        _error = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load contacts.';
      });
    }
  }

  List<ChatModel> get _filteredContacts {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _contacts;

    return _contacts.where((contact) {
      final name = contact.name?.toLowerCase() ?? '';
      final email = contact.email?.toLowerCase() ?? '';
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  void _openChat(ChatModel contact) {
    if (contact.id == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => IndivisualPage(
          chatModel: contact,
          session: widget.session,
        ),
      ),
    );
  }

  Future<void> _startCall(ChatModel contact) async {
    if (contact.id == null) return;
    Navigator.of(context).pop();
    final success = await CallService.instance.startCall(contact);
    if (!success && mounted) {
      final err = CallService.instance.lastError ?? 'Could not start call.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
    }
  }

  Future<void> _removeContact(ChatModel contact) async {
    final contactId = contact.id;
    if (contactId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove contact'),
        content: Text(
          'Remove ${contact.name ?? 'this contact'} from your contacts?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ApiService(token: widget.session.token).removeContact(contactId);
      if (!mounted) return;
      setState(() => _contacts.removeWhere((item) => item.id == contactId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact removed.')),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not remove the contact.')),
      );
    }
  }

  Future<void> _openAddContact() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddContactPage(session: widget.session),
      ),
    );

    if (added == true && mounted) {
      setState(() => _loading = true);
      await _loadContacts();
    }
  }

  Widget _buildBody() {
    final scheme = Theme.of(context).colorScheme;
    final filtered = _filteredContacts;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: (query) => setState(() => _searchQuery = query),
            decoration: InputDecoration(
              hintText: 'Search name or email...',
              prefixIcon: Icon(Icons.search, size: 20, color: scheme.onSurfaceVariant),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: scheme.primary, width: 1.2),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _openAddContact,
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
              label: const Text('Add contact', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? EmptyState(
                      icon: Icons.cloud_off_outlined,
                      title: 'Could not load contacts',
                      subtitle: _error!,
                      onPressed: () {
                        setState(() => _loading = true);
                        _loadContacts();
                      },
                    )
                  : filtered.isEmpty
                      ? EmptyState(
                          icon: Icons.person_outline_rounded,
                          title:
                              _contacts.isEmpty ? 'No contacts yet' : 'No matches found',
                          subtitle: _contacts.isEmpty
                              ? 'Add a contact by email to start chatting.'
                              : 'No contacts match "$_searchQuery".',
                        )
                      : RefreshIndicator(
                          onRefresh: _loadContacts,
                          color: scheme.primary,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              indent: 82,
                              endIndent: 16,
                              color: scheme.outlineVariant.withValues(alpha: 0.35),
                            ),
                            itemBuilder: (context, index) {
                              final contact = filtered[index];
                              return ContactCard(
                                contact: contact,
                                onTap: () => widget.forCall
                                    ? _startCall(contact)
                                    : _openChat(contact),
                                onRemove: () => _removeContact(contact),
                                trailing: widget.forCall
                                    ? Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: scheme.primary.withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(
                                            Icons.call_rounded,
                                            size: 19,
                                            color: scheme.primary,
                                          ),
                                          tooltip: 'Call ${contact.name ?? ''}',
                                          onPressed: () => _startCall(contact),
                                        ),
                                      )
                                    : null,
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _buildBody();
    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.forCall ? 'New call' : 'Select contact'),
      ),
      body: body,
    );
  }
}
