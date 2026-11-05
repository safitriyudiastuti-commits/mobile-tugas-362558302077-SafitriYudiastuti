import 'dart:convert';

import '../../../modul_06/models/sesi_pengguna.dart';
import '../storage/penyimpanan_aman.dart';
import 'sesi_repository.dart';

/// Menyimpan sesi lewat kontrak [PenyimpananAman].
/// Perlindungan aktual mengikuti platform dan konfigurasi.
class AmanSesiRepository implements SesiRepository {
  static const String kunciSesi = 'modul_06_sesi_aman';

  final PenyimpananAman penyimpanan;

  AmanSesiRepository(this.penyimpanan);

  @override
  String get nama => 'Aman';

  @override
  String get keterangan =>
      'flutter_secure_storage (Keychain/Keystore). Bertahan; perlindungan mengikuti platform.';

  @override
  bool get bertahanSetelahRestart => true;

  @override
  Future<SesiPengguna?> baca() async {
    final String? mentah = await penyimpanan.baca(kunciSesi);
    if (mentah == null) return null;

    final SesiPengguna? sesi = SesiRepository.uraiJson(mentah);
    if (sesi == null) {
      await penyimpanan.hapus(kunciSesi); // Data rusak dibuang.
    }
    return sesi;
  }

  @override
  Future<void> simpan(SesiPengguna sesi) =>
      penyimpanan.tulis(kunciSesi, jsonEncode(sesi.toJson()));

  @override
  Future<void> hapus() => penyimpanan.hapus(kunciSesi);

  @override
  Future<bool> adaSesi() async => (await penyimpanan.baca(kunciSesi)) != null;

  @override
  Future<String?> intipMentah() => penyimpanan.bacaMentah(kunciSesi);
  // Adapter tidak menyediakan pembacaan mentah melalui API aplikasi.
}