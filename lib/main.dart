import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'jam.dart';

/* ───────── Konstanta ───────── */
const merah = Color(0xFF9E1B1B), emas = Color(0xFFE0A526), krem = Color(0xFFFAF1E6);
const pusatPadang = LatLng(-0.925, 100.37);
const katInfo = <String, (String, Color, IconData)>{
  'Rumah Makan': ('Rumah Makan', Color(0xFF9E1B1B), Icons.restaurant),
  'Cafe': ('Kafe', Color(0xFF7A5236), Icons.local_cafe),
  'Kuliner': ('Kuliner', Color(0xFFC76A12), Icons.ramen_dining),
  'Oleh-Oleh': ('Oleh-oleh', Color(0xFF2E7D5B), Icons.shopping_bag),
};
const kataKunci = <String, List<String>>{
  'Rumah Makan': ['Rendangnya juara', 'Sambalnya mantap', 'Porsi banyak', 'Harga bersahabat', 'Lauk lengkap', 'Cocok bawa keluarga', 'Pelayanan cepat', 'Parkir mudah'],
  'Cafe': ['Kopinya enak', 'Cocok buat nugas', 'Tempatnya nyaman', 'Wifi kencang', 'Banyak colokan', 'Harga bersahabat', 'Bagus buat foto', 'Parkir mudah'],
  'Kuliner': ['Rasanya juara', 'Kuahnya mantap', 'Porsi banyak', 'Harga bersahabat', 'Pelayanan cepat', 'Buka sampai malam', 'Tempatnya bersih', 'Parkir mudah'],
  'Oleh-Oleh': ['Pilihan lengkap', 'Rasanya juara', 'Kemasan rapi', 'Aman dibawa ke pesawat', 'Bisa cicip dulu', 'Harga bersahabat', 'Pelayanan ramah', 'Parkir mudah'],
};
const kataKasar = ['anjing', 'bangsat', 'bajingan', 'kontol', 'memek', 'goblok', 'tolol', 'babi', 'kampret'];
bool kasar(String t) => kataKasar.any((k) => RegExp('(^|[^a-z])$k([^a-z]|\$)', caseSensitive: false).hasMatch(t));
String desimal(num n) => n.toStringAsFixed(1).replaceAll('.', ',');
String fmtJarak(double km) => km < 1 ? '${(km * 1000).round()} m' : '${desimal(km)} km';
int menitTempuh(double km) => math.max(2, (km * 1.3 / 25 * 60).round());

/* ───────── Model ───────── */
class Place {
  final String id, nama, alamat, kec, jam, telp, spes, kat;
  final double lat, lng, rating;
  final int ulasan;
  Place.fromJson(Map j, this.kat)
      : id = j['place_id'], nama = j['nama'], alamat = j['alamat'], kec = j['kecamatan'],
        jam = j['jam_buka'] ?? '-', telp = j['telepon'] ?? '-', spes = j['spesialisasi'] ?? '',
        lat = (j['latitude'] as num).toDouble(), lng = (j['longitude'] as num).toDouble(),
        rating = (j['rating'] as num?)?.toDouble() ?? 0, ulasan = j['jumlah_ulasan'] ?? 0;
  late final Jadwal? jadwal = parseJam(jam);
  bool get adaTelp => telp.trim().isNotEmpty && telp.trim() != '-';
  double get skor => rating * math.log(ulasan + 10) / math.ln10; // rating DAN banyak ulasan
  Status get status {
    final w = DateTime.now().toUtc().add(const Duration(hours: 7)); // WIB
    return statusBuka(jadwal, w.weekday - 1, w.hour * 60 + w.minute);
  }
  double? jarakKm(LatLng? dari) => dari == null ? null : const Distance().as(LengthUnit.Kilometer, dari, LatLng(lat, lng)).toDouble();
}

/* ───────── State + penyimpanan lokal ───────── */
class App extends ChangeNotifier {
  static final i = App._();
  App._();
  late SharedPreferences sp;
  List<Place> semua = [];
  Set<String> rekomen = {};
  LatLng? lokasi;
  Map<String, dynamic> s = {
    'akun': [{'id': 'u1', 'nama': 'Rani Putri', 'email': 'demo@foodfinder.id', 'sandi': 'demo123'}],
    'sesi': null, 'favorit': {}, 'ulasan': {}, 'gelap': false,
  };

  Future<void> muat() async {
    sp = await SharedPreferences.getInstance();
    final raw = sp.getString('foodfinder-v1');
    if (raw != null) s = jsonDecode(raw);
    final d = jsonDecode(await rootBundle.loadString('assets/places.json')) as Map<String, dynamic>;
    semua = [for (final e in d.entries) for (final j in e.value) Place.fromJson(j, e.key)];
    for (final k in katInfo.keys) {
      final l = semua.where((t) => t.kat == k).toList()..sort((a, b) => b.skor.compareTo(a.skor));
      rekomen.addAll(l.take(5).map((t) => t.id));
    }
  }
  void simpan() { sp.setString('foodfinder-v1', jsonEncode(s)); notifyListeners(); }

  bool get gelap => s['gelap'] == true;
  Map? get user { for (final a in s['akun']) { if (a['id'] == s['sesi']) return a; } return null; }
  String get kunci => s['sesi'] ?? 'tamu';
  List<String> get favList => List<String>.from(s['favorit'][kunci] ?? []);
  bool isFav(String id) => favList.contains(id);
  void toggleFav(String id) { final l = favList; l.contains(id) ? l.remove(id) : l.add(id); s['favorit'][kunci] = l; simpan(); }
  List<Map> ulasanDi(String id) => List<Map>.from(s['ulasan'][id] ?? []);
  ({double rata, int n})? ratingUser(String id) {
    final l = ulasanDi(id);
    return l.isEmpty ? null : (rata: l.fold<double>(0, (a, r) => a + r['bintang']) / l.length, n: l.length);
  }
  List<MapEntry<String, int>> hitungKunci(String id) {
    final c = <String, int>{};
    for (final r in ulasanDi(id)) { for (final k in r['kunci'] ?? []) { c[k] = (c[k] ?? 0) + 1; } }
    return c.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }
  void tambahUlasan(String id, int bintang, List<String> kunci, String teks) {
    final u = user!;
    (s['ulasan'][id] ??= []).add({'id': DateTime.now().microsecondsSinceEpoch.toString(), 'uid': u['id'], 'nama': u['nama'], 'bintang': bintang, 'kunci': kunci, 'teks': teks, 'tgl': DateTime.now().toIso8601String().substring(0, 10)});
    simpan();
  }
  void hapusUlasan(String id, String rid) { s['ulasan'][id] = ulasanDi(id).where((r) => r['id'] != rid).toList(); simpan(); }

  Future<String?> deteksiLokasi() async {
    if (!await Geolocator.isLocationServiceEnabled()) return 'GPS belum menyala.';
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
    if (p == LocationPermission.denied || p == LocationPermission.deniedForever) return 'Izin lokasi ditolak. Aktifkan di pengaturan HP.';
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, timeLimit: const Duration(seconds: 15));
    lokasi = LatLng(pos.latitude, pos.longitude);
    notifyListeners();
    return null;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await App.i.muat();
  runApp(const FoodFinderApp());
}

class FoodFinderApp extends StatelessWidget {
  const FoodFinderApp({super.key});
  @override
  Widget build(BuildContext c) => ListenableBuilder(
      listenable: App.i,
      builder: (_, __) => MaterialApp(
            title: 'FoodFinder', debugShowCheckedModeBanner: false,
            themeMode: App.i.gelap ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto', scaffoldBackgroundColor: krem, colorScheme: ColorScheme.fromSeed(seedColor: merah, primary: merah, surface: Colors.white)),
            darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorScheme: ColorScheme.fromSeed(seedColor: merah, brightness: Brightness.dark, primary: const Color(0xFFF2A69F))),
            home: const Shell(),
          ));
}

void pesan(BuildContext c, String t) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(t), behavior: SnackBarBehavior.floating));
void bukaDetail(BuildContext c, Place t) => Navigator.push(c, MaterialPageRoute(builder: (_) => DetailPage(t)));

/* ───────── Kerangka: 4 tab ───────── */
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}
class _ShellState extends State<Shell> {
  int tab = 0;
  @override
  Widget build(BuildContext c) {
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: tab, children: const [BerandaPage(), PetaPage(), FavoritPage(), ProfilPage()])),
      bottomNavigationBar: ListenableBuilder(
        listenable: App.i,
        builder: (_, __) => NavigationBar(selectedIndex: tab, onDestinationSelected: (i) => setState(() => tab = i), destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          const NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Peta'),
          NavigationDestination(icon: Badge(isLabelVisible: App.i.favList.isNotEmpty, label: Text('${App.i.favList.length}'), child: const Icon(Icons.favorite_border)), selectedIcon: const Icon(Icons.favorite), label: 'Favorit'),
          const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ]),
      ),
    );
  }
}

/* ───────── Kartu tempat ───────── */
Color warnaStatus(String k) => switch (k) { 'buka' => const Color(0xFF2E7D4F), 'segera' => const Color(0xFFA86200), 'tutup' => const Color(0xFFB3261E), _ => Colors.grey };

class PlaceCard extends StatelessWidget {
  final Place t;
  const PlaceCard(this.t, {super.key});
  @override
  Widget build(BuildContext c) {
    final (label, warna, ikon) = katInfo[t.kat]!;
    final st = t.status, km = t.jarakKm(App.i.lokasi), rp = App.i.ratingUser(t.id), k = App.i.hitungKunci(t.id);
    return Card(
      elevation: 1, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20), onTap: () => bukaDetail(c, t),
        child: Padding(padding: const EdgeInsets.all(10), child: Row(children: [
          Container(width: 84, height: 84, decoration: BoxDecoration(color: warna, borderRadius: BorderRadius.circular(16)), child: Icon(ikon, color: Colors.white, size: 36)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text.rich(TextSpan(children: [
              TextSpan(text: t.nama, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              if (App.i.rekomen.contains(t.id)) const WidgetSpan(child: Padding(padding: EdgeInsets.only(left: 6), child: Chip(label: Text('Rekomen', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)), backgroundColor: emas, padding: EdgeInsets.zero, visualDensity: VisualDensity.compact, side: BorderSide.none))),
            ]), maxLines: 2, overflow: TextOverflow.ellipsis),
            Text(t.spes.isEmpty ? label : t.spes, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: Theme.of(c).hintColor)),
            const SizedBox(height: 6),
            Wrap(spacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text('★ ${desimal(rp?.rata ?? t.rating)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
              Text(km != null ? '${fmtJarak(km)} · ±${menitTempuh(km)} mnt' : t.kec, style: const TextStyle(fontSize: 12.5)),
              Text(st.buka == true ? (st.kode == 'segera' ? '● Segera tutup' : '● Buka') : st.kode == 'tidak-ada' ? '● Jam tak ada' : '● Tutup', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: warnaStatus(st.kode))),
            ]),
            if (k.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text('“${k.first.key}”', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: warna))),
          ])),
          IconButton(icon: Icon(App.i.isFav(t.id) ? Icons.favorite : Icons.favorite_border, color: merah), onPressed: () { App.i.toggleFav(t.id); pesan(c, App.i.isFav(t.id) ? 'Disimpan ke favorit' : 'Dihapus dari favorit'); }),
        ])),
      ),
    );
  }
}

/* ───────── Beranda ───────── */
class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});
  @override
  State<BerandaPage> createState() => _BerandaState();
}
class _BerandaState extends State<BerandaPage> {
  String cari = '', urut = 'populer';
  String? kat;
  bool bukaSaja = false, mencari = false;
  int batas = 15;

  List<Place> saring() {
    final q = cari.trim().toLowerCase();
    final h = App.i.semua.where((t) {
      if (kat != null && t.kat != kat) return false;
      if (bukaSaja && t.status.buka != true) return false;
      return q.isEmpty || [t.nama, t.spes, t.kec, t.alamat].any((x) => x.toLowerCase().contains(q));
    }).toList();
    final lok = App.i.lokasi;
    if (urut == 'populer') h.sort((a, b) => b.ulasan.compareTo(a.ulasan));
    if (urut == 'rating') h.sort((a, b) { final r = b.rating.compareTo(a.rating); return r != 0 ? r : b.ulasan.compareTo(a.ulasan); });
    if (urut == 'jarak' && lok != null) h.sort((a, b) => a.jarakKm(lok)!.compareTo(b.jarakKm(lok)!));
    return h;
  }

  Future<void> terdekat() async {
    if (urut == 'jarak') return setState(() => urut = 'populer');
    if (App.i.lokasi == null) {
      setState(() => mencari = true);
      final err = await App.i.deteksiLokasi();
      if (!mounted) return;
      setState(() => mencari = false);
      if (err != null) return pesan(context, err);
    }
    setState(() { urut = 'jarak'; batas = 15; });
  }

  @override
  Widget build(BuildContext c) => ListenableBuilder(listenable: App.i, builder: (_, __) {
    final h = saring(), u = App.i.user;
    final polos = cari.isEmpty && kat == null && !bukaSaja;
    final pop = App.i.semua.toList()..sort((a, b) => b.ulasan.compareTo(a.ulasan));
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF3DCC8), krem])),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 30, height: 30, decoration: BoxDecoration(color: merah, borderRadius: BorderRadius.circular(9)), child: const Icon(Icons.location_on, color: emas, size: 20)),
            const SizedBox(width: 8),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text.rich(TextSpan(children: [TextSpan(text: 'Food'), TextSpan(text: 'Finder', style: TextStyle(color: merah))]), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              Text('Cita rasa di Kota Padang', style: TextStyle(fontSize: 10.5, color: Colors.black54)),
            ])),
            if (u != null) Text(u['nama'].split(' ').first, style: const TextStyle(fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 10),
          const Text.rich(TextSpan(children: [TextSpan(text: 'Dari '), TextSpan(text: 'Peta', style: TextStyle(color: Color(0xFFB3261E))), TextSpan(text: ',\nSampai ke '), TextSpan(text: 'Meja', style: TextStyle(color: Color(0xFFB3261E))), TextSpan(text: '!')]), style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, height: 1.12, color: Color(0xFF1F1A17))),
          const SizedBox(height: 14),
          TextField(
            onChanged: (v) => setState(() { cari = v; batas = 15; }),
            decoration: InputDecoration(hintText: 'Cari rendang, kopi, martabak...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE6CDB8)))),
          ),
        ]),
      ),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        for (final e in katInfo.entries) GestureDetector(
          onTap: () => setState(() { kat = kat == e.key ? null : e.key; batas = 15; }),
          child: Column(children: [
            Container(width: 60, height: 60, decoration: BoxDecoration(color: e.value.$2, borderRadius: BorderRadius.circular(20), border: kat == e.key ? Border.all(color: e.value.$2.withOpacity(.35), width: 4) : null), child: Icon(e.value.$3, color: Colors.white, size: 28)),
            const SizedBox(height: 6),
            Text(e.value.$1, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kat == e.key ? e.value.$2 : null)),
          ]),
        ),
      ])),
      if (polos) ...[
        _judul('Paling populer', 'dari ulasan terbanyak'),
        SizedBox(height: 190, child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), itemCount: 8, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) {
          final t = pop[i];
          final (_, w, ik) = katInfo[t.kat]!;
          return GestureDetector(onTap: () => bukaDetail(c, t), child: Container(width: 196, decoration: BoxDecoration(color: Theme.of(c).colorScheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFEADBC9))), clipBehavior: Clip.antiAlias, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(height: 110, color: w, alignment: Alignment.topLeft, padding: const EdgeInsets.all(8), child: Stack(children: [CircleAvatar(radius: 14, backgroundColor: i == 0 ? emas : Colors.white, child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.black87))), Align(alignment: Alignment.center, child: Icon(ik, color: Colors.white70, size: 40))])),
            Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.nama.replaceAll(RegExp(r'\s*\(.*?\)'), ''), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text('★ ${desimal(t.rating)} · ${t.spes}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
            ])),
          ])));
        })),
      ],
      _judul(polos ? (urut == 'jarak' ? 'Terdekat darimu' : 'Jelajahi semua') : '${h.length} tempat ditemukan', null),
      SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [
        FilterChip(label: const Text('Buka sekarang'), selected: bukaSaja, onSelected: (v) => setState(() { bukaSaja = v; batas = 15; })),
        const SizedBox(width: 8),
        FilterChip(avatar: const Icon(Icons.my_location, size: 16), label: Text(mencari ? 'Mencari...' : 'Terdekat'), selected: urut == 'jarak', onSelected: (_) => terdekat()),
        const SizedBox(width: 8),
        FilterChip(avatar: const Icon(Icons.star, size: 16), label: const Text('Rating tertinggi'), selected: urut == 'rating', onSelected: (v) => setState(() => urut = v ? 'rating' : 'populer')),
      ])),
      const SizedBox(height: 14),
      if (h.isEmpty) const Padding(padding: EdgeInsets.all(48), child: Center(child: Text('Yah, belum ketemu. Coba kata kunci lain.')))
      else Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(children: [
        for (final t in h.take(batas)) Padding(padding: const EdgeInsets.only(bottom: 12), child: PlaceCard(t)),
        if (h.length > batas) OutlinedButton(onPressed: () => setState(() => batas += 15), child: Text('Tampilkan lebih banyak (${h.length - batas} lagi)')),
      ])),
    ]);
  });

  Widget _judul(String a, String? b) => Padding(padding: const EdgeInsets.fromLTRB(20, 22, 20, 12), child: Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
    Container(width: 5, height: 18, decoration: BoxDecoration(color: merah, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 8),
    Expanded(child: Text(a, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
    if (b != null) Text(b, style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
  ]));
}

/* ───────── Detail ───────── */
class DetailPage extends StatelessWidget {
  final Place t;
  const DetailPage(this.t, {super.key});

  Future<void> _buka(String url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext c) => ListenableBuilder(listenable: App.i, builder: (_, __) {
    final (label, warna, ikon) = katInfo[t.kat]!;
    final st = t.status, km = t.jarakKm(App.i.lokasi), rp = App.i.ratingUser(t.id), u = App.i.user;
    final ulasan = App.i.ulasanDi(t.id).reversed.toList(), kw = App.i.hitungKunci(t.id);
    final sudah = u != null && ulasan.any((r) => r['uid'] == u['id']);
    final w = DateTime.now().toUtc().add(const Duration(hours: 7)), hari = w.weekday - 1;
    String slot(List<List<int>> l) => l.isEmpty ? 'Tutup' : l.map((r) => r[0] == 0 && r[1] >= 1440 ? '24 jam' : '${fmtJam(r[0])}–${fmtJam(r[1])}').join(', ');
    final maps = 'https://www.google.com/maps/search/?api=1&query=${t.lat},${t.lng}&query_place_id=${t.id}';
    final rute = 'https://www.google.com/maps/dir/?api=1${App.i.lokasi != null ? '&origin=${App.i.lokasi!.latitude},${App.i.lokasi!.longitude}' : ''}&destination=${t.lat},${t.lng}&destination_place_id=${t.id}&travelmode=driving';
    return Scaffold(body: ListView(padding: EdgeInsets.zero, children: [
      Stack(children: [
        Container(height: 250, color: warna, alignment: Alignment.center, child: Icon(ikon, color: Colors.white54, size: 90)),
        SafeArea(child: Padding(padding: const EdgeInsets.all(12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          CircleAvatar(backgroundColor: Colors.white, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(c))),
          CircleAvatar(backgroundColor: Colors.white, child: IconButton(icon: Icon(App.i.isFav(t.id) ? Icons.favorite : Icons.favorite_border, color: merah), onPressed: () => App.i.toggleFav(t.id))),
        ]))),
      ]),
      Transform.translate(offset: const Offset(0, -24), child: Container(
        decoration: BoxDecoration(color: Theme.of(c).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Chip(avatar: Icon(ikon, size: 14, color: warna), label: Text(label, style: TextStyle(color: warna, fontWeight: FontWeight.w800, fontSize: 12)), side: BorderSide.none, backgroundColor: warna.withOpacity(.15)),
          Text(t.nama, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.2)),
          Text(t.spes, style: TextStyle(color: Theme.of(c).hintColor)),
          const SizedBox(height: 8),
          Wrap(spacing: 12, children: [
            Text('★ ${desimal(t.rating)} (${t.ulasan} di Google)', style: const TextStyle(fontWeight: FontWeight.w700)),
            if (rp != null) Text('★ ${desimal(rp.rata)} (${rp.n} di FoodFinder)', style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(km != null ? '${fmtJarak(km)} darimu · ±${menitTempuh(km)} mnt' : 'Kec. ${t.kec}'),
          ]),
          const SizedBox(height: 8),
          Chip(avatar: Icon(Icons.access_time, size: 16, color: warnaStatus(st.kode)), label: Text(st.teks, style: TextStyle(color: warnaStatus(st.kode), fontWeight: FontWeight.w800)), side: BorderSide.none, backgroundColor: warnaStatus(st.kode).withOpacity(.13)),
          const Text('Info tempat dari Google Maps', style: TextStyle(fontSize: 11.5, color: Colors.black54)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _aksi(Icons.phone, 'Telepon', t.adaTelp ? () => _buka('tel:${t.telp.replaceAll(RegExp(r'[^0-9+]'), '')}') : null)),
            const SizedBox(width: 10),
            Expanded(child: _aksi(Icons.directions, 'Rute', () => _buka(rute))),
            const SizedBox(width: 10),
            Expanded(child: _aksi(Icons.star, sudah ? 'Sudah dinilai' : 'Beri nilai', sudah ? null : () => _nilai(c))),
          ]),
          const SizedBox(height: 22),
          const Text('Kata pengunjung', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          if (kw.isEmpty) const Text('Belum ada yang menilai. Jadilah yang pertama.', style: TextStyle(color: Colors.black54))
          else for (final e in kw.take(4)) Padding(padding: const EdgeInsets.only(bottom: 7), child: Stack(children: [
            FractionallySizedBox(widthFactor: math.max(.06, e.value / kw.first.value), child: Container(height: 42, decoration: BoxDecoration(color: emas.withOpacity(.4), borderRadius: BorderRadius.circular(12)))),
            Container(height: 42, padding: const EdgeInsets.symmetric(horizontal: 12), alignment: Alignment.centerLeft, child: Row(children: [Expanded(child: Text('“${e.key}”', style: const TextStyle(fontWeight: FontWeight.w700))), Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.w800))])),
          ])),
          const SizedBox(height: 18),
          const Text('Info', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          Card(child: Column(children: [
            ListTile(leading: const Icon(Icons.place, color: merah), title: Text('${t.alamat}, Kec. ${t.kec}'), subtitle: const Text('Ketuk untuk buka peta'), onTap: () => _buka(maps)),
            ExpansionTile(leading: const Icon(Icons.access_time), title: Text(t.jadwal == null ? 'Belum tersedia' : slot(t.jadwal![hari])), subtitle: const Text('Jam buka hari ini'), children: [
              if (t.jadwal != null) for (var i = 0; i < 7; i++) ListTile(dense: true, title: Text(namaHari[i], style: TextStyle(fontWeight: i == hari ? FontWeight.w800 : null)), trailing: Text(slot(t.jadwal![i]))),
            ]),
            ListTile(leading: const Icon(Icons.phone), title: Text(t.adaTelp ? t.telp : 'Belum tersedia'), subtitle: const Text('Telepon')),
          ])),
          SizedBox(height: 190, child: ClipRRect(borderRadius: BorderRadius.circular(18), child: FlutterMap(options: MapOptions(initialCenter: LatLng(t.lat, t.lng), initialZoom: 16, interactionOptions: const InteractionOptions(flags: InteractiveFlag.none), onTap: (_, __) => _buka(maps)), children: [
            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'id.foodfinder.app'),
            MarkerLayer(markers: [Marker(point: LatLng(t.lat, t.lng), width: 40, height: 50, child: Icon(Icons.location_on, color: warna, size: 44))]),
          ]))),
          const SizedBox(height: 22),
          const Text('Ulasan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          if (ulasan.isEmpty) const Text('Belum ada ulasan.', style: TextStyle(color: Colors.black54)),
          for (final r in ulasan) Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [CircleAvatar(radius: 17, backgroundColor: emas, child: Text(r['nama'].toString().substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.black87))), const SizedBox(width: 10), Expanded(child: Text('${r['nama']}\n${r['tgl']}', style: const TextStyle(fontSize: 12.5))), Text('★' * (r['bintang'] as int), style: const TextStyle(color: emas))]),
            if ((r['kunci'] as List).isNotEmpty) Wrap(spacing: 6, children: [for (final k in r['kunci']) Chip(label: Text(k, style: const TextStyle(fontSize: 11.5)), visualDensity: VisualDensity.compact)]),
            if ((r['teks'] as String).isNotEmpty) Text(r['teks']),
            if (u != null && r['uid'] == u['id']) TextButton(onPressed: () => App.i.hapusUlasan(t.id, r['id']), child: const Text('Hapus ulasanku')),
          ]))),
        ]),
      )),
    ]));
  });

  Widget _aksi(IconData i, String l, VoidCallback? f) => FilledButton.tonal(onPressed: f, style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), child: Column(children: [Icon(i), const SizedBox(height: 4), Text(l, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700))]));

  void _nilai(BuildContext c) {
    if (App.i.user == null) return pesan(c, 'Masuk dulu di tab Profil untuk memberi penilaian.');
    var bintang = 0;
    final pilih = <String>[];
    final teks = TextEditingController();
    String? err;
    showModalBottomSheet(context: c, isScrollControlled: true, builder: (_) => StatefulBuilder(builder: (ctx, set) => Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Nilai ${t.nama}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        Row(children: [for (var i = 1; i <= 5; i++) IconButton(iconSize: 36, icon: Icon(Icons.star, color: i <= bintang ? emas : Colors.black12), onPressed: () => set(() => bintang = i))]),
        const Text('Apa yang paling kamu suka? (maks. 3)', style: TextStyle(fontWeight: FontWeight.w700)),
        Wrap(spacing: 8, children: [for (final k in kataKunci[t.kat]!) FilterChip(label: Text(k), selected: pilih.contains(k), onSelected: (v) => set(() { if (v && pilih.length < 3) { pilih.add(k); } else { pilih.remove(k); } }))]),
        TextField(controller: teks, maxLength: 300, maxLines: 3, decoration: const InputDecoration(labelText: 'Cerita sedikit (opsional)')),
        if (err != null) Text(err!, style: const TextStyle(color: Color(0xFFB3261E), fontWeight: FontWeight.w700)),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: () {
          if (bintang == 0) return set(() => err = 'Pilih bintang dulu, 1 sampai 5.');
          if (kasar(teks.text)) return set(() => err = 'Komentarmu mengandung kata yang tidak pantas.');
          App.i.tambahUlasan(t.id, bintang, pilih, teks.text.trim());
          Navigator.pop(ctx);
          pesan(c, 'Makasih! Penilaianmu sudah tampil.');
        }, child: const Text('Kirim penilaian'))),
      ])),
    )));
  }
}

/* ───────── Peta ───────── */
class PetaPage extends StatefulWidget {
  const PetaPage({super.key});
  @override
  State<PetaPage> createState() => _PetaState();
}
class _PetaState extends State<PetaPage> {
  String? kat;
  final mc = MapController();
  @override
  Widget build(BuildContext c) => ListenableBuilder(listenable: App.i, builder: (_, __) {
    final l = App.i.semua.where((t) => kat == null || t.kat == kat).toList();
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(14, 16, 14, 8), child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Peta tempat makan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), Text('${l.length} tempat')]),
        const SizedBox(height: 8),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
          ChoiceChip(label: const Text('Semua'), selected: kat == null, onSelected: (_) => setState(() => kat = null)),
          for (final e in katInfo.entries) Padding(padding: const EdgeInsets.only(left: 8), child: ChoiceChip(avatar: Icon(e.value.$3, size: 16, color: e.value.$2), label: Text(e.value.$1), selected: kat == e.key, onSelected: (_) => setState(() => kat = e.key))),
        ])),
      ])),
      Expanded(child: Container(margin: const EdgeInsets.fromLTRB(12, 4, 12, 12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFF7A2E1E), width: 3)), clipBehavior: Clip.antiAlias, child: Stack(children: [
        FlutterMap(mapController: mc, options: MapOptions(initialCenter: App.i.lokasi ?? pusatPadang, initialZoom: App.i.lokasi != null ? 15 : 13, minZoom: 11, maxZoom: 18), children: [
          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'id.foodfinder.app'),
          MarkerLayer(markers: [
            for (final t in l) Marker(point: LatLng(t.lat, t.lng), width: 30, height: 40, alignment: Alignment.topCenter, child: GestureDetector(onTap: () => _pratinjau(t), child: Icon(Icons.location_on, color: katInfo[t.kat]!.$2, size: 34))),
            if (App.i.lokasi != null) Marker(point: App.i.lokasi!, width: 20, height: 20, child: Container(decoration: BoxDecoration(color: const Color(0xFF1E88E5), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)))),
          ]),
        ]),
        Positioned(right: 10, bottom: 12, child: Column(children: [
          FloatingActionButton.small(heroTag: 'z1', onPressed: () => mc.move(mc.camera.center, mc.camera.zoom + 1), child: const Icon(Icons.add)),
          const SizedBox(height: 8),
          FloatingActionButton.small(heroTag: 'z2', onPressed: () => mc.move(mc.camera.center, mc.camera.zoom - 1), child: const Icon(Icons.remove)),
          const SizedBox(height: 8),
          FloatingActionButton.small(heroTag: 'z3', onPressed: () async { final e = await App.i.deteksiLokasi(); if (!c.mounted) return; if (e != null) { pesan(c, e); } else { mc.move(App.i.lokasi!, 15); } }, child: const Icon(Icons.my_location, color: merah)),
          const SizedBox(height: 8),
          FloatingActionButton.small(heroTag: 'z4', onPressed: () => mc.move(pusatPadang, 13), child: const Icon(Icons.home, color: merah)),
        ])),
        const Positioned(left: 8, bottom: 4, child: Text('© OpenStreetMap', style: TextStyle(fontSize: 10))),
      ]))),
    ]);
  });
  void _pratinjau(Place t) => showModalBottomSheet(context: context, builder: (_) => Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children: [PlaceCard(t)])));
}

/* ───────── Favorit ───────── */
class FavoritPage extends StatelessWidget {
  const FavoritPage({super.key});
  @override
  Widget build(BuildContext c) => ListenableBuilder(listenable: App.i, builder: (_, __) {
    final l = [for (final id in App.i.favList) ...App.i.semua.where((t) => t.id == id)];
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Favorit', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
      Text(l.isEmpty ? 'Tempat yang kamu simpan muncul di sini' : '${l.length} tempat yang kamu simpan', style: const TextStyle(color: Colors.black54)),
      const SizedBox(height: 14),
      if (l.isEmpty) const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('Belum ada favorit.\nKetuk ikon hati di tempat yang ingin kamu datangi nanti.', textAlign: TextAlign.center)))
      else for (final t in l) Padding(padding: const EdgeInsets.only(bottom: 12), child: PlaceCard(t)),
    ]);
  });
}

/* ───────── Profil (akun lokal, pengganti backend) ───────── */
class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});
  @override
  State<ProfilPage> createState() => _ProfilState();
}
class _ProfilState extends State<ProfilPage> {
  bool daftar = false, lihat = false, setuju = false;
  final nama = TextEditingController(), email = TextEditingController(text: 'demo@foodfinder.id'), sandi = TextEditingController(text: 'demo123');
  String? err;

  void kirim() {
    final s = App.i.s, e = email.text.trim().toLowerCase();
    if (daftar) {
      if (nama.text.trim().length < 2) return setState(() => err = 'Isi nama minimal 2 huruf.');
      if (kasar(nama.text)) return setState(() => err = 'Nama mengandung kata yang tidak pantas.');
      if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(e)) return setState(() => err = 'Format email belum benar.');
      if (sandi.text.length < 6) return setState(() => err = 'Kata sandi minimal 6 karakter.');
      if ((s['akun'] as List).any((a) => a['email'] == e)) return setState(() => err = 'Email ini sudah terdaftar.');
      if (!setuju) return setState(() => err = 'Centang persetujuan Ketentuan dan Kebijakan Privasi dulu.');
      final a = {'id': 'u${DateTime.now().millisecondsSinceEpoch}', 'nama': nama.text.trim(), 'email': e, 'sandi': sandi.text};
      s['akun'].add(a);
      s['sesi'] = a['id'];
    } else {
      final a = (s['akun'] as List).where((x) => x['email'] == e && x['sandi'] == sandi.text);
      if (a.isEmpty) return setState(() => err = 'Email atau kata sandi salah.');
      s['sesi'] = a.first['id'];
    }
    err = null;
    App.i.simpan();
    pesan(context, 'Berhasil masuk. Selamat datang!');
  }

  Future<void> hapusAkun() async {
    final ya = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Hapus akun permanen?'), content: const Text('Akun, ulasan, dan favoritmu dihapus dan tidak bisa dikembalikan.'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Hapus'))]));
    if (ya != true) return;
    final s = App.i.s, id = s['sesi'];
    s['akun'] = (s['akun'] as List).where((a) => a['id'] != id).toList();
    for (final k in (s['ulasan'] as Map).keys.toList()) { s['ulasan'][k] = (s['ulasan'][k] as List).where((r) => r['uid'] != id).toList(); }
    (s['favorit'] as Map).remove(id);
    s['sesi'] = null;
    App.i.simpan();
  }

  @override
  Widget build(BuildContext c) => ListenableBuilder(listenable: App.i, builder: (_, __) {
    final u = App.i.user;
    final tema = SwitchListTile(secondary: const Icon(Icons.dark_mode), title: const Text('Mode gelap'), value: App.i.gelap, onChanged: (v) { App.i.s['gelap'] = v; App.i.simpan(); });
    final info = const ListTile(leading: Icon(Icons.shield), title: Text('Data tempat © Google Maps'), subtitle: Text('Lokasi hanya dipakai di HP untuk menghitung jarak.'));
    if (u == null) {
      return ListView(padding: const EdgeInsets.all(20), children: [
        Text(daftar ? 'Buat akun' : 'Masuk', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const Text('Supaya bisa memberi penilaian dan menyimpan favorit di akunmu.', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 14),
        SegmentedButton<bool>(segments: const [ButtonSegment(value: false, label: Text('Masuk')), ButtonSegment(value: true, label: Text('Daftar'))], selected: {daftar}, onSelectionChanged: (v) => setState(() { daftar = v.first; err = null; if (daftar) { email.clear(); sandi.clear(); } else { email.text = 'demo@foodfinder.id'; sandi.text = 'demo123'; } })),
        const SizedBox(height: 14),
        if (daftar) TextField(controller: nama, decoration: const InputDecoration(labelText: 'Nama', border: OutlineInputBorder())),
        if (daftar) const SizedBox(height: 12),
        TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: sandi, obscureText: !lihat, decoration: InputDecoration(labelText: 'Kata sandi', border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(lihat ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => lihat = !lihat)))),
        if (daftar) CheckboxListTile(contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading, value: setuju, onChanged: (v) => setState(() => setuju = v!), title: const Text('Saya setuju dengan Ketentuan Penggunaan dan Kebijakan Privasi, termasuk tidak mengunggah konten kasar.', style: TextStyle(fontSize: 12.5))),
        if (err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(err!, style: const TextStyle(color: Color(0xFFB3261E), fontWeight: FontWeight.w700))),
        const SizedBox(height: 12),
        FilledButton(onPressed: kirim, style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)), child: Text(daftar ? 'Daftar' : 'Masuk')),
        if (!daftar) const Padding(padding: EdgeInsets.only(top: 8), child: Text('Akun demo sudah terisi, tinggal ketuk Masuk.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: Colors.black54))),
        const SizedBox(height: 12), tema, info,
      ]);
    }
    final nUlasan = (App.i.s['ulasan'] as Map).values.expand((l) => l as List).where((r) => r['uid'] == u['id']).length;
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Profil', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      Card(child: ListTile(contentPadding: const EdgeInsets.all(16), leading: CircleAvatar(radius: 28, backgroundColor: emas, child: Text(u['nama'].substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87))), title: Text(u['nama'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)), subtitle: Text(u['email']))),
      Row(children: [for (final e in {'Ulasan': nUlasan, 'Favorit': App.i.favList.length}.entries) Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${e.value}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: merah)), Text(e.key)]))))]),
      tema,
      ListTile(leading: const Icon(Icons.my_location), title: const Text('Lokasi saya'), subtitle: Text(App.i.lokasi == null ? 'Belum diatur' : 'Aktif'), onTap: () async { final e = await App.i.deteksiLokasi(); if (c.mounted) pesan(c, e ?? 'Lokasi diperbarui.'); }),
      ListTile(leading: const Icon(Icons.logout), title: const Text('Keluar'), onTap: () { App.i.s['sesi'] = null; App.i.simpan(); }),
      ListTile(leading: const Icon(Icons.delete, color: Color(0xFFB3261E)), title: const Text('Hapus akun', style: TextStyle(color: Color(0xFFB3261E))), onTap: hapusAkun),
      info,
    ]);
  });
}