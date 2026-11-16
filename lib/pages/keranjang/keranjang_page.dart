import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';
import '../katalog/detail_page.dart';
import 'checkout_page.dart';

class KeranjangPage extends StatelessWidget {
  const KeranjangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        final items = app.cart
            .map((id) => app.product(id))
            .whereType<Product>()
            .toList();

        if (items.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Keranjang (0)')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.shopping_cart,
                      size: 80, color: Color(0xFFBBBBBB)),
                  const SizedBox(height: 12),
                  const Text('Keranjangmu masih kosong',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  const Text('Yuk cari barang preloved incaranmu!',
                      style: TextStyle(color: AppColors.grey)),
                  const SizedBox(height: 16),
                  FilledButton(
                      onPressed: () => app.setTab(0),
                      child: const Text('Mulai Belanja')),
                ]),
              ),
            ),
          );
        }

        final total = items.fold<int>(0, (s, p) => s + p.harga);
        return Scaffold(
          appBar: AppBar(title: Text('Keranjang (${items.length})')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: items.map<Widget>((p) {
              return WhiteCard(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DetailPage(productId: p.id))),
                child: Row(children: [
                  SizedBox(
                      width: 72,
                      height: 72,
                      child: ProductImage(p, iconSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.nama,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500)),
                          Text('${p.penjual} • ${p.lokasi}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.grey)),
                          const SizedBox(height: 4),
                          Text(rp(p.harga),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary)),
                        ]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Color(0xFFE57373)),
                    onPressed: () => app.removeCart(p.id),
                  ),
                ]),
              );
            }).toList(),
          ),
          bottomNavigationBar: BottomBar(
            child: Row(children: [
              Expanded(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total',
                          style:
                              TextStyle(fontSize: 12, color: AppColors.grey)),
                      Text(rp(total),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                    ]),
              ),
              FilledButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            CheckoutPage(ids: List.of(app.cart)))),
                child: const Text('Checkout'),
              ),
            ]),
          ),
        );
      },
    );
  }
}
