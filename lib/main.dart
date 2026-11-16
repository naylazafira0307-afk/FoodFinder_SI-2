<<<<<<< HEAD
import 'package:flutter/material.dart';

import 'data/app_state.dart';
import 'pages/katalog/katalog_page.dart';
import 'theme.dart';

void main() {
  app.login('demo@kosmah.id', '123456'); // login otomatis (sementara)
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
      home: const KatalogPage(),
    );
  }
}
=======
>>>>>>> a1c1edb1265624befc2926680df6147464e70468
