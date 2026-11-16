// Parser jam buka FoodFinder (port dari prototype). Hari: 0=Senin ... 6=Minggu.
const namaHari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const _hari = {'sen': 0, 'sel': 1, 'rab': 2, 'kam': 3, 'jum': 4, 'sab': 5, 'min': 6};

typedef Jadwal = List<List<List<int>>>;

class Status {
  final String kode; // buka | segera | tutup | tidak-ada
  final String teks;
  final bool? buka;
  const Status(this.kode, this.teks, this.buka);
}

int? _kode(String? k) {
  if (k == null) return null;
  final s = k.toLowerCase();
  return _hari[s.length >= 3 ? s.substring(0, 3) : s];
}

List<int> _rentang(String a, String? b) {
  final s = _kode(a)!, e = b == null ? s : _kode(b)!;
  final out = <int>[];
  for (var d = s;; d = (d + 1) % 7) {
    out.add(d);
    if (d == e) break;
  }
  return out;
}

List<List<int>> _baca(String t) {
  final re = RegExp(r'(\d{1,2})\.(\d{2})\s*–\s*(\d{1,2})\.(\d{2})');
  return re.allMatches(t).map((m) {
    final s = int.parse(m[1]!) * 60 + int.parse(m[2]!);
    var e = int.parse(m[3]!) * 60 + int.parse(m[4]!);
    if (e <= s) e += 1440; // lewat tengah malam
    return [s, e];
  }).toList();
}

String fmtJam(int mnt) {
  final x = ((mnt % 1440) + 1440) % 1440;
  return '${(x ~/ 60).toString().padLeft(2, '0')}.${(x % 60).toString().padLeft(2, '0')}';
}

Jadwal? parseJam(String? raw) {
  if (raw == null || raw.trim().isEmpty || raw.trim() == '-') return null;
  var s = raw.replaceAll('±', '').trim();
  final pengecualian = <String>[];
  s = s.replaceAllMapped(RegExp(r'\(([^)]*)\)'), (m) {
    pengecualian.add(m[1]!);
    return '';
  }).trim();
  final j = List.generate(7, (_) => <List<int>>[]);
  for (final segRaw in s.split(';')) {
    final seg = segRaw.trim();
    if (seg.isEmpty) continue;
    var hari = [0, 1, 2, 3, 4, 5, 6];
    var sisa = seg;
    final low = seg.toLowerCase();
    if (low.startsWith('setiap hari')) {
      sisa = seg.substring(11).trim();
    } else if (low.startsWith('buka 24 jam')) {
      sisa = '24 jam';
    } else {
      final m = RegExp(r'^([A-Za-z]+)(?:\s*–\s*([A-Za-z]+))?\s+(.*)$').firstMatch(seg);
      if (m != null && _kode(m[1]) != null && (m[2] == null || _kode(m[2]) != null)) {
        hari = _rentang(m[1]!, m[2]);
        sisa = m[3]!;
      }
    }
    final List<List<int>> slot = RegExp('tutup', caseSensitive: false).hasMatch(sisa)
        ? []
        : RegExp('24 jam', caseSensitive: false).hasMatch(sisa)
            ? [[0, 1440]]
            : _baca(sisa);
    for (final d in hari) {
      j[d] = slot.map((r) => [...r]).toList();
    }
  }
  for (final p in pengecualian) {
    var m = RegExp(r'^([A-Za-z]+) istirahat (.*)$').firstMatch(p);
    if (m != null && _kode(m[1]) != null) {
      final d = _kode(m[1])!;
      for (final r in _baca(m[2]!)) {
        final baru = <List<int>>[];
        for (final b in j[d]) {
          if (r[1] <= b[0] || r[0] >= b[1]) {
            baru.add(b);
          } else {
            if (r[0] > b[0]) baru.add([b[0], r[0]]);
            if (r[1] < b[1]) baru.add([r[1], b[1]]);
          }
        }
        j[d] = baru;
      }
      continue;
    }
    m = RegExp(r'^([A-Za-z]+) s\.d\. (\d{1,2})\.(\d{2})$').firstMatch(p);
    if (m != null && _kode(m[1]) != null) {
      final d = _kode(m[1])!;
      final e = int.parse(m[2]!) * 60 + int.parse(m[3]!);
      j[d] = j[d].map((r) => [r[0], e <= r[0] ? e + 1440 : e]).toList();
    }
  }
  return j;
}

Status statusBuka(Jadwal? j, int d, int m) {
  if (j == null) return const Status('tidak-ada', 'Jam buka tidak tersedia', null);
  if (j.every((h) => h.length == 1 && h[0][0] == 0 && h[0][1] >= 1440)) {
    return const Status('buka', 'Buka 24 jam', true);
  }
  final kemarin = (d + 6) % 7;
  final aktif = <int>[];
  for (final r in j[d]) {
    if (m >= r[0] && m < r[1]) aktif.add(r[1]);
  }
  for (final r in j[kemarin]) {
    if (r[1] > 1440 && m < r[1] - 1440) aktif.add(r[1] - 1440);
  }
  if (aktif.isNotEmpty) {
    var tutup = aktif.reduce((a, b) => a > b ? a : b);
    if (tutup == 1440) {
      for (final r in j[(d + 1) % 7]) {
        if (r[0] == 0) tutup = 1440 + r[1];
      }
    }
    if (tutup - m <= 60) return Status('segera', 'Segera tutup · ${fmtJam(tutup)}', true);
    return Status('buka', 'Buka · tutup ${fmtJam(tutup)}', true);
  }
  for (var i = 0; i < 8; i++) {
    final h = (d + i) % 7;
    final k = j[h].map((r) => r[0]).where((a) => i > 0 || a > m).toList()..sort();
    if (k.isNotEmpty) {
      final kapan = i == 0 ? '' : i == 1 ? ' besok' : ' ${namaHari[h]}';
      return Status('tutup', 'Tutup · buka$kapan ${fmtJam(k.first)}', false);
    }
  }
  return const Status('tutup', 'Tutup', false);
}
