import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';
import '../katalog/detail_page.dart';
import '../keranjang/checkout_page.dart';

/// Ruang chat dengan penjual (balasan otomatis/simulasi).
class ChatPage extends StatefulWidget {
  final String productId;
  const ChatPage({super.key, required this.productId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  static const _cepat = [
    'Masih ada kak?',
    'Bisa nego?',
    'Bisa COD di mana?',
    'Kondisinya gimana?',
    'Bisa kirim hari ini?',
  ];

  @override
  void initState() {
    super.initState();
    app.chatAktif = widget.productId;
  }

  @override
  void dispose() {
    if (app.chatAktif == widget.productId) app.chatAktif = null;
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _kirim([String? teks]) {
    final t = (teks ?? _input.text).trim();
    if (t.isEmpty) return;
    _input.clear();
    app.kirimChat(widget.productId, t);
  }

  void _keBawah() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        final p = app.product(widget.productId);
        final c = app.chats[widget.productId];
        if (p == null || c == null) {
          return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Chat tidak tersedia')));
        }
        _keBawah();
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Row(children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: AppColors.primaryLight,
                child: Text(p.penjual[0],
                    style: const TextStyle(color: AppColors.primary)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.penjual,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87)),
                      Text('● Online • ${p.lokasi}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.green)),
                    ]),
              ),
            ]),
          ),
          body: Column(children: [
            // info barang
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => DetailPage(productId: p.id))),
                  child: SizedBox(
                      width: 44,
                      height: 44,
                      child: ProductImage(p, iconSize: 22, radius: 8)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.nama,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12)),
                        Text(rp(p.harga),
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700)),
                      ]),
                ),
                if (p.sold)
                  const Text('Terjual',
                      style: TextStyle(fontSize: 12, color: AppColors.grey))
                else if (!p.mine)
                  FilledButton(
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8)),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CheckoutPage(ids: [p.id]))),
                    child: const Text('Beli'),
                  ),
              ]),
            ),
            // pesan
            Expanded(
              child: Container(
                color: const Color(0xFFF3E6E3),
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.all(12),
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: const Color(0xFFFFF6E0),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Text(
                            'Prototype: balasan penjual otomatis (simulasi)',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF7A5A12))),
                      ),
                    ),
                    ...c.msgs.map(_gelembung),
                    if (c.typing)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16)),
                          child: const Text('mengetik...',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // balasan cepat
            Container(
              color: Colors.white,
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: _cepat
                    .map((q) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              side: const BorderSide(color: AppColors.primary),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            onPressed: () => _kirim(q),
                            child: Text(q),
                          ),
                        ))
                    .toList(),
              ),
            ),
            // input
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
              child: SafeArea(
                top: false,
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      onSubmitted: (_) => _kirim(),
                      decoration: InputDecoration(
                        hintText: 'Tulis pesan...',
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide:
                                const BorderSide(color: AppColors.border)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        fixedSize: const Size(46, 46)),
                    onPressed: () => _kirim(),
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ]),
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _gelembung(ChatMessage m) {
    return Align(
      alignment: m.me ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * .78),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: m.me ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(m.me ? 16 : 4),
              bottomRight: Radius.circular(m.me ? 4 : 16),
            ),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(m.text,
                    style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: m.me ? Colors.white : Colors.black87)),
                const SizedBox(height: 2),
                Text('${jam(m.w)}${m.me ? ' ✓✓' : ''}',
                    style: TextStyle(
                        fontSize: 10,
                        color: m.me ? Colors.white70 : Colors.black45)),
              ]),
        ),
      ),
    );
  }
}
