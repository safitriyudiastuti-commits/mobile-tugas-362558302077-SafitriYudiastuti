import 'package:flutter/foundation.dart';

import '../../../modul_06/models/sesi_pengguna.dart';
import '../../../modul_06/services/auth_api.dart';
import '../repositories/sesi_repository.dart';

enum StatusSesi { memeriksa, keluar, memproses, masuk, gagal, kedaluwarsa }

/// Satu-satunya tempat yang "tahu kebenaran" tentang sesi.
/// Layar hanya menampilkan apa yang dikatakan pengendali ini.
class SesiController extends ChangeNotifier {
  SesiRepository repository;
  final AuthApi api;
  final DateTime Function() jam;

  StatusSesi _status = StatusSesi.memeriksa;
  SesiPengguna? _sesi;
  String? _pesan;
  bool _dibuang = false;

  SesiController({
    required this.repository,
    required this.api,
    this.jam = DateTime.now,
  });

  StatusSesi get status => _status;
  SesiPengguna? get sesi => _sesi;
  String? get pesan => _pesan;

  void _ubah(StatusSesi status, {SesiPengguna? sesi, String? pesan}) {
    _status = status;
    _sesi = sesi;
    _pesan = pesan;
    if (!_dibuang) notifyListeners();
  }

  /// Dipanggil saat aplikasi dibuka: adakah sesi tersimpan?
  Future<void> pulihkan() async {
    _ubah(StatusSesi.memeriksa);

    final SesiPengguna? tersimpan = await repository.baca();
    if (tersimpan == null) {
      _ubah(StatusSesi.keluar);
      return;
    }

    if (tersimpan.sudahKedaluwarsa(jam())) {
      await repository.hapus(); // Sesi mati dibuang, bukan dibiarkan.
      _ubah(
        StatusSesi.kedaluwarsa,
        pesan: 'Sesi Anda sudah berakhir. Silakan masuk kembali.',
      );
      return;
    }

    _ubah(StatusSesi.masuk, sesi: tersimpan);
  }

  Future<void> masuk({required String email, required String sandi}) async {
    if (_status == StatusSesi.memproses) return; // Cegah kirim ganda.
    _ubah(StatusSesi.memproses);

    try {
      final SesiPengguna hasil = await api.masuk(email: email, sandi: sandi);
      await repository.simpan(hasil);
      _ubah(StatusSesi.masuk, sesi: hasil);
    } on AuthException catch (e) {
      _ubah(StatusSesi.gagal, pesan: e.pesan);
    } catch (e) {
      debugPrint('Login gagal tak terduga: $e');
      _ubah(
        StatusSesi.gagal,
        pesan: 'Terjadi kesalahan tak terduga. Coba lagi.',
      );
    }
  }

  Future<void> keluar() async {
    await repository.hapus();
    _ubah(StatusSesi.keluar); // Bukan gagal: keluar bukan kesalahan.
  }

  /// Pembaruan hanya boleh berjalan bila sesi BELUM mati.
  Future<void> perbaruiSesi({
    Duration masaBerlaku = const Duration(hours: 2),
  }) async {
    final SesiPengguna? sekarang = _sesi;
    if (sekarang == null) return;

    if (sekarang.sudahKedaluwarsa(jam())) {
      await repository.hapus();
      _ubah(
        StatusSesi.kedaluwarsa,
        pesan: 'Sesi sudah berakhir dan tidak dapat diperbarui.',
      );
      return;
    }

    final SesiPengguna baru =
        await api.perbaruiSesi(sekarang, masaBerlaku: masaBerlaku);
    await repository.simpan(baru);
    _ubah(StatusSesi.masuk, sesi: baru);
  }

  /// Berpindah penyimpanan TIDAK memindahkan sesi lama:
  /// pengguna harus login ulang di penyimpanan baru.
  void gantiPenyimpanan(SesiRepository baru) {
    repository = baru;
      pulihkan();
  }

  @override
  void dispose() {
    _dibuang = true;
    super.dispose();
  }
}
