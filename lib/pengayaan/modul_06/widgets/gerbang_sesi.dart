import 'package:flutter/material.dart';

import '../../../modul_06/models/sesi_pengguna.dart';
import '../controllers/sesi_controller.dart';

/// Satu tempat yang memilih layar berdasarkan status sesi.
/// (Mengatur pengalaman pengguna, BUKAN keamanan.)
class GerbangSesi extends StatelessWidget {
  final SesiController controller;
  final WidgetBuilder form;
  final Widget Function(BuildContext context, SesiPengguna sesi) beranda;

  const GerbangSesi({
    super.key,
    required this.controller,
    required this.form,
    required this.beranda,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? _) {
        switch (controller.status) {
          case StatusSesi.memeriksa:
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memeriksa sesi tersimpan…'),
                ],
              ),
            );
          case StatusSesi.masuk:
            final SesiPengguna? sesi = controller.sesi;
            if (sesi == null) return form(context);
            return beranda(context, sesi);
          case StatusSesi.keluar:
          case StatusSesi.memproses:
          case StatusSesi.gagal:
          case StatusSesi.kedaluwarsa:
            return form(context);
        }
      },
    );
  }
}