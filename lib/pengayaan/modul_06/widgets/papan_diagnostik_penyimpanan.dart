import 'package:flutter/material.dart';

import '../repositories/sesi_repository.dart';

/// Papan yang membuktikan klaim Bagian 6.8: tombol "intip" meniru
/// penyerang yang dapat membaca berkas aplikasi.
/// Papan ini hanya mengenal kontrak [SesiRepository].
class PapanDiagnostikPenyimpanan extends StatefulWidget {
  final SesiRepository repository;

  const PapanDiagnostikPenyimpanan({super.key, required this.repository});

  @override
  State<PapanDiagnostikPenyimpanan> createState() =>
      _PapanDiagnostikPenyimpananState();
}

class _PapanDiagnostikPenyimpananState
    extends State<PapanDiagnostikPenyimpanan> {
  String? _hasilIntip;
  bool _sudahMengintip = false;
  bool _sedangMengintip = false;

  @override
  void didUpdateWidget(covariant PapanDiagnostikPenyimpanan oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      _hasilIntip = null;
      _sudahMengintip = false;
    }
  }

  Future<void> _intip() async {
    setState(() => _sedangMengintip = true);
    final String? hasil = await widget.repository.intipMentah();
    if (!mounted) return;
    setState(() {
      _hasilIntip = hasil;
      _sudahMengintip = true;
      _sedangMengintip = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final SesiRepository repo = widget.repository;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Papan diagnostik penyimpanan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Penyimpanan aktif: ${repo.nama}'),
            Text(repo.keterangan),
            Text(
              'Bertahan setelah restart: '
              '${repo.bertahanSetelahRestart ? "Ya" : "Tidak"}',
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _sedangMengintip ? null : _intip,
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('Intip isi penyimpanan'),
            ),
            if (_sudahMengintip) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                _hasilIntip == null
                    ? 'Hasil: null (tidak ada nilai yang terbaca)'
                    : 'Hasil terbaca:',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (_hasilIntip != null) SelectableText(_hasilIntip!),
            ],
          ],
        ),
      ),
    );
  }
}