import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';
import '../chat/chat_page.dart';
import '../keranjang/checkout_page.dart';

class DetailPage extends StatelessWidget {
  final String productId;
  const DetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        final p = app.product(productId);
        if (p == null) {
          return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Barang sudah dihapus')));
        }
        final c = p.kategori.color;
        final diKeranjang = app.cart.contains(p.id);

        Widget bawah;
        if (p.mine) {
          bawah = const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Ini barang yang kamu jual.',
                textAlign: TextAlign.center),
          );
        } else if (p.sold) {
          bawah = const FilledButton(
              onPressed: null, child: Text('Barang sudah terjual'));
        } else {
          bawah = Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  if (diKeranjang) {
                    keTab(context, 1);
                  } else {
                    app.addCart(p.id);
                    snack(context, 'Ditambahkan ke keranjang');
                  }
                },
                icon: Icon(diKeranjang
                    ? Icons.shopping_cart
                    : Icons.add_shopping_cart),
                label: Text(diKeranjang ? 'Lihat Keranjang' : 'Keranjang'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CheckoutPage(ids: [p.id]))),
                child: const Text('Beli Sekarang'),
              ),
            ),
          ]);
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Detail Barang')),
          body: ListView(children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        height: 260,
                        child: ProductImage(p, iconSize: 90)),
                    if (p.asli != null) HargaBanding(p),
                    const SizedBox(height: 8),
                    // indikator jumlah foto
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        p.jumlahFoto < 1 ? 1 : p.jumlahFoto,
                        (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == 0 ? 18 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: i == 0
                                ? AppColors.primary
                                : const Color(0xFFDDDDDD),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(rp(p.harga),
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                    if (p.asli != null)
                      Row(children: [
                        Text(rp(p.asli!),
                            style: const TextStyle(
                                color: AppColors.grey,
                                decoration: TextDecoration.lineThrough)),
                        const SizedBox(width: 8),
                        Text('Hemat ${p.hemat}%',
                            style: const TextStyle(
                                color: AppColors.red,
                                fontWeight: FontWeight.w600)),
                      ]),
                    const SizedBox(height: 8),
                    Text(p.nama,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(children: [
                      KondisiChip(p.kondisi),
                      const SizedBox(width: 8),
                      LabelChip(p.kategori.label, c),
                    ]),
                  ]),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.white,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Text(p.penjual[0].toUpperCase(),
                      style: const TextStyle(color: AppColors.primary)),
                ),
                title: Text(p.penjual),
                subtitle: Row(children: [
                  const Icon(Icons.location_on, size: 14),
                  Expanded(
                      child: Text(p.lokasi,
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
                trailing: p.mine
                    ? null
                    : OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8)),
                        onPressed: () {
                          app.openChat(p);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      ChatPage(productId: p.id)));
                        },
                        icon: const Icon(Icons.chat, size: 18),
                        label: const Text('Chat'),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Deskripsi',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(p.desk,
                        style: const TextStyle(fontSize: 14, height: 1.5)),
                    const SizedBox(height: 16),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.verified_user,
                              color: Colors.green, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => showJaminan(context),
                              child: const Text.rich(TextSpan(
                                style: TextStyle(fontSize: 12),
                                children: [
                                  TextSpan(
                                      text: 'Jaminan uang kembali',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700)),
                                  TextSpan(
                                      text:
                                          ' jika barang tidak sesuai, dengan bukti video unboxing. '),
                                  TextSpan(
                                      text: 'Selengkapnya',
                                      style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600)),
                                ],
                              )),
                            ),
                          ),
                        ]),
                  ]),
            ),
            const SizedBox(height: 24),
          ]),
          bottomNavigationBar: BottomBar(child: bawah),
        );
      },
    );
  }
}
