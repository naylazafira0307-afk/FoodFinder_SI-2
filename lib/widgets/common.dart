import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../theme.dart';
import '../utils/format.dart';

/// Kembali ke halaman utama lalu pindah ke tab tertentu
/// (0 Katalog, 1 Keranjang, 2 Jual, 3 Pesanan, 4 Profil).
void keTab(BuildContext context, int tab) {
  Navigator.of(context).popUntil((r) => r.isFirst);
  app.setTab(tab);
}

/// Logo Lapakos (dipakai di halaman login).
class LapakosLogo extends StatelessWidget {
  const LapakosLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(color: AppColors.yellow, offset: Offset(0, 6)),
            ],
          ),
          child: const Icon(Icons.recycling, size: 46, color: AppColors.yellow),
        ),
        const SizedBox(height: 14),
        Transform.rotate(
          angle: -0.05,
          child: const Text(
            'Lapakos',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.brown,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Lapaknya Anak Kos',
            style: TextStyle(
              color: AppColors.yellow,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Barang bekas berkualitas untuk anak kos & rumah tangga',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.brown, fontSize: 13),
        ),
      ],
    );
  }
}

/// Gambar barang (ilustrasi: ikon + warna kategori).
class ProductImage extends StatelessWidget {
  final Product p;
  final double iconSize;
  final double radius;
  const ProductImage(this.p, {super.key, this.iconSize = 48, this.radius = 12});

  @override
  Widget build(BuildContext context) {
    final c = p.kategori.color;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [c.withOpacity(.18), c.withOpacity(.38)],
              ),
            ),
            child: Center(
              child: Icon(p.icon, size: iconSize, color: c),
            ),
          ),
          if (p.sold)
            Container(
              color: Colors.black45,
              alignment: Alignment.center,
              child: const Text(
                'TERJUAL',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Label kecil berwarna.
class LabelChip extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  const LabelChip(this.text, this.color, {super.key, this.fontSize = 10});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class KondisiChip extends StatelessWidget {
  final String kondisi;
  const KondisiChip(this.kondisi, {super.key});

  @override
  Widget build(BuildContext context) => LabelChip(
    kondisi,
    kondisi == 'Seperti Baru' ? AppColors.green : const Color(0xFF6D6D6D),
  );
}

class StatusChip extends StatelessWidget {
  final int status;
  const StatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final s = statusList[status];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: s.color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        s.label,
        style: TextStyle(
          color: s.color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Judul bagian (section).
class SectionTitle extends StatelessWidget {
  final String text;
  final EdgeInsets padding;
  const SectionTitle(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.fromLTRB(0, 18, 0, 8),
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.brown,
      ),
    ),
  );
}

/// Kartu putih membulat.
class WhiteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final VoidCallback? onTap;
  final Border? border;
  const WhiteCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: border,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Pilihan radio (kurir, metode bayar, alasan refund).
class PilihanTile extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailing;
  const PilihanTile({
    super.key,
    required this.selected,
    required this.onTap,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFBECEB) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFD5DBD9),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.primary : Colors.black54),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  trailing!,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppColors.primary : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

/// Baris rincian pembayaran: "Subtotal ...... Rp100.000"
class BarisRincian extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const BarisRincian(this.label, this.value, {super.key, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final st = TextStyle(
      fontSize: bold ? 16 : 14,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: st)),
          Text(value, style: st),
        ],
      ),
    );
  }
}

/// Bar putih di bawah layar (tempat tombol utama).
class BottomBar extends StatelessWidget {
  final Widget child;
  const BottomBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEF1F0))),
      ),
      padding: const EdgeInsets.all(12),
      child: SafeArea(top: false, child: child),
    );
  }
}

/// Panel perbandingan harga baru vs preloved.
class HargaBanding extends StatelessWidget {
  final Product p;
  const HargaBanding(this.p, {super.key});

  @override
  Widget build(BuildContext context) {
    final st = standarHarga[p.kondisi]!;
    Widget bar(String label, double fraksi, String nilai, bool coret) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: coret ? Colors.black87 : AppColors.primary,
                  fontWeight: coret ? FontWeight.w400 : FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: fraksi,
                  minHeight: 9,
                  backgroundColor: const Color(0xFFF0E6E4),
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(
              width: 82,
              child: Text(
                nilai,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: coret ? FontWeight.w400 : FontWeight.w700,
                  decoration: coret ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0D6D1), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.compare_arrows,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              const Expanded(
                child: Text(
                  'Perbandingan Harga',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.yellow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Hemat ${p.hemat}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onYellow,
                  ),
                ),
              ),
            ],
          ),
          bar('Harga Baru', 1, rp(p.asli!), true),
          bar('Preloved', (100 - p.hemat) / 100, rp(p.harga), false),
          const SizedBox(height: 6),
          Text(
            'Kamu hemat ${rp(p.asli! - p.harga)} • Harga wajar untuk kondisi '
            '${p.kondisi.toLowerCase()} (${(st.min * 100).round()}–${(st.max * 100).round()}% harga baru)',
            style: const TextStyle(fontSize: 12, color: AppColors.brown),
          ),
        ],
      ),
    );
  }
}

/// Dialog info Jaminan Uang Kembali.
void showJaminan(BuildContext context) {
  showDialog(
    context: context,
    builder: (c) => AlertDialog(
      icon: const Icon(Icons.verified_user, size: 48, color: AppColors.green),
      title: const Text('Jaminan Uang Kembali'),
      content: const SingleChildScrollView(
        child: Text(
          'Uang kembali 100% jika barang yang kamu terima tidak sesuai:\n'
          '• Rusak / tidak berfungsi\n'
          '• Berbeda dari foto atau deskripsi\n'
          '• Kondisi lebih buruk dari yang tertulis\n'
          '• Barang kurang / tidak lengkap\n\n'
          'Syarat:\n'
          '• Wajib video unboxing tanpa jeda, dari paket masih tertutup\n'
          '• Diajukan maks. 2×24 jam setelah barang sampai, sebelum menekan "Pesanan Diterima"\n'
          '• Barang dikembalikan ke penjual\n'
          '• Berlaku untuk pembayaran lewat aplikasi (tidak termasuk COD)',
          style: TextStyle(height: 1.5),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(c),
          child: const Text('Mengerti'),
        ),
      ],
    ),
  );
}

/// Dialog konfirmasi sederhana. Return true kalau user menekan tombol utama.
Future<bool> konfirmasiDialog(
  BuildContext context, {
  required String title,
  required String body,
  String ok = 'Ya',
  String batal = 'Batal',
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: Text(batal),
        ),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(ok)),
      ],
    ),
  );
  return r ?? false;
}
