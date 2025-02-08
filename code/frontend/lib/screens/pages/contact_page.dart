import 'package:flutter/material.dart';
import '../../constants/style.dart';
import '../../components/page_title.dart';

class Contact {
  final String name;
  final String email;
  final String phone;
  final String type;

  Contact({
    required this.name,
    required this.email,
    required this.phone,
    required this.type,
  });
}

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Contact> _contacts = [
    Contact(name: 'John Supplier', email: 'john@supplier.com', phone: '+1234567890', type: 'Supplier'),
    Contact(name: 'Alice Client', email: 'alice@client.com', phone: '+1234567891', type: 'Client'),
    Contact(name: 'Bob Distributor', email: 'bob@distributor.com', phone: '+1234567892', type: 'Distributor'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitle(
              title: "Contacts",
              subtitle: "Manage your business contacts and communications",
              icon: Icons.contact_page_outlined,
              actions: [
                ElevatedButton.icon(
                  icon: Icon(Icons.person_add),
                  label: Text("New Contact"),
                  onPressed: () => _showAddContactDialog("Supplier"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: defaultPadding,
                      vertical: defaultPadding / 2,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: defaultPadding),
            Container(
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: "Suppliers"),
                      Tab(text: "Clients"),
                      Tab(text: "Distributors"),
                    ],
                  ),
                  const SizedBox(height: defaultPadding),
                  SizedBox(
                    height: 500,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildContactList('Supplier'),
                        _buildContactList('Client'),
                        _buildContactList('Distributor'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactList(String type) {
    final contacts = _contacts.where((c) => c.type == type).toList();
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$type List",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddContactDialog(type),
                icon: const Icon(Icons.add),
                label: Text("Add $type"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding,
                    vertical: defaultPadding / 2,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: defaultPadding,
                  vertical: defaultPadding / 2,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: primaryColor,
                    child: Text(contact.name[0]),
                  ),
                  title: Text(contact.name),
                  subtitle: Text(contact.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.email),
                        onPressed: () => _showContactForm(context, contact),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditContactDialog(contact),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteContact(contact),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddContactDialog(String type) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New $type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                icon: Icon(Icons.person),
              ),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                icon: Icon(Icons.email),
              ),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                icon: Icon(Icons.phone),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _contacts.add(Contact(
                  name: nameController.text,
                  email: emailController.text,
                  phone: phoneController.text,
                  type: type,
                ));
              });
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditContactDialog(Contact contact) {
    final nameController = TextEditingController(text: contact.name);
    final emailController = TextEditingController(text: contact.email);
    final phoneController = TextEditingController(text: contact.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                icon: Icon(Icons.person),
              ),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                icon: Icon(Icons.email),
              ),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                icon: Icon(Icons.phone),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final index = _contacts.indexOf(contact);
                _contacts[index] = Contact(
                  name: nameController.text,
                  email: emailController.text,
                  phone: phoneController.text,
                  type: contact.type,
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteContact(Contact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _contacts.remove(contact);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showContactForm(BuildContext context, Contact contact) {
    final messageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Message to ${contact.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Message',
                icon: Icon(Icons.message),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Message sent to ${contact.name}')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
