import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'penyimpanan_aman.dart';

/// Adapter yang memenuhi kontrak [PenyimpananAman] memakai flutter_secure_storage.
class PenyimpananAmanPlatform implements PenyimpananAman {
  final FlutterSecureStorage _storage;

  PenyimpananAmanPlatform({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> tulis(String kunci, String nilai) =>
      _storage.write(key: kunci, value: nilai);

  @override
  Future<String?> baca(String kunci) => _storage.read(key: kunci);

  @override
  Future<void> hapus(String kunci) => _storage.delete(key: kunci);

  @override
  Future<String?> bacaMentah(String kunci) async {
    // Ilustrasi batas API: plugin tidak menyediakan pembacaan mentah
    // melalui kontrak ini. Ini bukan pemeriksaan forensik isi disk.
    return null;
  }
}