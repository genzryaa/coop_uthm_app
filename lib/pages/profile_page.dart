import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/coop_data.dart';
import 'login_page.dart';

class UserProfilePage extends StatelessWidget {
  final bool isAdmin;
  const UserProfilePage({super.key, this.isAdmin = false});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: coopState,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              isAdmin
                  ? 'COOP Staff ${coopState.tr('profile')}'
                  : coopState.tr('profile'),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFFE60000),
                        child: Icon(
                          isAdmin ? Icons.admin_panel_settings : Icons.person,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              coopState.currentUserName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              coopState.currentUserEmail.isEmpty
                                  ? 'student@uthm.edu.my'
                                  : coopState.currentUserEmail,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE60000)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isAdmin
                                    ? 'ROLE: COOP UTHM STAFF'
                                    : 'ROLE: UTHM BUYER',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE60000),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Theme Mode Selector (System / Light / Dark)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.brightness_6_outlined),
                          const SizedBox(width: 10),
                          Text(
                            coopState.tr('appearance'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ThemeMode>(
                          segments: [
                            ButtonSegment(
                              value: ThemeMode.system,
                              label: Text(coopState.tr('system_theme')),
                              icon: const Icon(Icons.settings_brightness),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              label: Text(coopState.tr('light_theme')),
                              icon: const Icon(Icons.light_mode),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              label: Text(coopState.tr('dark_theme')),
                              icon: const Icon(Icons.dark_mode),
                            ),
                          ],
                          selected: {coopState.themeMode},
                          onSelectionChanged: (selection) {
                            coopState.setThemeMode(selection.first);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Dual Language Selector (English / Bahasa Melayu)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.language),
                          const SizedBox(width: 10),
                          Text(
                            coopState.tr('language'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'en',
                              label: Text('English'),
                            ),
                            ButtonSegment(
                              value: 'ms',
                              label: Text('Bahasa Melayu'),
                            ),
                          ],
                          selected: {coopState.languageCode},
                          onSelectionChanged: (selection) {
                            coopState.setLanguage(selection.first);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _logout(context),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.logout),
                label: Text(coopState.tr('logout')),
              ),
            ],
          ),
        );
      },
    );
  }
}