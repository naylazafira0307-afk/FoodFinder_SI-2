import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';
import '../keranjang/pembayaran_page.dart';
import 'lacak_page.dart';

class PesananPage extends StatelessWidget {
  const PesananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pesanan Saya'),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            tabs: [Tab(text: 'Berlangsung'), Tab(text: 'Selesai')],
          ),
        ),
        body: AnimatedBuilder(
          animation: app,
          builder: (context, _) => TabBarView(children: [
            _daftar(context, app.orders.where((o) => o.status < 4).toList()),
            _daftar(context, app.orders.where((o) => o.status == 4).toList()),
          ]),
        ),
      ),
    );
  }

  Widget _daftar(BuildContext context, List<Order> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.receipt_long, size: 72, color: Color(0xFFBBBBBB)),
          const SizedBox(height: 8),
          const Text('Belum ada pesanan',
              style: TextStyle(color: AppColors.grey)),
          const SizedBox(height: 12),
          OutlinedButton(
              onPressed: () => app.setTab(0),
              child: const Text('Lihat Katalog')),
        ]),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: list.map((o) => _kartu(context, o)).toList(),
    );
  }

  Widget _kartu(BuildContext context, Order o) {
    final f = o.items.first;
    void buka() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              o.status == 0 ? PembayaranPage(order: o) : LacakPage(order: o),
        ),
      );
    }

    return WhiteCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => LacakPage(order: o))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.storefront, size: 16),
          const SizedBox(width: 6),
          Expanded(
              child: Text(f.penjual,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          StatusChip(o.status),
        ]),
        const Divider(height: 20),
        Row(children: [
          SizedBox(
              width: 56,
              height: 56,
              child: ProductImage(f, iconSize: 26, radius: 8)),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f.nama),
              if (o.items.length > 1)
                Text('+${o.items.length - 1} barang lainnya',
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.grey)),
              Text(o.id,
                  style: const TextStyle(fontSize: 12, color: AppColors.grey)),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: Text('Total ${rp(o.total)}',
                  style: const TextStyle(fontWeight: FontWeight.w700))),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.yellow,
              foregroundColor: AppColors.onYellow,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: buka,
            child: Text(o.status == 0 ? 'Bayar' : 'Lacak'),
          ),
        ]),
      ]),
    );
  }
}
