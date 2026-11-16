import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import 'chat_page.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        final rooms = app.chats.values.toList()
          ..sort((a, b) => b.msgs.last.w.compareTo(a.msgs.last.w));
        return Scaffold(
          appBar: AppBar(title: const Text('Chat')),
          body: rooms.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.forum, size: 64, color: Color(0xFFC9B5B2)),
                      SizedBox(height: 8),
                      Text(
                          'Belum ada chat.\nBuka detail barang lalu tekan Chat untuk tanya penjual.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.grey)),
                    ]),
                  ),
                )
              : ListView(
                  children: rooms.map((c) {
                    final p = app.product(c.pid);
                    final m = c.msgs.last;
                    final penjual = p?.penjual ?? '?';
                    return Container(
                      color: Colors.white,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          child: Text(penjual[0],
                              style:
                                  const TextStyle(color: AppColors.primary)),
                        ),
                        title: Text(penjual,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          '${p?.nama ?? '(barang dihapus)'}\n${m.me ? 'Kamu: ' : ''}${m.text}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        isThreeLine: true,
                        trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(jam(m.w),
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.grey)),
                              if (c.unread > 0)
                                Badge(label: Text('${c.unread}')),
                            ]),
                        onTap: p == null
                            ? null
                            : () {
                                app.openChat(p);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            ChatPage(productId: p.id)));
                              },
                      ),
                    );
                  }).toList(),
                ),
        );
      },
    );
  }
}
