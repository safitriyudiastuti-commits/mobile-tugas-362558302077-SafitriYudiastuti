import 'package:flutter/material.dart';

import '../../modul_06/services/auth_api.dart';
import '../../modul_06/services/sesi_memori.dart';
import 'controllers/sesi_controller.dart';
import 'repositories/aman_sesi_repository.dart';
import 'repositories/memori_sesi_repository.dart';
import 'repositories/prefs_sesi_repository.dart';
import 'repositories/sesi_repository.dart';
import 'screens/beranda_pengayaan_screen.dart';
import 'screens/login_pengayaan_screen.dart';
import 'storage/penyimpanan_aman_platform.dart';
import 'widgets/gerbang_sesi.dart';

class Modul06PengayaanApp extends StatefulWidget {
  const Modul06PengayaanApp({super.key});

  @override
  State<Modul06PengayaanApp> createState() => _Modul06PengayaanAppState();
}

class _Modul06PengayaanAppState extends State<Modul06PengayaanApp> {
  // Dibuat sekali, hidup lebih lama dari satu kali build().
  late final List<SesiRepository> _repos = <SesiRepository>[
    MemoriSesiRepository(SesiMemori()),
    PrefsSesiRepository(),
    AmanSesiRepository(PenyimpananAmanPlatform()),
  ];

  int _indeks = 2; // Mulai dari penyimpanan "Aman".

  late final SesiController _kendali = SesiController(
    repository: _repos[_indeks],
    api: const AuthApi(),
  );

  @override
  void initState() {
    super.initState();
    _kendali.pulihkan();
  }

  @override
  void dispose() {
    _kendali.dispose();
    super.dispose();
  }

  void _pilih(int indeks) {
    setState(() => _indeks = indeks);
    _kendali.gantiPenyimpanan(_repos[indeks]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modul 06 — Fase B',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0284C7)),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Modul 06 — Secure Storage (Fase B)'),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: SegmentedButton<int>(
                  segments: const <ButtonSegment<int>>[
                    ButtonSegment<int>(value: 0, label: Text('Memori')),
                    ButtonSegment<int>(value: 1, label: Text('Prefs')),
                    ButtonSegment<int>(value: 2, label: Text('Aman')),
                  ],
                  selected: <int>{_indeks},
                  onSelectionChanged: (Set<int> pilihan) =>
                      _pilih(pilihan.first),
                ),
              ),
              Expanded(
                child: GerbangSesi(
                  controller: _kendali,
                  form: (BuildContext context) =>
                      LoginPengayaanScreen(controller: _kendali),
                  beranda: (BuildContext context, sesi) =>
                      BerandaPengayaanScreen(
                    controller: _kendali,
                    sesi: sesi,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}