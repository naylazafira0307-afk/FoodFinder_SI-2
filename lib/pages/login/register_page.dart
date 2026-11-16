import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../theme.dart';
import '../../utils/format.dart';

/// Halaman daftar akun. Jika berhasil, kembali ke Login membawa email baru.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nama = TextEditingController();
  final _email = TextEditingController();
  final _hp = TextEditingController();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  bool _setuju = false;
  bool _lihatPw = false;
  bool _lihatPw2 = false;

  @override
  void dispose() {
    for (final c in [_nama, _email, _hp, _pw, _pw2]) {
      c.dispose();
    }
    super.dispose();
  }

  void _daftar() {
    final err = app.register(
      nama: _nama.text,
      email: _email.text,
      hp: _hp.text,
      pw: _pw.text,
      pw2: _pw2.text,
      setuju: _setuju,
    );
    if (err != null) {
      snack(context, err);
      return;
    }
    Navigator.pop(context, _email.text.trim().toLowerCase());
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      ),
    );
  }

  Widget _pwField(TextEditingController c, String label, IconData icon,
      bool lihat, VoidCallback toggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        obscureText: !lihat,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: IconButton(
            icon: Icon(lihat ? Icons.visibility_off : Icons.visibility),
            onPressed: toggle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Buat akun baru',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brown)),
          const Text('Mulai jual & beli barang preloved di sekitarmu.',
              style: TextStyle(color: AppColors.grey)),
          const SizedBox(height: 20),
          _field(_nama, 'Nama lengkap', Icons.person_outline),
          _field(_email, 'Email', Icons.mail_outline,
              type: TextInputType.emailAddress),
          _field(_hp, 'No. HP / WhatsApp', Icons.call_outlined,
              type: TextInputType.phone),
          _pwField(_pw, 'Password', Icons.lock_outline, _lihatPw,
              () => setState(() => _lihatPw = !_lihatPw)),
          _pwField(_pw2, 'Konfirmasi password', Icons.lock_reset, _lihatPw2,
              () => setState(() => _lihatPw2 = !_lihatPw2)),
          CheckboxListTile(
            value: _setuju,
            onChanged: (v) => setState(() => _setuju = v ?? false),
            title: const Text('Saya menyetujui syarat & ketentuan',
                style: TextStyle(fontSize: 13)),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          FilledButton(onPressed: _daftar, child: const Text('Daftar')),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('Sudah punya akun?'),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Masuk')),
          ]),
        ],
      ),
    );
  }
}
