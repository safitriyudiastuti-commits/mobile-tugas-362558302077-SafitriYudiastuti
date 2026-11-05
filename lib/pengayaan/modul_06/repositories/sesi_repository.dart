import 'dart:convert';

import '../../../modul_06/models/sesi_pengguna.dart';

/// Kontrak sesi. Berkas ini sengaja TIDAK mengimpor shared_preferences
/// maupun flutter_secure_storage.
abstract class SesiRepository {
  String get nama;
  String get keterangan;
  bool get bertahanSetelahRestart;

  Future<SesiPengguna?> baca();
  Future<void> simpan(SesiPengguna sesi);
  Future<void> hapus();
  Future<bool> adaSesi();

  /// Nilai ini adalah demonstrasi batas API, bukan pemeriksaan isi disk.
  Future<String?> intipMentah();

  /// Mengubah teks JSON menjadi sesi. Data rusak -> null (bukan crash).
  static SesiPengguna? uraiJson(String mentah) {
    try {
      final Object? data = jsonDecode(mentah);
      if (data is Map<String, dynamic>) {
        return SesiPengguna.fromJson(data);
      }
      return null;
    } on FormatException {
      return null;
    }
  }
}