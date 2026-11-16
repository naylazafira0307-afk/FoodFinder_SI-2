import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';

/// Ajukan Uang Kembali (dengan video unboxing).
class RefundPage extends StatefulWidget {
  final Order order;
  const RefundPage({super.key, required this.order});

  @override
  State<RefundPage> createState() => _RefundPageState();
}

class _RefundPageState extends State<RefundPage> {
  int? _alasan;
  String? _video; // nama file video (simulasi)
  final _ket = TextEditingController();

  @override
  void dispose() {
    _ket.dispose();
    super.dispose();
  }

  void _kirim() {
    if (_alasan == null) return snack(context, 'Pilih alasan pengembalian');
    if (_video == null) return snack(context, 'Video unboxing wajib diupload');
    if (_ket.text.trim().length < 10) {
      return snack(context, 'Keterangan minimal 10 karakter');
    }
    app.ajukanRefund(
        widget.order, alasanRefund[_alasan!], _ket.text.trim(), _video!);
    snack(context, 'Pengajuan terkirim, admin akan meninjau dalam 3×24 jam');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    return Scaffold(
      appBar: AppBar(title: const Text('Ajukan Uang Kembali')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          WhiteCard(
            child: Row(children: [
              const Icon(Icons.verified_user, size: 28, color: AppColors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Kamu akan menerima ${rp(o.total)} kembali jika pengajuan disetujui. Pesanan ${o.id}.',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ]),
          ),
          const SectionTitle('Alasan Pengembalian'),
          ...List.generate(alasanRefund.length, (i) => PilihanTile(
                selected: _alasan == i,
                onTap: () => setState(() => _alasan = i),
                icon: Icons.report,
                title: alasanRefund[i],
              )),
          const SectionTitle('Video Unboxing *'),
          if (_video != null)
            WhiteCard(
              padding: const EdgeInsets.all(8),
              child: Column(children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                      color: const Color(0xFF222222),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Center(
                      child: Icon(Icons.play_circle,
                          size: 52, color: Colors.white)),
                ),
                Row(children: [
                  const Icon(Icons.check_circle,
                      size: 15, color: AppColors.green),
                  const SizedBox(width: 4),
                  Expanded(
                      child: Text(_video!,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.green))),
                  TextButton(
                      onPressed: () => setState(() => _video = null),
                      child: const Text('Ganti')),
                ]),
              ]),
            )
          else ...[
            WhiteCard(
              padding: const EdgeInsets.all(20),
              border: Border.all(color: AppColors.border, width: 1.5),
              // Untuk upload video asli, pakai package image_picker (pickVideo).
              onTap: () =>
                  setState(() => _video = 'unboxing_${o.id}.mp4 (simulasi)'),
              child: const Column(children: [
                Icon(Icons.video_call, size: 44, color: AppColors.primary),
                SizedBox(height: 6),
                Text('Upload video unboxing',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text('Tanpa jeda, dari paket masih tersegel sampai barang dicek',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.grey)),
              ]),
            ),
            TextButton(
              onPressed: () => setState(
                  () => _video = 'unboxing_demo.mp4 (contoh)'),
              child: const Text('Belum punya video? Pakai video contoh (demo)'),
            ),
          ],
          const SectionTitle('Keterangan'),
          TextField(
            controller: _ket,
            maxLines: 3,
            decoration: const InputDecoration(
                hintText:
                    'Jelaskan masalahnya, misal: tombol rice cooker tidak menyala'),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(
        child: FilledButton(
            onPressed: _kirim, child: const Text('Kirim Pengajuan')),
      ),
    );
  }
}
