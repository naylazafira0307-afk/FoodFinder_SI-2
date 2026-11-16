import 'package:flutter/material.dart';

// ===================== KATEGORI =====================
class Kategori {
  final String key;
  final String label;
  final String contoh;
  final IconData icon;
  final Color color;
  const Kategori(this.key, this.label, this.contoh, this.icon, this.color);
}

const Map<String, Kategori> kategoriMap = {
  'elektronik': Kategori(
    'elektronik',
    'Elektronik',
    'Rice cooker, kipas, setrika',
    Icons.devices_other,
    Color(0xFF3F7CDB),
  ),
  'kamar': Kategori(
    'kamar',
    'Kamar',
    'Lemari, kasur, rak sepatu',
    Icons.bed,
    Color(0xFFD9822B),
  ),
  'sepatu': Kategori(
    'sepatu',
    'Sepatu',
    'Sneakers, sandal, pantofel',
    Icons.directions_run,
    Color(0xFF8E5CD9),
  ),
  'pakaian': Kategori(
    'pakaian',
    'Pakaian',
    'Jaket, kemeja, hoodie',
    Icons.checkroom,
    Color(0xFFD9467A),
  ),
};

// ===================== KONDISI & STANDAR HARGA =====================
const List<String> kondisiList = [
  'Seperti Baru',
  'Bekas - Baik',
  'Bekas - Layak Pakai',
];

class StandarHarga {
  final double min;
  final double max;
  final String ket;
  const StandarHarga(this.min, this.max, this.ket);
}

/// Harga wajar preloved = % dari harga baru, sesuai kondisi (potongan maks 60%).
const Map<String, StandarHarga> standarHarga = {
  'Seperti Baru': StandarHarga(.55, .65, 'jarang dipakai, mulus, fungsi 100%'),
  'Bekas - Baik': StandarHarga(
    .45,
    .55,
    'ada bekas pemakaian ringan, fungsi normal',
  ),
  'Bekas - Layak Pakai': StandarHarga(
    .40,
    .45,
    'ada lecet/kekurangan kecil, masih berfungsi',
  ),
};

class Rentang {
  final int lo;
  final int hi;
  const Rentang(this.lo, this.hi);
}

Rentang rentangHarga(int asli, String kondisi) {
  final st = standarHarga[kondisi]!;
  return Rentang(
    (asli * st.min / 1000).ceil() * 1000,
    (asli * st.max / 1000).floor() * 1000,
  );
}

int bulat5rb(num v) => (v / 5000).round() * 5000;

// ===================== KURIR, METODE BAYAR, STATUS =====================
class Kurir {
  final String nama;
  final String est;
  final int ongkir;
  final IconData icon;
  const Kurir(this.nama, this.est, this.ongkir, this.icon);
}

const List<Kurir> kurirList = [
  Kurir(
    'Lapakos Express',
    'Same day • area Padang',
    10000,
    Icons.electric_moped,
  ),
  Kurir('JNE Reguler', 'Estimasi 2-3 hari', 18000, Icons.local_shipping),
  Kurir(
    'Ambil di Tempat',
    'Ketemuan langsung dengan penjual',
    0,
    Icons.handshake,
  ),
];

class MetodeBayar {
  final String nama;
  final String grup;
  final IconData icon;
  const MetodeBayar(this.nama, this.grup, this.icon);
}

const List<MetodeBayar> metodeList = [
  MetodeBayar('BCA Virtual Account', 'Transfer Bank', Icons.account_balance),
  MetodeBayar('BRI Virtual Account', 'Transfer Bank', Icons.account_balance),
  MetodeBayar('GoPay', 'E-Wallet', Icons.account_balance_wallet),
  MetodeBayar('DANA', 'E-Wallet', Icons.account_balance_wallet),
  MetodeBayar(
    'QRIS',
    'Scan dari aplikasi bank / e-wallet apa pun',
    Icons.qr_code_2,
  ),
  MetodeBayar(
    'Bayar di Tempat (COD)',
    'Bayar tunai saat barang diterima',
    Icons.payments,
  ),
];

class StatusInfo {
  final String label;
  final String pendek;
  final String ket;
  final IconData icon;
  final Color color;
  const StatusInfo(this.label, this.pendek, this.ket, this.icon, this.color);
}

const List<StatusInfo> statusList = [
  StatusInfo(
    'Menunggu Pembayaran',
    'Bayar',
    'Selesaikan pembayaran agar penjual bisa memproses pesananmu.',
    Icons.account_balance_wallet,
    Color(0xFFE08A00),
  ),
  StatusInfo(
    'Dikemas',
    'Dikemas',
    'Penjual sedang mengemas barangmu.',
    Icons.inventory_2,
    Color(0xFF3F7CDB),
  ),
  StatusInfo(
    'Dikirim',
    'Dikirim',
    'Barang sedang dalam perjalanan ke alamatmu.',
    Icons.local_shipping,
    Color(0xFF7B4DD6),
  ),
  StatusInfo(
    'Sampai Tujuan',
    'Sampai',
    'Barang sudah sampai. Rekam video unboxing saat membuka paket, lalu konfirmasi.',
    Icons.home,
    Color(0xFFC0392B),
  ),
  StatusInfo(
    'Selesai',
    'Selesai',
    'Pesanan selesai. Terima kasih sudah belanja!',
    Icons.verified,
    Color(0xFF2E7D32),
  ),
];

const int biayaLayanan = 2000;

const List<String> alasanRefund = [
  'Barang rusak / tidak berfungsi',
  'Tidak sesuai foto atau deskripsi',
  'Kondisi lebih buruk dari yang tertulis',
  'Barang kurang / tidak lengkap',
  'Bukan barang yang saya pesan',
];

// ===================== WILAYAH =====================
const String kKota = 'Kota Padang';
const String kProvinsi = 'Sumatera Barat';
const List<String> kecamatanList = [
  'Bungus Teluk Kabung',
  'Koto Tangah',
  'Kuranji',
  'Lubuk Begalung',
  'Lubuk Kilangan',
  'Nanggalo',
  'Padang Barat',
  'Padang Selatan',
  'Padang Timur',
  'Padang Utara',
  'Pauh',
];

// ===================== MODEL DATA =====================
class Product {
  final String id;
  String nama;
  String kat;
  int harga;
  int? asli; // harga baru / harga beli dulu
  String kondisi;
  String penjual;
  String lokasi;
  IconData icon;
  String desk;
  int jumlahFoto;
  bool mine;
  bool sold;

  Product({
    required this.id,
    required this.nama,
    required this.kat,
    required this.harga,
    this.asli,
    required this.kondisi,
    required this.penjual,
    required this.lokasi,
    required this.icon,
    required this.desk,
    this.jumlahFoto = 3,
    this.mine = false,
    this.sold = false,
  });

  Kategori get kategori => kategoriMap[kat]!;

  /// Persen hemat dibanding harga baru.
  int get hemat =>
      (asli == null || asli == 0) ? 0 : (100 - harga * 100 / asli!).round();
}

class Address {
  String id;
  String label; // Rumah / Kos / Kantor
  String nama;
  String hp;
  String kecamatan;
  String jalan;
  String detail;
  bool utama;

  Address({
    this.id = '',
    required this.label,
    required this.nama,
    required this.hp,
    required this.kecamatan,
    required this.jalan,
    this.detail = '',
    this.utama = false,
  });

  String get full =>
      '$jalan${detail.isNotEmpty ? ' ($detail)' : ''}, Kec. $kecamatan, $kKota, $kProvinsi';
}

class User {
  String nama;
  String email;
  String hp;
  String pw;
  List<Address> addresses;
  User({
    required this.nama,
    required this.email,
    required this.hp,
    required this.pw,
    List<Address>? addresses,
  }) : addresses = addresses ?? [];
}

class Riwayat {
  final String judul;
  final String ket;
  final DateTime w;
  Riwayat(this.judul, this.ket, this.w);
}

class Refund {
  String status; // Diproses / Disetujui / Ditolak
  final String alasan;
  final String ket;
  final String video;
  Refund(this.status, this.alasan, this.ket, this.video);
}

class Order {
  final String id;
  final List<Product> items;
  final Kurir kurir;
  final String alamat;
  final String penerima;
  final String catatan;
  final DateTime dibuat;
  String? metode;
  String? resi;
  int status = 0; // index ke statusList
  bool langkah = false; // sudah transit di hub?
  final List<Riwayat> riwayat;
  Refund? refund;

  Order({
    required this.id,
    required this.items,
    required this.kurir,
    required this.alamat,
    required this.penerima,
    required this.catatan,
    required this.dibuat,
  }) : riwayat = [
         Riwayat(
           'Pesanan dibuat',
           'Menunggu pembayaran dari pembeli.',
           DateTime.now(),
         ),
       ];

  int get subtotal => items.fold<int>(0, (s, p) => s + p.harga);
  int get total => subtotal + kurir.ongkir + biayaLayanan;

  /// Posisi kurir di garis pengiriman (0..1).
  double get progres => [0.0, 0.08, langkah ? 0.75 : 0.4, 1.0, 1.0][status];
}

class ChatMessage {
  final bool me;
  final String text;
  final DateTime w;
  ChatMessage(this.me, this.text, this.w);
}

class ChatRoom {
  final String pid;
  final List<ChatMessage> msgs;
  int unread = 0;
  bool typing = false;
  ChatRoom(this.pid, this.msgs);
}
