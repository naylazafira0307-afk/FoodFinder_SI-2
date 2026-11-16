import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';

/// Form upload barang jualan + saran harga wajar.
class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  int _jumlahFoto = 0; // simulasi foto (maks 5)
  String _kat = 'elektronik';
  int _kondisi = 0;
  final _nama = TextEditingController();
  final _harga = TextEditingController();
  final _asli = TextEditingController();
  final _lokasi = TextEditingController();
  final _desk = TextEditingController();
  String? _kecamatan;

  @override
  void initState() {
    super.initState();
    _pakaiAlamatUtama();
  }

  @override
  void dispose() {
    for (final c in [_nama, _harga, _asli, _lokasi, _desk]) {
      c.dispose();
    }
    super.dispose();
  }

  void _pakaiAlamatUtama() {
    final u = app.alamatUtama;
    if (u == null) return;
    _lokasi.text = u.jalan;
    _kecamatan = u.kecamatan;
  }

  void _tambahFoto() {
    // Untuk ambil foto asli dari galeri/kamera, tambahkan package image_picker.
    showModalBottomSheet(
      context: context,
      builder: (c) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Pilih dari Galeri (simulasi)'),
            onTap: () {
              Navigator.pop(c);
              setState(() => _jumlahFoto++);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Ambil Foto (simulasi kamera)'),
            onTap: () {
              Navigator.pop(c);
              setState(() => _jumlahFoto++);
            },
          ),
        ]),
      ),
    );
  }

  void _simpan() {
    final harga = angka(_harga.text);
    final asli = angka(_asli.text);
    final kondisi = kondisiList[_kondisi];

    if (_jumlahFoto == 0) return snack(context, 'Tambahkan minimal 1 foto barang');
    if (_nama.text.trim().length < 3) {
      return snack(context, 'Nama barang minimal 3 karakter');
    }
    if (harga < 1000) return snack(context, 'Harga jual minimal Rp1.000');
    if (asli == 0) {
      return snack(
          context, 'Isi harga beli dulu supaya harga wajarnya bisa dihitung');
    }
    final r = rentangHarga(asli, kondisi);
    if (harga > r.hi) {
      return snack(context, 'Terlalu mahal untuk kondisi $kondisi. Maksimal ${rp(r.hi)}');
    }
    if (harga < r.lo) {
      return snack(context, 'Terlalu murah untuk kondisi $kondisi. Minimal ${rp(r.lo)}');
    }
    if (_lokasi.text.trim().isEmpty) {
      return snack(context, 'Lokasi barang wajib diisi');
    }
    if (_kecamatan == null) return snack(context, 'Pilih kecamatan lokasi barang');
    if (_desk.text.trim().length < 10) {
      return snack(context, 'Deskripsi minimal 10 karakter');
    }

    final k = kategoriMap[_kat]!;
    app.addProduct(Product(
      id: 'U${DateTime.now().millisecondsSinceEpoch}',
      nama: _nama.text.trim(),
      kat: _kat,
      harga: harga,
      asli: asli,
      kondisi: kondisi,
      penjual: app.user!.nama,
      lokasi: 'Kec. $_kecamatan, Padang',
      icon: k.icon,
      desk: _desk.text.trim(),
      jumlahFoto: _jumlahFoto,
      mine: true,
    ));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        icon: const Icon(Icons.check_circle,
            size: 56, color: Color(0xFF43A047)),
        title: const Text('Barang Berhasil Diupload'),
        content: Text(
            '"${_nama.text.trim()}" sudah tayang di katalog kategori ${k.label}.',
            textAlign: TextAlign.center),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(c); // tutup dialog
              Navigator.pop(context); // kembali ke halaman Jual
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ---------- saran harga wajar ----------
  Widget _saranHarga() {
    final asli = angka(_asli.text);
    final harga = angka(_harga.text);
    final kondisi = kondisiList[_kondisi];
    const coklat = Color(0xFF7A5A12);

    final tabel = WhiteCard(
      margin: const EdgeInsets.only(top: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('📊 Standar harga wajar preloved',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ...kondisiList.map((x) {
          final st = standarHarga[x]!;
          final aktif = x == kondisi;
          final gaya = TextStyle(
              fontSize: 12,
              color: aktif ? AppColors.primary : Colors.black87,
              fontWeight: aktif ? FontWeight.w700 : FontWeight.w400);
          return Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(children: [
              Expanded(child: Text('${aktif ? '▸ ' : ''}$x', style: gaya)),
              Text('${(st.min * 100).round()}–${(st.max * 100).round()}% harga baru',
                  style: gaya),
            ]),
          );
        }),
        const SizedBox(height: 4),
        const Text(
            'Potongan maks. 60% supaya penjual tidak rugi, dan harga tetap jauh di bawah barang baru supaya pembeli juga untung.',
            style: TextStyle(fontSize: 12, color: AppColors.grey)),
      ]),
    );

    if (asli == 0) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text(
            '💡 Isi harga beli dulu untuk melihat harga wajar sesuai kondisi barang',
            style: TextStyle(fontSize: 12, color: coklat)),
        tabel,
      ]);
    }

    final r = rentangHarga(asli, kondisi);
    final saran = bulat5rb((r.lo + r.hi) / 2);
    Widget? peringatan;
    if (harga > 0 && harga > r.hi) {
      peringatan = _warn(
          'Terlalu mahal untuk kondisi ${kondisi.toLowerCase()} — pembeli rugi. Maksimal ${rp(r.hi)}.');
    } else if (harga > 0 && harga < r.lo) {
      peringatan = _warn(
          'Terlalu murah — kamu (penjual) rugi. Untuk kondisi ${kondisi.toLowerCase()}, minimal ${rp(r.lo)}.');
    } else if (harga > 0) {
      peringatan = Text(
          '✅ Harga wajar — penjual untung, pembeli hemat ${(100 - harga * 100 / asli).round()}%',
          style: const TextStyle(fontSize: 12, color: AppColors.green));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text('💡 Harga wajar untuk kondisi $kondisi: ${rp(r.lo)} – ${rp(r.hi)}',
            style: const TextStyle(fontSize: 12, color: coklat)),
        TextButton(
          style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: Size.zero),
          onPressed: () => setState(() => _harga.text = ribuan(saran)),
          child: Text('Pakai ${rp(saran)}', style: const TextStyle(fontSize: 12)),
        ),
      ]),
      if (peringatan != null) peringatan,
      tabel,
    ]);
  }

  Widget _warn(String t) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: const Color(0xFFFDECEA),
            borderRadius: BorderRadius.circular(10)),
        child: Text(t,
            style: const TextStyle(fontSize: 12, color: Color(0xFF9B1C1C))),
      );

  Widget _fotoKotak(int i) {
    final k = kategoriMap[_kat]!;
    return Container(
      width: 90,
      height: 90,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
          color: k.color.withOpacity(.2),
          borderRadius: BorderRadius.circular(12)),
      child: Stack(children: [
        Center(child: Icon(k.icon, size: 36, color: k.color)),
        if (i == 0)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: k.color,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: const Text('Utama',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: () => setState(() => _jumlahFoto--),
            child: const CircleAvatar(
              radius: 11,
              backgroundColor: Colors.black54,
              child: Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final k = kategoriMap[_kat]!;
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Barang Jualan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          SectionTitle('Foto Barang ($_jumlahFoto/5)'),
          SizedBox(
            height: 90,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              ...List.generate(_jumlahFoto, _fotoKotak),
              if (_jumlahFoto < 5)
                GestureDetector(
                  onTap: _tambahFoto,
                  child: Container(
                    width: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, color: AppColors.grey),
                          Text('Tambah',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.grey)),
                        ]),
                  ),
                ),
            ]),
          ),
          const SectionTitle('Kategori'),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: kategoriMap.values.map((v) {
              final on = _kat == v.key;
              return ChoiceChip(
                selected: on,
                showCheckmark: false,
                selectedColor: v.color,
                avatar: Icon(v.icon,
                    size: 18, color: on ? Colors.white : v.color),
                label: Text(v.label,
                    style: TextStyle(color: on ? Colors.white : Colors.black87)),
                onSelected: (_) => setState(() => _kat = v.key),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
          Text('Contoh: ${k.contoh}',
              style: const TextStyle(fontSize: 12, color: AppColors.grey)),
          const SectionTitle('Detail Barang'),
          TextField(
            controller: _nama,
            decoration: const InputDecoration(
                labelText: 'Nama barang',
                hintText: 'Contoh: Lemari plastik 3 susun'),
          ),
          const SizedBox(height: 12),
          const Text('Kondisi',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(kondisiList.length, (i) {
              return ChoiceChip(
                selected: _kondisi == i,
                selectedColor: AppColors.yellow,
                label: Text(kondisiList[i]),
                onSelected: (_) => setState(() => _kondisi = i),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _harga,
                keyboardType: TextInputType.number,
                inputFormatters: [RibuanFormatter()],
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                    labelText: 'Harga jual', prefixText: 'Rp '),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _asli,
                keyboardType: TextInputType.number,
                inputFormatters: [RibuanFormatter()],
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                    labelText: 'Harga beli dulu',
                    hintText: 'Wajib',
                    prefixText: 'Rp '),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          _saranHarga(),
          const SizedBox(height: 16),
          TextField(
            controller: _lokasi,
            decoration: const InputDecoration(
              labelText: 'Lokasi barang',
              hintText: 'Contoh: Jl. Limau Manis, dekat Unand',
              prefixIcon: Icon(Icons.location_on),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _kecamatan,
            decoration: const InputDecoration(labelText: 'Kecamatan'),
            items: kecamatanList
                .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                .toList(),
            onChanged: (v) => setState(() => _kecamatan = v),
          ),
          if (app.alamatUtama != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(_pakaiAlamatUtama),
                icon: const Icon(Icons.home, size: 16),
                label: const Text('Pakai alamat utama'),
              ),
            ),
          const SizedBox(height: 8),
          TextField(
            controller: _desk,
            maxLines: 4,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'Deskripsi',
              hintText:
                  'Jelaskan kondisi, lama pemakaian, minus/kekurangan, alasan dijual...',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(
        child: FilledButton.icon(
          onPressed: _simpan,
          icon: const Icon(Icons.upload),
          label: const Text('Upload & Tayangkan'),
        ),
      ),
    );
  }
}
