import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';
import '../katalog/detail_page.dart';
import 'upload_page.dart';

class JualPage extends StatelessWidget {
  const JualPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        final l = app.produkSaya;
        final tayang = l.where((p) => !p.sold).length;
        final terjual = l.length - tayang;

        Widget stat(String label, int v, Color c) => Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  Text('$v',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: c)),
                  Text(label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.25)),
                ]),
              ),
            );

        return Scaffold(
          appBar: AppBar(title: const Text('Jual Barang')),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.yellow,
            foregroundColor: AppColors.onYellow,
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const UploadPage())),
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Upload Barang'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
                      const Text('Punya barang yang sudah tidak terpakai?',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      const Text(
                          'Upload foto, tentukan harga, dan barangmu langsung tayang di katalog.',
                          style:
                              TextStyle(color: Colors.white, fontSize: 12)),
                      const SizedBox(height: 12),
                      Row(children: [
                        stat('Sedang\nDijual', tayang, AppColors.primary),
                        const SizedBox(width: 12),
                        stat('Sudah\nTerjual', terjual, AppColors.green),
                        const SizedBox(width: 12),
                        stat('Total\nBarang', l.length,
                            const Color(0xFFD98A00)),
                      ]),
                    ]),
              ),
              const SectionTitle('Barang yang Saya Jual'),
              if (l.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Column(children: [
                    Icon(Icons.sell, size: 64, color: Color(0xFFBBBBBB)),
                    SizedBox(height: 8),
                    Text('Kamu belum menjual barang apa pun',
                        style: TextStyle(color: AppColors.grey)),
                  ]),
                )
              else
                ...l.map((p) => WhiteCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => DetailPage(productId: p.id))),
                      child: Row(children: [
                        SizedBox(
                            width: 56,
                            height: 56,
                            child: ProductImage(p, iconSize: 26, radius: 8)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.nama,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                Text(rp(p.harga),
                                    style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700)),
                                Text(
                                    '${p.kategori.label} • ${p.sold ? 'Terjual' : 'Tayang'}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: p.sold
                                            ? const Color(0xFF43A047)
                                            : Colors.grey)),
                              ]),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'terjual') app.markSold(p);
                            if (v == 'hapus') app.deleteProduct(p);
                          },
                          itemBuilder: (_) => [
                            if (!p.sold)
                              const PopupMenuItem(
                                  value: 'terjual',
                                  child: ListTile(
                                      leading: Icon(Icons.sell),
                                      title: Text('Tandai terjual'))),
                            const PopupMenuItem(
                                value: 'hapus',
                                child: ListTile(
                                    leading: Icon(Icons.delete,
                                        color: AppColors.red),
                                    title: Text('Hapus',
                                        style:
                                            TextStyle(color: AppColors.red)))),
                          ],
                        ),
                      ]),
                    )),
            ],
          ),
        );
      },
    );
  }
}
