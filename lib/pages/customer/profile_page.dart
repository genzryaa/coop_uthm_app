import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_locale_provider.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _user = FirebaseAuth.instance.currentUser;

  void _showEditProfileDialog(String currentName, String currentPhone, String currentMatric) {
    final nameController = TextEditingController(text: currentName);
    final phoneController = TextEditingController(text: currentPhone);
    final matricController = TextEditingController(text: currentMatric);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: matricController,
                decoration: const InputDecoration(labelText: 'Matric / Staff ID (e.g., CI230001)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (_user != null) {
                await FirebaseFirestore.instance.collection('users').doc(_user!.uid).set({
                  'name': nameController.text.trim(),
                  'matricId': matricController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'email': _user!.email,
                }, SetOptions(merge: true));
              }
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<ThemeLocaleProvider>(context);
    final isBm = settingsProvider.locale.languageCode == 'ms';

    return Scaffold(
      appBar: AppBar(
        title: Text(isBm ? 'Profil Saya' : 'My Profile'),
      ),
      body: _user == null
          ? const Center(child: Text('Not logged in'))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(_user!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                final data = (snapshot.data?.data() as Map<String, dynamic>?) ?? {};
                final name = data['name'] ?? _user!.displayName ?? 'UTHM Student';
                final matricId = data['matricId'] ?? 'Not set';
                final phone = data['phone'] ?? 'Not set';
                final email = _user!.email ?? '';

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Top Profile Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(email, style: const TextStyle(fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text('ID: $matricId • $phone',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.secondary)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: 'Edit Profile',
                              onPressed: () =>
                                  _showEditProfileDialog(name, phone == 'Not set' ? '' : phone, matricId == 'Not set' ? '' : matricId),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Appearance & Language Settings
                    Text(
                      isBm ? 'Tetapan Aplikasi' : 'App Settings',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children: [
                          // Light / Dark Mode Switch
                          SwitchListTile(
                            secondary: Icon(
                              settingsProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                            ),
                            title: Text(isBm ? 'Mod Gelap' : 'Dark Mode'),
                            subtitle: Text(
                              settingsProvider.isDarkMode
                                  ? (isBm ? 'Aktif' : 'Enabled')
                                  : (isBm ? 'Mod Cerah' : 'Light Mode'),
                            ),
                            value: settingsProvider.isDarkMode,
                            onChanged: (val) => settingsProvider.toggleTheme(val),
                          ),
                          const Divider(height: 1),
                          // Dual Language Toggle (EN / BM)
                          ListTile(
                            leading: const Icon(Icons.language),
                            title: Text(isBm ? 'Bahasa' : 'Language'),
                            trailing: SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(value: 'en', label: Text('EN')),
                                ButtonSegment(value: 'ms', label: Text('BM')),
                              ],
                              selected: {settingsProvider.locale.languageCode},
                              onSelectionChanged: (newSelection) {
                                settingsProvider.setLocale(Locale(newSelection.first));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Logout Button
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.logout),
                      label: Text(isBm ? 'Log Keluar' : 'Logout'),
                      onPressed: _logout,
                    ),
                  ],
                );
              },
            ),
    );
  }
}