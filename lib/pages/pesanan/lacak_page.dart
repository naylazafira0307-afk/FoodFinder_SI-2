import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';
import '../keranjang/pembayaran_page.dart';
import 'refund_page.dart';

/// Halaman Lacak Pesanan: status, posisi paket, info pengiriman, riwayat.
class LacakPage extends StatelessWidget {
  final Order order;
  const LacakPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        final o = order;
        final s = statusList[o.status];
        return Scaffold(
          appBar: AppBar(title: const Text('Lacak Pesanan')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Banner status
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: s.color, borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  Icon(s.icon, size: 40, color: Colors.white),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.label,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(s.ket,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ]),
                  ),
                ]),
              ),
              if (o.status == 3 && o.refund == null)
                WhiteCard(
                  margin: const EdgeInsets.only(top: 12),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                  child: const Row(children: [
                    Icon(Icons.videocam, size: 32, color: AppColors.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Rekam video unboxing!\nRekam dari paket masih tertutup sampai barang dicek. Video ini wajib untuk klaim uang kembali.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ]),
                ),
              if (o.refund != null) _kartuRefund(o),
              const SizedBox(height: 16),
              WhiteCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: _langkah(o),
              ),
              if (o.status > 0 && o.kurir.ongkir > 0) ...[
                const SizedBox(height: 12),
                WhiteCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Posisi Paket',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        _rute(o),
                        Row(children: [
                          Expanded(
                              child: Text(o.items.first.lokasi,
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.grey))),
                          const Text('Alamatmu',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.grey)),
                        ]),
                      ]),
                ),
              ],
              const SizedBox(height: 12),
              WhiteCard(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Info Pengiriman',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      _info(Icons.local_shipping, 'Kurir',
                          '${o.kurir.nama} • ${o.kurir.est}'),
                      _info(Icons.qr_code, 'No. Resi',
                          o.resi ?? 'Muncul setelah dibayar',
                          aksi: o.resi == null
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.content_copy,
                                      size: 18, color: AppColors.primary),
                                  onPressed: () {
                                    Clipboard.setData(
                                        ClipboardData(text: o.resi!));
                                    snack(context, 'No. resi disalin');
                                  },
                                )),
                      _info(Icons.payments, 'Metode Pembayaran',
                          o.metode ?? 'Belum dibayar'),
                      _info(Icons.person, 'Penerima', o.penerima),
                      _info(Icons.location_on, 'Alamat Pengiriman', o.alamat,
                          terakhir: true),
                    ]),
              ),
              const SectionTitle('Riwayat Perjalanan'),
              WhiteCard(child: _timeline(o)),
              SectionTitle('Barang (${o.items.length})'),
              WhiteCard(
                padding: EdgeInsets.zero,
                child: Column(children: [
                  ...o.items.map((p) => ListTile(
                        leading: SizedBox(
                            width: 44,
                            height: 44,
                            child: ProductImage(p, iconSize: 22, radius: 8)),
                        title: Text(p.nama),
                        subtitle: Text(p.penjual),
                        trailing: Text(rp(p.harga)),
                      )),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: BarisRincian('Total dibayar', rp(o.total),
                        bold: true),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
            ],
          ),
          bottomNavigationBar: BottomBar(child: _aksi(context, o)),
        );
      },
    );
  }

  // ---------- tombol bawah sesuai status ----------
  Widget _aksi(BuildContext context, Order o) {
    if (o.status == 0) {
      return FilledButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => PembayaranPage(order: o))),
        child: const Text('Bayar Sekarang'),
      );
    }
    if (o.status < 3) {
      return OutlinedButton.icon(
        onPressed: () => app.majukan(o),
        icon: const Icon(Icons.fast_forward),
        label: const Text('Simulasikan Update Status (Demo)'),
      );
    }
    if (o.status == 3 && o.refund != null) {
      return OutlinedButton.icon(
        onPressed: () => _keputusanAdmin(context, o),
        icon: const Icon(Icons.fast_forward),
        label: const Text('Simulasi Keputusan Admin'),
      );
    }
    if (o.status == 3) {
      return Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => RefundPage(order: o))),
            icon: const Icon(Icons.undo),
            label: const Text('Uang Kembali'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton.icon(
            onPressed: () async {
              final ok = await konfirmasiDialog(
                context,
                title: 'Konfirmasi Pesanan Diterima',
                body:
                    'Pastikan barang sudah kamu cek dan sesuai. Setelah dikonfirmasi, pengajuan uang kembali tidak bisa dilakukan lagi.',
                ok: 'Ya, Diterima',
              );
              if (ok) app.majukan(o);
            },
            icon: const Icon(Icons.check),
            label: const Text('Diterima'),
          ),
        ),
      ]);
    }
    return FilledButton(
      style: FilledButton.styleFrom(
          backgroundColor: AppColors.yellow,
          foregroundColor: AppColors.onYellow),
      onPressed: () => keTab(context, 0),
      child: const Text('Belanja Lagi'),
    );
  }

  void _keputusanAdmin(BuildContext context, Order o) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Simulasi Keputusan Admin'),
        content: const Text('Pilih hasil peninjauan video unboxing:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              app.putuskanRefund(o, false);
            },
            child: const Text('Ditolak'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(c);
              app.putuskanRefund(o, true);
            },
            child: const Text('Disetujui'),
          ),
        ],
      ),
    );
  }

  // ---------- 5 langkah status ----------
  Widget _langkah(Order o) {
    const abu = Color(0xFFE0E0E0);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(statusList.length, (i) {
        final on = i <= o.status;
        final cur = i == o.status;
        final sz = cur ? 38.0 : 30.0;
        return Expanded(
          child: Column(children: [
            SizedBox(
              height: 38,
              child: Row(children: [
                Expanded(
                    child: Container(
                        height: 3,
                        color: i == 0
                            ? Colors.transparent
                            : (i <= o.status ? AppColors.primary : abu))),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: sz,
                  height: sz,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: on ? AppColors.primary : abu,
                    boxShadow: cur
                        ? [
                            BoxShadow(
                                color: AppColors.primary.withOpacity(.5),
                                blurRadius: 8)
                          ]
                        : null,
                  ),
                  child: Icon(statusList[i].icon,
                      size: cur ? 20 : 16,
                      color: on ? Colors.white : Colors.grey),
                ),
                Expanded(
                    child: Container(
                        height: 3,
                        color: i == statusList.length - 1
                            ? Colors.transparent
                            : (i < o.status ? AppColors.primary : abu))),
              ]),
            ),
            const SizedBox(height: 6),
            Text(statusList[i].pendek,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: cur ? FontWeight.w700 : FontWeight.w400,
                  color: on ? const Color(0xFF222222) : Colors.grey,
                )),
          ]),
        );
      }),
    );
  }

  // ---------- garis posisi kurir (animasi) ----------
  Widget _rute(Order o) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final kiri = (w - 36) * o.progres;
      const dur = Duration(milliseconds: 600);
      return SizedBox(
        height: 56,
        child: Stack(children: [
          Positioned(
              left: 18,
              right: 18,
              top: 17,
              child: Container(height: 3, color: const Color(0xFFE0E0E0))),
          AnimatedPositioned(
              duration: dur,
              left: 18,
              top: 17,
              width: kiri,
              child: Container(height: 3, color: AppColors.primary)),
          const Positioned(
              left: 2,
              top: 4,
              child: Icon(Icons.storefront, size: 30, color: Colors.orange)),
          const Positioned(
              right: 2,
              top: 4,
              child: Icon(Icons.home, size: 30, color: Color(0xFF43A047))),
          AnimatedPositioned(
            duration: dur,
            curve: Curves.easeInOut,
            left: kiri,
            top: 0,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary,
              child: Icon(o.kurir.icon, size: 20, color: Colors.white),
            ),
          ),
        ]),
      );
    });
  }

  Widget _info(IconData i, String label, String nilai,
      {Widget? aksi, bool terakhir = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: terakhir
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF1E6E4))),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              color: const Color(0xFFFBECEB),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(i, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(fontSize: 12, color: AppColors.grey)),
            Text(nilai,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500, height: 1.45)),
          ]),
        ),
        if (aksi != null) aksi,
      ]),
    );
  }

  Widget _timeline(Order o) {
    return Column(
      children: List.generate(o.riwayat.length, (i) {
        final r = o.riwayat[i];
        final terakhir = i == o.riwayat.length - 1;
        return IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(
              width: 24,
              child: Column(children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == 0 ? AppColors.primary : const Color(0xFFBBBBBB),
                  ),
                ),
                if (!terakhir)
                  Expanded(
                      child:
                          Container(width: 2, color: const Color(0xFFE0E0E0))),
              ]),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.judul,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: i == 0
                                  ? AppColors.primary
                                  : const Color(0xFF222222))),
                      const SizedBox(height: 2),
                      Text(r.ket, style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(fw(r.w),
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.grey)),
                    ]),
              ),
            ),
          ]),
        );
      }),
    );
  }

  Widget _kartuRefund(Order o) {
    final r = o.refund!;
    final c = {
      'Diproses': const Color(0xFFE08A00),
      'Disetujui': AppColors.green,
      'Ditolak': const Color(0xFFC62828),
    }[r.status]!;
    return WhiteCard(
      margin: const EdgeInsets.only(top: 12),
      border: Border.all(color: c, width: 1.5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.undo, size: 18, color: c),
          const SizedBox(width: 6),
          const Expanded(
              child: Text('Pengajuan Uang Kembali',
                  style: TextStyle(fontWeight: FontWeight.w700))),
          LabelChip(r.status, c, fontSize: 11),
        ]),
        const SizedBox(height: 6),
        Text('Alasan: ${r.alasan}\nKeterangan: ${r.ket}\nVideo: ${r.video}',
            style: const TextStyle(fontSize: 12)),
        if (r.status == 'Disetujui')
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('${rp(o.total)} dikembalikan ke ${o.metode}',
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.green,
                    fontWeight: FontWeight.w600)),
          ),
      ]),
    );
  }
}
