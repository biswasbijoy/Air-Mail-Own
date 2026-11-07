import 'package:airmail/DesignUI/contact_card.dart';
import 'package:airmail/DesignUI/empty_state.dart';
import 'package:airmail/Model/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:airmail/theme/app_colors.dart';

class SelectContact extends StatefulWidget {
  const SelectContact({Key? key}) : super(key: key);
  @override
  _SelectContactState createState() => _SelectContactState();
}

class _SelectContactState extends State<SelectContact> {
  List<ChatModel> _contacts = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Sample contacts
    _contacts = [
      ChatModel(name: 'Bill Gates', icon: 'assets/images/BillGates.jpeg', time: 'Today', status: 'online'),
      ChatModel(name: 'Boris Johnson', icon: 'assets/images/BorisJohnson.jpg', time: 'Yesterday', status: 'online'),
      ChatModel(name: 'Donald Trump', icon: 'assets/images/DonaldTrump.jpg', time: '2d ago', status: 'online'),
      ChatModel(name: 'Recep Tayyip Erdogan', icon: 'assets/images/Erdogan.jpg', time: '3d ago', status: 'online'),
      ChatModel(name: 'Jack Ma', icon: 'assets/images/JackMa.jpg', time: '4d ago', status: 'online'),
    ];
  }

  List<ChatModel> get _filteredContacts {
    if (_searchQuery.isEmpty) return _contacts;
    return _contacts.where((contact) {
      return contact.name!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          contact.email!.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(
      title: const Text('Select contact'),
    ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search field
            TextField(
              onChanged: (query) {
                setState(() => _searchQuery = query);
              },
              decoration: const InputDecoration(
                hintText: 'Search name or email',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            // Filtered list
            Expanded(
              child: _filteredContacts.isEmpty
                  ? EmptyState(
                      icon: Icons.person_outline,
                      title: 'No contacts',
                      subtitle: 'No matching contacts found.',
                    )
                  : ListView.builder(
                      itemCount: _filteredContacts.length,
                      itemBuilder: (context, index) {
                        return ContactCard(contact: _filteredContacts[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}