import 'package:flutter/material.dart';
import 'data/coop_data.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const CoopUthmApp());
}

class CoopUthmApp extends StatelessWidget {
  const CoopUthmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: coopState,
      builder: (context, _) {
        return MaterialApp(
          title: 'COOP UTHM Store',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF0D47A1),
            brightness: Brightness.light,
          ),  
          home: const LoginPage(),
        );
      },
    );
  }
}