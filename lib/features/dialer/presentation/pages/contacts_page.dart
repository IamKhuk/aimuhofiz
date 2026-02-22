import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../bloc/call_bloc.dart';
import 'in_call_page.dart';

/// Device contacts page with search and tap-to-call.
class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = true;
  bool _permissionDenied = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() {
        _permissionDenied = true;
        _isLoading = false;
      });
      return;
    }

    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );

    setState(() {
      _contacts = contacts;
      _filteredContacts = contacts;
      _isLoading = false;
    });
  }

  void _filterContacts(String query) {
    if (query.isEmpty) {
      setState(() => _filteredContacts = _contacts);
      return;
    }

    final lower = query.toLowerCase();
    setState(() {
      _filteredContacts = _contacts.where((c) {
        final name = c.displayName.toLowerCase();
        final phones = c.phones.map((p) => p.number).join(' ');
        return name.contains(lower) || phones.contains(query);
      }).toList();
    });
  }

  void _onContactTap(Contact contact) {
    final phones = contact.phones;
    if (phones.isEmpty) return;

    if (phones.length == 1) {
      _makeCall(phones.first.number);
    } else {
      // Show picker for contacts with multiple numbers
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF131D2B),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                contact.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ...phones.map((phone) => ListTile(
                    leading: const Icon(Icons.phone, color: Color(0xFF3B82F6)),
                    title: Text(
                      phone.number,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      phone.label.name,
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _makeCall(phone.number);
                    },
                  )),
            ],
          ),
        ),
      );
    }
  }

  void _makeCall(String number) {
    final cleanNumber = number.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    context.read<CallBloc>().add(InitiateCallEvent(cleanNumber));

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CallBloc>(),
          child: const InCallPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1720),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _filterContacts,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Kontakt qidirish...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF131D2B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            // Contact list
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF3B82F6)))
                  : _permissionDenied
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.contacts,
                                  color: Colors.white24, size: 64),
                              SizedBox(height: 16),
                              Text(
                                'Kontaktlar ruxsati berilmagan',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ],
                          ),
                        )
                      : _filteredContacts.isEmpty
                          ? const Center(
                              child: Text(
                                'Kontaktlar topilmadi',
                                style: TextStyle(color: Colors.white54),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredContacts.length,
                              itemBuilder: (context, index) {
                                final contact = _filteredContacts[index];
                                final phone = contact.phones.isNotEmpty
                                    ? contact.phones.first.number
                                    : '';
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        const Color(0xFF1E2D3D),
                                    child: Text(
                                      contact.displayName.isNotEmpty
                                          ? contact.displayName[0]
                                              .toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: Color(0xFF3B82F6),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    contact.displayName,
                                    style:
                                        const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: phone.isNotEmpty
                                      ? Text(
                                          phone,
                                          style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 13),
                                        )
                                      : null,
                                  onTap: () => _onContactTap(contact),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
