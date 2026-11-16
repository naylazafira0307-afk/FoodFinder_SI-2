import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';
import 'sukses_page.dart';

class PembayaranPage extends StatefulWidget {
  final Order order;
  const PembayaranPage({super.key, required this.order});

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  int? _metode;

  Future<void> _bayar() async {
    final m = metodeList[_metode!];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(children: [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Text('Memproses pembayaran...'),
        ]),
      ),
    );
    await app.bayar(widget.order, m);
    if (!mounted) return;
    Navigator.pop(context); // tutup loading
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => SuksesPage(order: widget.order)));
  }

  Widget _caraBayar(MetodeBayar m, int tot) {
    Widget isi;
    if (m.grup == 'Transfer Bank') {
      final va = (m.nama.startsWith('BCA') ? '3901 ' : '8808 ') +
          (app.user?.hp ?? '');
      isi = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Nomor Virtual Account',
            style: TextStyle(fontSize: 12, color: AppColors.grey)),
        const SizedBox(height: 4),
        Text(va,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        const Text(
            '1. Buka m-banking\n2. Pilih Transfer > Virtual Account\n3. Masukkan nomor di atas & konfirmasi',
            style: TextStyle(fontSize: 12, height: 1.6)),
      ]);
    } else if (m.nama == 'QRIS') {
      isi = const Center(
        child: Column(children: [
          Icon(Icons.qr_code_2, size: 160),
          Text('Scan QR di atas untuk membayar',
              style: TextStyle(fontSize: 12)),
        ]),
      );
    } else if (m.grup == 'E-Wallet') {
      isi = Text(
          'Kamu akan diarahkan ke aplikasi ${m.nama} untuk menyelesaikan pembayaran ${rp(tot)}.',
          style: const TextStyle(fontSize: 13));
    } else {
      isi = Text(
          'Siapkan uang tunai ${rp(tot)} dan bayarkan ke kurir saat barang sampai.',
          style: const TextStyle(fontSize: 13));
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(14)),
      child: isi,
    );
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final tot = o.total;
    final batas = o.dibuat.add(const Duration(days: 1));
    final m = _metode == null ? null : metodeList[_metode!];
    final label = m == null
        ? 'Pilih metode pembayaran'
        : m.nama.contains('COD')
            ? 'Konfirmasi Pesanan COD'
            : 'Bayar Sekarang • ${rp(tot)}';

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.brown]),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID Pesanan: ${o.id}',
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 6),
                  const Text('Total Pembayaran',
                      style: TextStyle(color: Colors.white)),
                  Text(rp(tot),
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.yellow)),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.timer, size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text('Bayar sebelum ${fw(batas)}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white)),
                  ]),
                ]),
          ),
          const SectionTitle('Pilih Metode Pembayaran'),
          ...List.generate(metodeList.length, (i) {
            final x = metodeList[i];
            return PilihanTile(
              selected: _metode == i,
              onTap: () => setState(() => _metode = i),
              icon: x.icon,
              title: x.nama,
              subtitle: x.grup,
            );
          }),
          if (m != null) ...[
            const SectionTitle('Cara Bayar'),
            _caraBayar(m, tot),
          ],
          const SizedBox(height: 8),
          WhiteCard(
            child: Column(children: [
              BarisRincian('Subtotal barang', rp(o.subtotal)),
              BarisRincian('Ongkos kirim (${o.kurir.nama})',
                  o.kurir.ongkir > 0 ? rp(o.kurir.ongkir) : 'Gratis'),
              BarisRincian('Biaya layanan', rp(biayaLayanan)),
              const Divider(),
              BarisRincian('Total', rp(tot), bold: true),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(
        child: FilledButton(
          onPressed: m == null ? null : _bayar,
          child: Text(label),
        ),
      ),
    );
  }
}
