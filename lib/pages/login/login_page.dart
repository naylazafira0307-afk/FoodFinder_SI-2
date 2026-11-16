import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';
import '../home_shell.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Akun demo sudah terisi
  final _email = TextEditingController(text: 'demo@kosmah.id');
  final _pw = TextEditingController(text: '123456');
  bool _hidePw = true;

  @override
  void dispose() {
    _email.dispose();
    _pw.dispose();
    super.dispose();
  }

  void _masuk() {
    final err = app.login(_email.text, _pw.text);
    if (err != null) {
      snack(context, err);
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeShell()),
      (_) => false,
    );
  }

  Future<void> _daftar() async {
    final email = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
    if (email != null && mounted) {
      _email.text = email;
      _pw.clear();
      snack(context, 'Akun berhasil dibuat. Silakan masuk.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            const LapakosLogo(),
            const SizedBox(height: 32),
            const Text('Masuk',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brown)),
            const SizedBox(height: 16),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pw,
              obscureText: _hidePw,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                      _hidePw ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _hidePw = !_hidePw),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => snack(
                    context, 'Fitur lupa password belum tersedia di prototype'),
                child: const Text('Lupa password?'),
              ),
            ),
            FilledButton(onPressed: _masuk, child: const Text('Masuk')),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Belum punya akun?'),
              TextButton(onPressed: _daftar, child: const Text('Daftar')),
            ]),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppColors.yellow,
                  borderRadius: BorderRadius.circular(12)),
              child: const Text('Akun demo: demo@kosmah.id / 123456',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.onYellow)),
            ),
          ],
        ),
      ),
    );
  }
}
