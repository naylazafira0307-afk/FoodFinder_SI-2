import 'package:flutter/material.dart';

import 'pages/login/login_page.dart';
import 'theme.dart';

void main() {
  runApp(const LapakosApp());
}

class LapakosApp extends StatelessWidget {
  const LapakosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lapakos',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      // Halaman pertama: Login. Setelah login berhasil -> HomeShell (5 tab).
      home: const LoginPage(),
    );
  }
}
