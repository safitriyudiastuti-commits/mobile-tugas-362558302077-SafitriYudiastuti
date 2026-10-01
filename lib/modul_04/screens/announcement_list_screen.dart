import 'package:flutter/material.dart';
import 'package:poliwangi_mobile_starter/modul_04/models/announcement.dart';
import 'package:poliwangi_mobile_starter/modul_04/screens/announcement_detail_screen.dart';
import 'package:poliwangi_mobile_starter/modul_04/services/announcement_api.dart';
import 'package:poliwangi_mobile_starter/modul_04/widgets/announcement_card.dart';

class AnnouncementListScreen extends StatefulWidget {
  const AnnouncementListScreen({super.key, this.api});

  /// Dapat disuntikkan dari luar (widget test atau demo offline).
  final AnnouncementApi? api;

  @override
  State<AnnouncementListScreen> createState() => _AnnouncementListScreenState();
}

class _AnnouncementListScreenState extends State<AnnouncementListScreen> {
  static const List<String> _kategori = <String>[
    'Semua',
    'Akademik',
    'Beasiswa',
    'Kegiatan',
    'Prestasi',
  ];

  late final AnnouncementApi _api = widget.api ?? AnnouncementApi();

  late Future<List<Announcement>> _futurePengumuman;

  String _kategoriTerpilih = 'Semua';

  @override
  void initState() {
    super.initState();
    _futurePengumuman = _api.ambilPengumuman();
  }

  @override
  void dispose() {
    _api.tutup();
    super.dispose();
  }

  Future<void> _muatUlang() async {
    final Future<List<Announcement>> futureBaru = _api.ambilPengumuman();
    setState(() {
      _futurePengumuman = futureBaru;
    });

    try {
      await futureBaru;
    } catch (_) {
      // Error sudah ditangani FutureBuilder lewat snapshot.hasError.
      // Blok catch ini hanya mencegah "unhandled exception" dan memastikan
      // RefreshIndicator berhenti berputar.
    }
  }

  void _pilihKategori(String kategori) {
    if (kategori == _kategoriTerpilih) return;
    setState(() => _kategoriTerpilih = kategori);
  }

  // PERBAIKAN: nama diberi garis bawah (_bukaDetail) agar sama dengan
  // pemanggilnya di _buildDaftar.
  void _bukaDetail(Announcement announcement) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) =>
            AnnouncementDetailScreen(announcement: announcement),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal Pengumuman TRPL'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan Data',
            onPressed: _muatUlang,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildBarisFilter(),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<Announcement>>(
              future: _futurePengumuman,
              builder: (context, snapshot) {
                // Keadaan 1: LOADING
                if (snapshot.connectionState != ConnectionState.done) {
                  return _buildMemuat();
                }
                // Keadaan 2: ERROR
                if (snapshot.hasError) {
                  return _buildGagal(snapshot.error!);
                }
                // Keadaan 3 & 4: KOSONG / BERHASIL
                final List<Announcement> semua =
                    snapshot.data ?? const <Announcement>[];

                final List<Announcement> tampil = _kategoriTerpilih == 'Semua'
                    ? semua
                    : semua
                        .where(
                          (Announcement item) =>
                              item.category.toLowerCase() ==
                              _kategoriTerpilih.toLowerCase(),
                        )
                        .toList(growable: false);

                if (tampil.isEmpty) return _buildKosong();
                return _buildDaftar(tampil);
              },
            ),
          ),
        ],
      ),
    );
  }

  // KUMPULAN WIDGET HELPER

  Widget _buildBarisFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _kategori.map((cat) {
            final isSelected = _kategoriTerpilih == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                selectedColor: const Color(0xFFE0F2FE),
                labelStyle: TextStyle(
                  color: isSelected
                      ? const Color(0xFF0284C7)
                      : const Color(0xFF475569),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
                onSelected: (selected) {
                  if (selected) _pilihKategori(cat);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMemuat() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color(0xFF0284C7)),
          SizedBox(height: 16),
          Text(
            'Memuat pengumuman dari server...',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildGagal(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'Gagal Memuat Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString().replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _muatUlang,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKosong() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 64, color: Color(0xFF94A3B8)),
          const SizedBox(height: 16),
          Text(
            'Tidak ada pengumuman untuk kategori "$_kategoriTerpilih"',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDaftar(List<Announcement> tampil) {
    return RefreshIndicator(
      color: const Color(0xFF0284C7),
      onRefresh: _muatUlang,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tampil.length,
        itemBuilder: (context, index) {
          final item = tampil[index];
          return AnnouncementCard(
            announcement: item,
            onTap: () => _bukaDetail(item),
          );
        },
      ),
    );
  }
}