import '../../../modul_06/models/sesi_pengguna.dart';
import '../../../modul_06/services/sesi_memori.dart';
import 'sesi_repository.dart';

/// Membungkus SesiMemori dari Fase A (bukan menyalinnya).
class MemoriSesiRepository implements SesiRepository {
  final SesiMemori _memori;

  MemoriSesiRepository(this._memori);

  @override
  String get nama => 'Memori';

  @override
  String get keterangan =>
      'Variabel di memori proses. Hilang saat aplikasi ditutup.';

  @override
  bool get bertahanSetelahRestart => false;

  @override
  Future<SesiPengguna?> baca() async => _memori.baca();

  @override
  Future<void> simpan(SesiPengguna sesi) => _memori.simpan(sesi);

  @override
  Future<void> hapus() => _memori.hapus();

  @override
  Future<bool> adaSesi() async => _memori.adaSesi;

  @override
  Future<String?> intipMentah() async => null; // Tidak ada di disk.
}