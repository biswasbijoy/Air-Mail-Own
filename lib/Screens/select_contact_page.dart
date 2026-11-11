import 'package:airmail/DesignUI/contact_card.dart';
import 'package:airmail/DesignUI/empty_state.dart';
import 'package:airmail/Model/chat_model.dart';
import 'package:airmail/Screens/indivisual_page.dart';
import 'package:airmail/services/api_service.dart';
import 'package:airmail/services/session.dart';
import 'package:airmail/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SelectContact extends StatefulWidget {
  const SelectContact({
    super.key,
    required this.session,
    this.embedded = true,
  });

  final Session session;
  final bool embedded;

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
          await ApiService(token: widget.session.token).fetchUsers();
      if (!mounted) return;
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

  Widget _buildBody() {
    final filtered = _filteredContacts;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: (query) => setState(() => _searchQuery = query),
            decoration: const InputDecoration(
              hintText: 'Search name or email',
              prefixIcon: Icon(Icons.search),
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
                          icon: Icons.person_outline,
                          title: _contacts.isEmpty ? 'No contacts' : 'No matches',
                          subtitle: _contacts.isEmpty
                              ? 'Invite friends to start chatting.'
                              : 'No contacts match your search.',
                        )
                      : RefreshIndicator(
                          onRefresh: _loadContacts,
                          color: AppColors.primary,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final contact = filtered[index];
                              return ContactCard(
                                contact: contact,
                                onTap: () => _openChat(contact),
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
      appBar: AppBar(title: const Text('Select contact')),
      body: body,
    );
  }
}
