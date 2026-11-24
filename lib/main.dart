import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/coop_data.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await coopState.initFirestoreData();
  runApp(const CoopUthmApp());
}

class CoopUthmApp extends StatelessWidget {
  const CoopUthmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COOP UTHM Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE60000),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: const LoginPage(),
    );
  }
}