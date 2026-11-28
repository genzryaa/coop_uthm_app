import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart'; // Generated via `flutterfire configure`
import 'pages/admin/admin_dashboard_page.dart';
import 'pages/auth/login_page.dart';
import 'pages/customer/customer_main_page.dart';
import 'providers/cart_provider.dart';
import 'providers/theme_locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeLocaleProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const UthmCoopApp(),
    ),
  );
}

class UthmCoopApp extends StatelessWidget {
  const UthmCoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<ThemeLocaleProvider>(context);

    return MaterialApp(
      title: 'Koperasi UTHM',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF003366), // UTHM Navy Blue theme
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF003366),
        brightness: Brightness.dark,
      ),
      home: const AuthGate(),
    );
  }
}

/// Automatically routes logged-in users to Admin or Customer pages
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = authSnapshot.data;
        if (user == null) {
          return const LoginPage();
        }

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final data = roleSnapshot.data?.data() as Map<String, dynamic>?;
            final role = (data?['role'] ?? 'customer').toString().toLowerCase();

            if (role == 'admin') {
              return const AdminDashboardPage();
            }
            return const CustomerMainPage();
          },
        );
      },
    );
  }
}