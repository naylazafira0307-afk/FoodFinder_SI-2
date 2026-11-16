import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/format.dart';
import 'models.dart';

/// Penyimpanan data aplikasi (in-memory, tanpa database).
/// Semua halaman mendengarkan perubahan lewat `AnimatedBuilder(animation: app)`.
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  // ---------------- DATA ----------------
  final Map<String, User> users = {
    'demo@kosmah.id': User(
      nama: 'Shynta',
      email: 'demo@kosmah.id',
      hp: '081234567890',
      pw: '123456',
      addresses: [
        Address(
          id: 'A1',
          label: 'Kos',
          nama: 'Shynta',
          hp: '081234567890',
          kecamatan: 'Pauh',
          jalan: 'Kos Melati No. 12, Jl. Limau Manis',
          detail: 'Pagar hijau, kamar no. 3',
          utama: true,
        ),
        Address(
          id: 'A2',
          label: 'Rumah',
          nama: 'Rahmawati (Mama)',
          hp: '085276543210',
          kecamatan: 'Koto Tangah',
          jalan: 'Jl. Adinegoro No. 21',
          detail: 'Depan masjid',
        ),
      ],
    ),
  };

  User? user;
  int tab = 0; // tab aktif di bottom navigation
  final List<String> cart = [];
  final List<Order> orders = [];
  final Map<String, ChatRoom> chats = {};
  String? chatAktif; // id produk yang chat-nya sedang dibuka
  final List<Product> products = _seedProducts();

  void setTab(int t) {
    tab = t;
    notifyListeners();
  }

  void refresh() => notifyListeners();

  // ---------------- AUTH ----------------
  /// Return pesan error, atau null jika berhasil.
  String? login(String email, String pw) {
    final e = email.trim().toLowerCase();
    if (!e.contains('@')) return 'Masukkan email yang valid';
    if (pw.length < 6) return 'Password minimal 6 karakter';
    final u = users[e];
    if (u == null) return 'Akun tidak ditemukan. Silakan daftar dulu.';
    if (u.pw != pw) return 'Password salah';
    user = u;
    tab = 0;
    notifyListeners();
    return null;
  }

  String? register({
    required String nama,
    required String email,
    required String hp,
    required String pw,
    required String pw2,
    required bool setuju,
  }) {
    if (nama.trim().isEmpty) return 'Nama wajib diisi';
    if (!email.contains('@')) return 'Masukkan email yang valid';
    if (hp.length < 10) return 'Nomor HP tidak valid';
    if (pw.length < 6) return 'Password minimal 6 karakter';
    if (pw != pw2) return 'Password tidak sama';
    if (!setuju) return 'Setujui syarat & ketentuan terlebih dahulu';
    final e = email.trim().toLowerCase();
    if (users.containsKey(e)) return 'Email sudah terdaftar';
    users[e] = User(nama: nama.trim(), email: e, hp: hp, pw: pw);
    return null;
  }

  void logout() {
    user = null;
    cart.clear();
    tab = 0;
    notifyListeners();
  }

  // ---------------- PRODUK ----------------
  Product? product(String id) {
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  List<Product> katalog({String? kat, String q = ''}) => products
      .where(
        (p) =>
            !p.sold &&
            (kat == null || p.kat == kat) &&
            p.nama.toLowerCase().contains(q.toLowerCase()),
      )
      .toList();

  List<Product> get produkSaya => products.where((p) => p.mine).toList();

  void addProduct(Product p) {
    products.insert(0, p);
    notifyListeners();
  }

  void markSold(Product p) {
    p.sold = true;
    notifyListeners();
  }

  void deleteProduct(Product p) {
    products.remove(p);
    cart.remove(p.id);
    notifyListeners();
  }

  // ---------------- KERANJANG ----------------
  void addCart(String id) {
    if (!cart.contains(id)) cart.add(id);
    notifyListeners();
  }

  void removeCart(String id) {
    cart.remove(id);
    notifyListeners();
  }

  // ---------------- ALAMAT ----------------
  List<Address> get addresses => user?.addresses ?? [];

  Address? get alamatUtama {
    final l = addresses;
    if (l.isEmpty) return null;
    return l.firstWhere((a) => a.utama, orElse: () => l.first);
  }

  Address? addressById(String? id) {
    if (id == null) return null;
    for (final a in addresses) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// Simpan alamat baru / ubah alamat. Return id alamat.
  String saveAddress(Address data, {String? editId}) {
    final l = user!.addresses;
    if (l.isEmpty) data.utama = true;
    if (data.utama) {
      for (final a in l) {
        a.utama = false;
      }
    }
    if (editId != null) {
      final i = l.indexWhere((a) => a.id == editId);
      data.id = editId;
      l[i] = data;
      if (!l.any((a) => a.utama)) l.first.utama = true;
    } else {
      data.id = 'A${DateTime.now().millisecondsSinceEpoch}';
      l.add(data);
    }
    notifyListeners();
    return data.id;
  }

  /// Return pesan error, atau null jika berhasil.
  String? deleteAddress(String id) {
    final a = addressById(id);
    if (a == null) return null;
    if (a.utama && addresses.length > 1) {
      return 'Alamat utama tidak bisa dihapus. Jadikan alamat lain sebagai utama dulu.';
    }
    user!.addresses.remove(a);
    notifyListeners();
    return null;
  }

  // ---------------- PESANAN ----------------
  int get pesananAktif => orders.where((o) => o.status < 4).length;

  Order buatPesanan(List<String> ids, Kurir kurir, Address a, String catatan) {
    final o = Order(
      id: 'PRL-${DateTime.now().millisecondsSinceEpoch % 10000000}',
      items: ids.map((id) => product(id)!).toList(),
      kurir: kurir,
      alamat: a.full,
      penerima: '${a.nama} (${a.hp})',
      catatan: catatan,
      dibuat: DateTime.now(),
    );
    orders.insert(0, o);
    cart.removeWhere((x) => ids.contains(x));
    notifyListeners();
    return o;
  }

  /// Simulasi proses pembayaran (1,8 detik).
  Future<void> bayar(Order o, MetodeBayar m) async {
    await Future.delayed(const Duration(milliseconds: 1800));
    o.metode = m.nama;
    o.status = 1;
    o.resi = 'KSM${DateTime.now().millisecondsSinceEpoch % 1000000000}';
    for (final p in o.items) {
      p.sold = true;
      cart.remove(p.id);
    }
    o.riwayat.insert(
      0,
      Riwayat('Pembayaran berhasil', 'Dibayar via ${m.nama}.', DateTime.now()),
    );
    o.riwayat.insert(
      0,
      Riwayat(
        'Pesanan dikemas',
        'Penjual (${o.items.first.penjual}) sedang menyiapkan barang.',
        DateTime.now(),
      ),
    );
    notifyListeners();
  }

  /// Simulasi update status pengiriman (tombol demo).
  void majukan(Order o) {
    final n = DateTime.now();
    if (o.status == 1) {
      o.status = 2;
      o.riwayat.insert(
        0,
        Riwayat(
          'Paket diserahkan ke kurir',
          '${o.kurir.nama} menjemput paket di ${o.items.first.lokasi}.',
          n,
        ),
      );
    } else if (o.status == 2 && !o.langkah) {
      o.langkah = true;
      o.riwayat.insert(
        0,
        Riwayat(
          'Dalam perjalanan',
          'Paket transit di Hub Lapakos Padang, menuju alamatmu.',
          n,
        ),
      );
    } else if (o.status == 2) {
      o.status = 3;
      o.riwayat.insert(
        0,
        Riwayat('Paket sampai', 'Paket telah diantar ke alamat tujuan.', n),
      );
    } else if (o.status == 3) {
      o.status = 4;
      o.riwayat.insert(
        0,
        Riwayat('Pesanan selesai', 'Pembeli mengonfirmasi barang diterima.', n),
      );
    }
    notifyListeners();
  }

  void ajukanRefund(Order o, String alasan, String ket, String video) {
    o.refund = Refund('Diproses', alasan, ket, video);
    o.riwayat.insert(
      0,
      Riwayat(
        'Pengajuan uang kembali',
        'Alasan: $alasan. Video unboxing terlampir. Menunggu peninjauan admin (maks. 3×24 jam).',
        DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void putuskanRefund(Order o, bool disetujui) {
    o.status = 4;
    if (disetujui) {
      o.refund!.status = 'Disetujui';
      o.riwayat.insert(
        0,
        Riwayat(
          'Uang dikembalikan',
          '${rp(o.total)} dikembalikan ke ${o.metode}. Barang dikirim kembali ke penjual.',
          DateTime.now(),
        ),
      );
    } else {
      o.refund!.status = 'Ditolak';
      o.riwayat.insert(
        0,
        Riwayat(
          'Pengajuan ditolak',
          'Video unboxing tidak menunjukkan kerusakan. Dana diteruskan ke penjual.',
          DateTime.now(),
        ),
      );
    }
    notifyListeners();
  }

  // ---------------- CHAT ----------------
  int get chatUnread => chats.values.fold<int>(0, (s, c) => s + c.unread);

  ChatRoom openChat(Product p) {
    final c = chats.putIfAbsent(
      p.id,
      () => ChatRoom(p.id, [
        ChatMessage(
          false,
          'Halo kak! 👋 ${p.nama} masih tersedia ya. Ada yang mau ditanyakan?',
          DateTime.now(),
        ),
      ]),
    );
    c.unread = 0;
    notifyListeners();
    return c;
  }

  void kirimChat(String pid, String text) {
    final c = chats[pid];
    final p = product(pid);
    if (c == null || p == null || text.trim().isEmpty) return;
    c.msgs.add(ChatMessage(true, text.trim(), DateTime.now()));
    c.typing = true;
    notifyListeners();
    Future.delayed(Duration(milliseconds: 1100 + Random().nextInt(700)), () {
      c.typing = false;
      c.msgs.add(ChatMessage(false, _balas(p, text), DateTime.now()));
      if (chatAktif != pid) c.unread++;
      notifyListeners();
    });
  }

  /// Balasan otomatis penjual (simulasi).
  String _balas(Product p, String text) {
    final t = text.toLowerCase();
    int r(num v) => (v / 1000).round() * 1000;
    final m = RegExp(r'rp\s?([\d.]+)').firstMatch(t);
    if (m != null) {
      final v = int.tryParse(m.group(1)!.replaceAll('.', '')) ?? 0;
      if (v >= p.harga)
        return 'Siap kak, ${rp(v)} deal! 🤝 Langsung checkout aja ya.';
      if (v >= p.harga * .85) {
        return 'Oke deh kak, ${rp(v)} boleh 🤝 Tapi checkout hari ini ya biar aku langsung kemas.';
      }
      return 'Waduh belum bisa kak 🙏 Paling mentok ${rp(r(p.harga * .9))}, itu sudah jauh di bawah harga baru${p.asli != null ? ' (${rp(p.asli!)})' : ''}.';
    }
    bool has(String pola) => RegExp(pola).hasMatch(t);
    if (has(r'nego|kurang|tawar|diskon|murah')) {
      return 'Harga ${rp(p.harga)} sudah murah kak${p.asli != null ? ', harga barunya ${rp(p.asli!)}' : ''} 😊 Tapi boleh kurang dikit jadi ${rp(r(p.harga * .9))} kalau ambil hari ini.';
    }
    if (has(r'cod|ketemu|ambil|lokasi|dimana|di mana')) {
      return 'Bisa COD kak, aku di ${p.lokasi}. Kita bisa ketemuan di tempat umum terdekat, kabari aja jamnya ya.';
    }
    if (has(r'kondisi|minus|rusak|normal|lecet|mulus')) {
      return 'Kondisinya ${p.kondisi.toLowerCase()} kak. ${p.desk}';
    }
    if (has(r'kirim|ongkir|hari ini|kapan|sampai')) {
      return 'Bisa kak! Kalau bayar sebelum jam 3 sore, hari ini juga aku kirim pakai Lapakos Express.';
    }
    if (has(r'masih|ada|ready|tersedia|stok')) {
      return 'Masih ada kak, ready! Langsung checkout aja biar nggak keduluan yang lain 🙏';
    }
    if (has(r'foto|gambar|real')) {
      return 'Fotonya real pict kak 📸 Kalau mau foto tambahan bilang aja ya.';
    }
    if (has(r'makasih|terima kasih|thanks|oke|ok\b')) {
      return 'Sama-sama kak! Ditunggu pesanannya 😊';
    }
    if (has(r'halo|hai|hi\b|permisi|assalam')) {
      return 'Halo kak, iya ada yang bisa dibantu? 😊';
    }
    return 'Oke kak 👍 Ada lagi yang mau ditanyakan soal barangnya?';
  }
}

/// Akses singkat ke state global.
final app = AppState.instance;

// ---------------- DATA AWAL KATALOG ----------------
List<Product> _seedProducts() {
  int n = 0;
  Product p(
    String nama,
    String kat,
    int harga,
    int asli,
    String kondisi,
    String penjual,
    String lokasi,
    IconData icon,
    String desk,
  ) {
    n++;
    return Product(
      id: 'P$n',
      nama: nama,
      kat: kat,
      harga: harga,
      asli: asli,
      kondisi: kondisi,
      penjual: penjual,
      lokasi: lokasi,
      icon: icon,
      desk: desk,
    );
  }

  return [
    p(
      'Rice Cooker Miyako 1.8L',
      'elektronik',
      135000,
      285000,
      'Bekas - Baik',
      'Rina',
      'Limau Manis, Padang',
      Icons.rice_bowl,
      'Masih normal, masak & warm berfungsi. Dijual karena pindah kos. Panci anti lengket masih mulus.',
    ),
    p(
      'Kipas Angin Cosmos 16"',
      'elektronik',
      120000,
      250000,
      'Bekas - Baik',
      'Dimas',
      'Air Tawar, Padang',
      Icons.air,
      'Kipas berdiri 3 kecepatan, putar kanan-kiri normal. Sedikit lecet di tiang.',
    ),
    p(
      'Setrika Philips',
      'elektronik',
      110000,
      189000,
      'Seperti Baru',
      'Ayu',
      'Pauh, Padang',
      Icons.iron,
      'Baru dipakai 3 bulan, lengkap dengan dus. Panas merata.',
    ),
    p(
      'Lampu Belajar LED',
      'elektronik',
      45000,
      80000,
      'Seperti Baru',
      'Fajar',
      'Lubuk Buaya, Padang',
      Icons.light,
      '3 mode warna cahaya, bisa dicas via USB. Cocok untuk meja belajar kos.',
    ),
    p(
      'Lemari Plastik 3 Susun',
      'kamar',
      100000,
      210000,
      'Bekas - Baik',
      'Nisa',
      'Limau Manis, Padang',
      Icons.inventory_2,
      'Lemari plastik Napolly 3 laci, semua roda lengkap. Ada stiker kecil di depan.',
    ),
    p(
      'Kasur Busa Inoac 120x200',
      'kamar',
      270000,
      650000,
      'Bekas - Layak Pakai',
      'Rizky',
      'Kampung Jua, Padang',
      Icons.bed,
      'Kasur busa tebal 15 cm, sarung baru dicuci. Tidak kempes, tidak ada noda besar.',
    ),
    p(
      'Rak Sepatu 4 Tingkat',
      'kamar',
      45000,
      99000,
      'Bekas - Baik',
      'Putri',
      'Pauh, Padang',
      Icons.view_agenda,
      'Rak besi bongkar pasang, muat 12 pasang sepatu. Baut lengkap.',
    ),
    p(
      'Meja Lipat Belajar',
      'kamar',
      70000,
      120000,
      'Seperti Baru',
      'Andi',
      'Air Tawar, Padang',
      Icons.table_restaurant,
      'Meja lipat kayu motif, kaki kokoh. Pas untuk belajar lesehan.',
    ),
    p(
      'Converse Chuck 70 (40)',
      'sepatu',
      425000,
      899000,
      'Bekas - Baik',
      'Kevin',
      'Ulak Karang, Padang',
      Icons.directions_walk,
      'Original, ukuran 40. Sol masih tebal, sudah dicuci bersih.',
    ),
    p(
      'Sepatu Futsal Specs (42)',
      'sepatu',
      215000,
      450000,
      'Bekas - Baik',
      'Bayu',
      'Lubuk Buaya, Padang',
      Icons.sports_soccer,
      'Dipakai main beberapa kali, jahitan aman. Ukuran 42.',
    ),
    p(
      'Sandal Gunung Eiger',
      'sepatu',
      170000,
      299000,
      'Seperti Baru',
      'Tari',
      'Pauh, Padang',
      Icons.hiking,
      'Ukuran 39, tali velcro masih kuat. Jarang dipakai.',
    ),
    p(
      'Pantofel Kulit Hitam (41)',
      'sepatu',
      180000,
      375000,
      'Bekas - Baik',
      'Yoga',
      'Kampung Jua, Padang',
      Icons.business_center,
      'Kulit sintetis, cocok untuk magang/sidang. Ukuran 41.',
    ),
    p(
      "Jaket Denim Levi's (M)",
      'pakaian',
      330000,
      699000,
      'Bekas - Baik',
      'Sinta',
      'Limau Manis, Padang',
      Icons.checkroom,
      'Original, ukuran M. Warna masih pekat, tidak ada sobek.',
    ),
    p(
      'Kemeja Flanel Uniqlo (L)',
      'pakaian',
      230000,
      399000,
      'Seperti Baru',
      'Raka',
      'Air Tawar, Padang',
      Icons.checkroom,
      'Motif kotak merah-hitam, baru dipakai 2 kali.',
    ),
    p(
      'Hoodie H&M Abu (L)',
      'pakaian',
      165000,
      349000,
      'Bekas - Baik',
      'Lala',
      'Ulak Karang, Padang',
      Icons.checkroom,
      'Bahan fleece tebal, resleting depan normal.',
    ),
    p(
      'Rok Plisket Mocca',
      'pakaian',
      85000,
      150000,
      'Seperti Baru',
      'Wulan',
      'Pauh, Padang',
      Icons.checkroom,
      'All size, bahan jatuh dan tidak nerawang. Cocok untuk kuliah.',
    ),
  ];
}
