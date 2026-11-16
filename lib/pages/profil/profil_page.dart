import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';
import '../login/login_page.dart';
import 'alamat_page.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  void _tentang(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        icon: const Icon(Icons.recycling, size: 40, color: AppColors.primary),
        title: const Text('Lapakos'),
        content: const Text(
            'Versi 1.0.0 (prototype)\n\nMarketplace barang preloved untuk anak kos & rumah tangga: elektronik, perabot kamar, sepatu, dan pakaian.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('Tutup')),
        ],
      ),
    );
  }

  void _keluar(BuildContext context) {
    app.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        final u = app.user;
        if (u == null) return const SizedBox();
        final utama = app.alamatUtama;

        Widget stat(String label, int v, int tab) => Expanded(
              child: InkWell(
                onTap: () => app.setTab(tab),
                child: Column(children: [
                  Text('$v',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700)),
                  Text(label, style: const TextStyle(color: AppColors.grey)),
                ]),
              ),
            );

        Widget menu(IconData i, String t, String? sub, VoidCallback onTap) =>
            Container(
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF0F2F1)))),
              child: ListTile(
                leading: Icon(i, color: const Color(0xFF555555)),
                title: Text(t),
                subtitle: sub == null
                    ? null
                    : Text(sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: onTap,
              ),
            );

        return Scaffold(
          appBar: AppBar(title: const Text('Profil')),
          body: ListView(children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.primary,
                  child: Text(u.nama[0].toUpperCase(),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 28)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.nama,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        Text(u.email),
                        Text(u.hp,
                            style: const TextStyle(color: AppColors.grey)),
                      ]),
                ),
              ]),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(children: [
                stat('Pesanan', app.orders.length, 3),
                stat('Dijual', app.produkSaya.length, 2),
                stat('Keranjang', app.cart.length, 1),
              ]),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.white,
              child: Column(children: [
                menu(
                  Icons.location_on,
                  'Alamat Saya',
                  utama?.full ?? 'Belum ada alamat — tambah sekarang',
                  () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AlamatPage())),
                ),
                menu(Icons.verified_user, 'Jaminan Uang Kembali',
                    'Barang tidak sesuai? Uang kembali dengan video unboxing',
                    () => showJaminan(context)),
                menu(Icons.help, 'Bantuan', null,
                    () => snack(context, 'Hubungi CS Lapakos via WhatsApp')),
                menu(Icons.info, 'Tentang Aplikasi', null,
                    () => _tentang(context)),
              ]),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.white,
              child: ListTile(
                leading: const Icon(Icons.logout, color: AppColors.red),
                title: const Text('Keluar',
                    style: TextStyle(color: AppColors.red)),
                onTap: () => _keluar(context),
              ),
            ),
          ]),
        );
      },
    );
  }
}
