import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';

/// Form tambah / ubah alamat. Return id alamat saat disimpan.
class AlamatFormPage extends StatefulWidget {
  final Address? edit;
  const AlamatFormPage({super.key, this.edit});

  @override
  State<AlamatFormPage> createState() => _AlamatFormPageState();
}

class _AlamatFormPageState extends State<AlamatFormPage> {
  late final TextEditingController _nama;
  late final TextEditingController _hp;
  late final TextEditingController _jalan;
  late final TextEditingController _detail;
  String? _kecamatan;
  String _label = 'Rumah';
  bool _utama = false;

  bool get _isEdit => widget.edit != null;

  @override
  void initState() {
    super.initState();
    final a = widget.edit;
    final u = app.user!;
    _nama = TextEditingController(text: a?.nama ?? u.nama);
    _hp = TextEditingController(text: a?.hp ?? u.hp);
    _jalan = TextEditingController(text: a?.jalan ?? '');
    _detail = TextEditingController(text: a?.detail ?? '');
    _kecamatan = a?.kecamatan;
    _label = a?.label ?? 'Rumah';
    _utama = a?.utama ?? app.addresses.isEmpty;
  }

  @override
  void dispose() {
    for (final c in [_nama, _hp, _jalan, _detail]) {
      c.dispose();
    }
    super.dispose();
  }

  void _simpan() {
    if (_nama.text.trim().length < 2) {
      return snack(context, 'Nama penerima wajib diisi');
    }
    if (_hp.text.replaceAll(RegExp(r'\D'), '').length < 10) {
      return snack(context, 'Nomor telepon tidak valid (min. 10 digit)');
    }
    if (_kecamatan == null) return snack(context, 'Pilih kecamatan');
    if (_jalan.text.trim().length < 5) {
      return snack(context, 'Nama jalan / no. rumah wajib diisi');
    }
    final id = app.saveAddress(
      Address(
        label: _label,
        nama: _nama.text.trim(),
        hp: _hp.text.trim(),
        kecamatan: _kecamatan!,
        jalan: _jalan.text.trim(),
        detail: _detail.text.trim(),
        utama: _utama,
      ),
      editId: widget.edit?.id,
    );
    snack(context,
        _isEdit ? 'Alamat berhasil diubah' : 'Alamat baru berhasil ditambahkan');
    Navigator.pop(context, id);
  }

  Future<void> _hapus() async {
    final ok = await konfirmasiDialog(context,
        title: 'Hapus Alamat?',
        body: 'Alamat ini akan dihapus dari daftar alamatmu.',
        ok: 'Hapus');
    if (!ok || !mounted) return;
    final err = app.deleteAddress(widget.edit!.id);
    if (err != null) {
      snack(context, err);
      return;
    }
    snack(context, 'Alamat dihapus');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const ikonLabel = {
      'Rumah': Icons.home,
      'Kos': Icons.apartment,
      'Kantor': Icons.work,
    };
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Ubah Alamat' : 'Alamat Baru')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          const SectionTitle('Kontak'),
          TextField(
            controller: _nama,
            decoration: const InputDecoration(
                labelText: 'Nama Lengkap', hintText: 'Nama penerima paket'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _hp,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
                labelText: 'Nomor Telepon', hintText: '08xxxxxxxxxx'),
          ),
          const SectionTitle('Alamat'),
          const TextField(
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Provinsi, Kota',
              hintText: '$kProvinsi, $kKota',
              fillColor: Color(0xFFF5EFEE),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _kecamatan,
            decoration: const InputDecoration(labelText: 'Kecamatan'),
            hint: const Text('Pilih kecamatan'),
            items: kecamatanList
                .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                .toList(),
            onChanged: (v) => setState(() => _kecamatan = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _jalan,
            decoration: const InputDecoration(
                labelText: 'Nama Jalan, Gedung, No. Rumah',
                hintText: 'Contoh: Kos Melati No. 12, Jl. Limau Manis'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _detail,
            decoration: const InputDecoration(
                labelText: 'Detail Lainnya (opsional)',
                hintText: 'Cth: warna pagar, patokan, no. kamar'),
          ),
          const SectionTitle('Tandai Sebagai'),
          Wrap(
            spacing: 6,
            children: ikonLabel.entries.map((e) {
              return ChoiceChip(
                selected: _label == e.key,
                selectedColor: AppColors.yellow,
                avatar: Icon(e.value, size: 18),
                showCheckmark: false,
                label: Text(e.key),
                onSelected: (_) => setState(() => _label = e.key),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          WhiteCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _utama,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _utama = v),
              title: const Text('Atur sebagai Alamat Utama',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text('Dipakai otomatis saat checkout',
                  style: TextStyle(fontSize: 12)),
            ),
          ),
          if (_isEdit) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.red,
                side: const BorderSide(color: Color(0xFFF0C9C9)),
              ),
              onPressed: _hapus,
              icon: const Icon(Icons.delete),
              label: const Text('Hapus Alamat'),
            ),
          ],
        ],
      ),
      bottomNavigationBar: BottomBar(
        child: FilledButton(onPressed: _simpan, child: const Text('SIMPAN')),
      ),
    );
  }
}
