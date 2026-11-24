import 'package:flutter/material.dart';
import '../data/coop_data.dart';
import 'main_shell.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameCtrl = TextEditingController();
  final _matricCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buyer Registration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Register for Coop Self-Checkout',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _matricCtrl,
              decoration: const InputDecoration(
                labelText: 'Matric / Staff ID (e.g. AI220145)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'UTHM Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                if (_nameCtrl.text.isNotEmpty) {
                  coopState.currentUserName =
                      '${_nameCtrl.text} (${_matricCtrl.text.isEmpty ? "UTHM" : _matricCtrl.text})';
                }
                if (_emailCtrl.text.isNotEmpty) {
                  coopState.currentUserEmail = _emailCtrl.text;
                }
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainNavigationShell(),
                  ),
                  (route) => false,
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Register & Enter Store'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}