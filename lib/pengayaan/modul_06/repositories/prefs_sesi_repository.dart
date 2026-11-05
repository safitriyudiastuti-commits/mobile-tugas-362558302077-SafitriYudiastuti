import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../modul_06/models/sesi_pengguna.dart';
import 'sesi_repository.dart';

/// Bertahan setelah restart, TETAPI token tersimpan apa adanya (bukan rahasia aman).
/// Sengaja disertakan supaya kelemahannya bisa dibuktikan.
class PrefsSesiRepository implements SesiRepository {
  static const String kunciSesi = 'modul_06_sesi_pengguna';

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  String get nama => 'Prefs';

  @override
  String get keterangan =>
      'SharedPreferences. Bertahan, tetapi token terbaca apa adanya.';

  @override
  bool get bertahanSetelahRestart => true;

  @override
  Future<SesiPengguna?> baca() async {
    final SharedPreferences prefs = await _prefs;
    final String? mentah = prefs.getString(kunciSesi);
    if (mentah == null) return null;

    final SesiPengguna? sesi = SesiRepository.uraiJson(mentah);
    if (sesi == null) {
      await prefs.remove(kunciSesi); // Data rusak dibuang.
    }
    return sesi;
  }

  @override
  Future<void> simpan(SesiPengguna sesi) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(kunciSesi, jsonEncode(sesi.toJson()));
  }

  @override
  Future<void> hapus() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove(kunciSesi);
  }

  @override
  Future<bool> adaSesi() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.containsKey(kunciSesi);
  }

  @override
  Future<String?> intipMentah() async {
    final SharedPreferences prefs = await _prefs;
    // Demonstrasi: adapter preferensi mengembalikan nilai token lewat API biasa.
    return prefs.getString(kunciSesi);
  }
}