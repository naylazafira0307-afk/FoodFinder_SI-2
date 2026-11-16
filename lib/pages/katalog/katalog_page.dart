import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';

// import '../chat/chat_list_page.dart';
// import 'detail_page.dart';

class KatalogPage extends StatefulWidget {
  const KatalogPage({super.key});

  @override
  State<KatalogPage> createState() => _KatalogPageState();
}

class _KatalogPageState extends State<KatalogPage> {
  String _q = '';
  String? _kat;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        final list = app.katalog(kat: _kat, q: _q);
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _header(context)),
              SliverToBoxAdapter(child: _banner()),
              SliverToBoxAdapter(child: _kategori()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    _kat == null
                        ? 'Semua Barang (${list.length})'
                        : '${kategoriMap[_kat]!.label} (${list.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brown,
                    ),
                  ),
                ),
              ),
              if (list.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.search_off, size: 56, color: AppColors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Barang tidak ditemukan',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (c, i) => ProductCard(list[i]),
                      childCount: list.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: 258,
                        ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context) {
    Widget ikonBadge(IconData i, int n, VoidCallback onTap) => IconButton(
      onPressed: onTap,
      icon: Badge(
        isLabelVisible: n > 0,
        label: Text('$n'),
        backgroundColor: AppColors.yellow,
        textColor: AppColors.onYellow,
        child: Icon(i, color: Colors.white),
      ),
    );

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        14,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.brown],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.yellow,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.recycling, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lapakos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    Text(
                      'LAPAKNYA ANAK KOS',
                      style: TextStyle(
                        color: AppColors.yellow,
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              ikonBadge(Icons.chat, app.chatUnread, () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (_) => const ChatListPage()),
                // );
              }),
              ikonBadge(
                Icons.shopping_cart,
                app.cart.length,
                () => app.setTab(1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Halo, ${app.user?.nama ?? ''} 👋',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const Text(
            'Cari barang preloved apa?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (v) => setState(() => _q = v),
            decoration: InputDecoration(
              hintText: 'Cari rice cooker, lemari, sepatu...',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _banner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFF8C56C), Color(0xFFF2A65A)],
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pindahan Kos? 📦',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Hemat sampai 60% dan pantau pengiriman barangmu langsung dari aplikasi.',
                  style: TextStyle(fontSize: 12, color: AppColors.onYellow),
                ),
              ],
            ),
          ),
          Icon(Icons.local_shipping, size: 56, color: AppColors.onYellow),
        ],
      ),
    );
  }

  Widget _kategori() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Kategori',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              if (_kat != null)
                TextButton(
                  onPressed: () => setState(() => _kat = null),
                  child: const Text('Lihat semua'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: kategoriMap.values.map((k) {
              final on = _kat == k.key;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _kat = on ? null : k.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: on ? k.color : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: k.color.withOpacity(.4)),
                    ),
                    child: Column(
                      children: [
                        Icon(k.icon, color: on ? Colors.white : k.color),
                        const SizedBox(height: 6),
                        Text(
                          k.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: on ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Kartu barang di grid katalog.
class ProductCard extends StatelessWidget {
  final Product p;
  const ProductCard(this.p, {super.key});

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: const EdgeInsets.all(8),
      onTap: () {}, // nanti diganti ke DetailPage
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ProductImage(p),
                if (p.mine)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: _tag(
                      'Milikku',
                      AppColors.yellow,
                      AppColors.onYellow,
                    ),
                  ),
                if (p.asli != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: _tag(
                      '-${p.hemat}%',
                      AppColors.primary,
                      Colors.white,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: Text(
              p.nama,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rp(p.harga),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          if (p.asli != null)
            Text(
              rp(p.asli!),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.grey,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          const SizedBox(height: 4),
          KondisiChip(p.kondisi),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.location_on, size: 12, color: AppColors.grey),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  p.lokasi,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String t, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      t,
      style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w700),
    ),
  );
}
