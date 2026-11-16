import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';
import '../pesanan/lacak_page.dart';

class SuksesPage extends StatelessWidget {
  final Order order;
  const SuksesPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle,
                      size: 90, color: Color(0xFF43A047)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Pembayaran Berhasil!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary)),
              const SizedBox(height: 8),
              Text(
                '${rp(order.total)} via ${order.metode}\nPesanan ${order.id} sedang dikemas penjual.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.grey, height: 1.5),
              ),
              const SizedBox(height: 12),
              Text('No. Resi: ${order.resi}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => LacakPage(order: order))),
                icon: const Icon(Icons.local_shipping),
                label: const Text('Lacak Pesanan'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => keTab(context, 0),
                child: const Text('Kembali ke Katalog'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
