import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';
import '../profil/alamat_form_page.dart';
import '../profil/alamat_page.dart';
import 'pembayaran_page.dart';

/// Halaman Pemesanan (checkout): alamat, barang, kurir, catatan, rincian.
class CheckoutPage extends StatefulWidget {
  final List<String> ids;
  const CheckoutPage({super.key, required this.ids});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _kurir = 0;
  String? _addrId;
  final _catatan = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addrId = app.alamatUtama?.id;
  }

  @override
  void dispose() {
    _catatan.dispose();
    super.dispose();
  }

  Future<void> _pilihAlamat() async {
    final id = await Navigator.push<String>(
      context,
      MaterialPageRoute(
          builder: (_) => AlamatPage(pilihMode: true, terpilihId: _addrId)),
    );
    if (id != null) setState(() => _addrId = id);
  }

  Future<void> _tambahAlamat() async {
    final id = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const AlamatFormPage()),
    );
    if (id != null) setState(() => _addrId = id);
  }

  void _buatPesanan(Address? a) {
    if (a == null) {
      snack(context, 'Tambahkan alamat pengiriman dulu');
      return;
    }
    final o =
        app.buatPesanan(widget.ids, kurirList[_kurir], a, _catatan.text.trim());
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => PembayaranPage(order: o)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        final items =
            widget.ids.map((id) => app.product(id)).whereType<Product>().toList();
        final a = app.addressById(_addrId) ?? app.alamatUtama;
        final k = kurirList[_kurir];
        final sub = items.fold<int>(0, (s, p) => s + p.harga);
        final tot = sub + k.ongkir + biayaLayanan;

        return Scaffold(
          appBar: AppBar(title: const Text('Pemesanan')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              const SectionTitle('Alamat Pengiriman'),
              _kartuAlamat(a),
              SectionTitle('Barang Dipesan (${items.length})'),
              WhiteCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: items
                      .map((p) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            child: Row(children: [
                              SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: ProductImage(p,
                                      iconSize: 24, radius: 8)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(p.nama,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      Text(
                                          'Penjual: ${p.penjual} • ${p.kondisi}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.grey)),
                                    ]),
                              ),
                              Text(rp(p.harga),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                            ]),
                          ))
                      .toList(),
                ),
              ),
              const SectionTitle('Metode Pengiriman'),
              ...List.generate(kurirList.length, (i) {
                final x = kurirList[i];
                return PilihanTile(
                  selected: _kurir == i,
                  onTap: () => setState(() => _kurir = i),
                  icon: x.icon,
                  title: x.nama,
                  subtitle: x.est,
                  trailing: x.ongkir > 0 ? rp(x.ongkir) : 'Gratis',
                );
              }),
              const SectionTitle('Catatan untuk Penjual'),
              TextField(
                controller: _catatan,
                decoration: const InputDecoration(
                    hintText: 'Contoh: tolong dibungkus rapi ya (opsional)'),
              ),
              const SectionTitle('Rincian Pembayaran'),
              WhiteCard(
                child: Column(children: [
                  BarisRincian('Subtotal barang', rp(sub)),
                  BarisRincian('Ongkos kirim',
                      k.ongkir > 0 ? rp(k.ongkir) : 'Gratis'),
                  BarisRincian('Biaya layanan', rp(biayaLayanan)),
                  const Divider(),
                  BarisRincian('Total', rp(tot), bold: true),
                ]),
              ),
            ],
          ),
          bottomNavigationBar: BottomBar(
            child: Row(children: [
              Expanded(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Bayar',
                          style:
                              TextStyle(fontSize: 12, color: AppColors.grey)),
                      Text(rp(tot),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                    ]),
              ),
              FilledButton(
                  onPressed: () => _buatPesanan(a),
                  child: const Text('Buat Pesanan')),
            ]),
          ),
        );
      },
    );
  }

  Widget _kartuAlamat(Address? a) {
    if (a == null) {
      return WhiteCard(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Text('Belum ada alamat pengiriman',
              style: TextStyle(fontSize: 12, color: AppColors.grey)),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _tambahAlamat,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Alamat'),
          ),
        ]),
      );
    }
    return WhiteCard(
      onTap: _pilihAlamat,
      border: Border.all(color: AppColors.primary, width: 1.5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.location_on, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text.rich(TextSpan(children: [
              TextSpan(
                  text: a.nama,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              TextSpan(
                  text: '  |  ${a.hp}',
                  style: const TextStyle(color: AppColors.grey)),
            ])),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ]),
        Padding(
          padding: const EdgeInsets.only(left: 30, top: 4),
          child: Text(a.full, style: const TextStyle(fontSize: 13, height: 1.45)),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30, top: 6),
          child: Wrap(spacing: 6, children: [
            if (a.utama) const LabelChip('Utama', AppColors.primary, fontSize: 11),
            LabelChip(a.label, const Color(0xFF9A6A12), fontSize: 11),
          ]),
        ),
      ]),
    );
  }
}
