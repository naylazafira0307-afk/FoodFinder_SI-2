import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import 'alamat_form_page.dart';

/// Daftar alamat. Jika [pilihMode] true (dari checkout), tap alamat
/// akan mengembalikan id alamat yang dipilih.
class AlamatPage extends StatelessWidget {
  final bool pilihMode;
  final String? terpilihId;
  const AlamatPage({super.key, this.pilihMode = false, this.terpilihId});

  Future<void> _form(BuildContext context, [Address? edit]) async {
    final id = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => AlamatFormPage(edit: edit)),
    );
    // alamat baru dari mode pilih -> langsung dipakai untuk checkout
    if (id != null && pilihMode && edit == null && context.mounted) {
      Navigator.pop(context, id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        final l = app.addresses;
        return Scaffold(
          appBar: AppBar(title: Text(pilihMode ? 'Pilih Alamat' : 'Alamat Saya')),
          body: ListView(children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text('Alamat',
                  style: TextStyle(fontSize: 12, color: AppColors.grey)),
            ),
            if (l.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                child: Column(children: [
                  Icon(Icons.location_off, size: 64, color: Color(0xFFC9B5B2)),
                  SizedBox(height: 8),
                  Text('Belum ada alamat tersimpan',
                      style: TextStyle(color: AppColors.grey)),
                ]),
              ),
            ...l.map((a) => _item(context, a)),
            const SizedBox(height: 8),
            Material(
              color: Colors.white,
              child: InkWell(
                onTap: () => _form(context),
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text('Tambah Alamat Baru',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                      ]),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _item(BuildContext context, Address a) {
    final dipilih = terpilihId == a.id;
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () =>
            pilihMode ? Navigator.pop(context, a.id) : _form(context, a),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF0E4E2)))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (pilihMode)
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 2),
                child: Icon(
                  dipilih
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: dipilih ? AppColors.primary : Colors.grey,
                ),
              ),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text.rich(TextSpan(children: [
                          TextSpan(
                              text: a.nama,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          TextSpan(
                              text: '  |  ${a.hp}',
                              style: const TextStyle(color: AppColors.grey)),
                        ])),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(40, 24)),
                        onPressed: () => _form(context, a),
                        child: const Text('Ubah'),
                      ),
                    ]),
                    Text(
                        '${a.jalan}${a.detail.isNotEmpty ? ' (${a.detail})' : ''}',
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF555555))),
                    Text(
                        'KEC. ${a.kecamatan.toUpperCase()}, ${kKota.toUpperCase()}, ${kProvinsi.toUpperCase()}',
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF555555))),
                    const SizedBox(height: 6),
                    Wrap(spacing: 6, children: [
                      if (a.utama)
                        const LabelChip('Utama', AppColors.primary,
                            fontSize: 11),
                      LabelChip(a.label, const Color(0xFF9A6A12),
                          fontSize: 11),
                    ]),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }
}
