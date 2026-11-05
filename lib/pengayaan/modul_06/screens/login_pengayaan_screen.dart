import 'package:flutter/material.dart';

import '../../../modul_06/widgets/field_kata_sandi.dart';
import '../controllers/sesi_controller.dart';

/// Layar login Fase B: TIDAK menyimpan kebenaran (tidak ada _status,
/// tidak ada try/catch). Ia hanya menampilkan apa kata pengendali.
class LoginPengayaanScreen extends StatefulWidget {
  final SesiController controller;

  const LoginPengayaanScreen({super.key, required this.controller});

  @override
  State<LoginPengayaanScreen> createState() => _LoginPengayaanScreenState();
}

class _LoginPengayaanScreenState extends State<LoginPengayaanScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _sandi = TextEditingController();

  static String? _validasiEmail(String? nilai) {
    final String teks = (nilai ?? '').trim();
    if (teks.isEmpty) return 'Email wajib diisi.';
    if (!teks.contains('@') || !teks.contains('.')) {
      return 'Format email belum benar.';
    }
    return null;
  }

  Future<void> _kirim() async {
    if (widget.controller.status == StatusSesi.memproses) return;
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await widget.controller.masuk(email: _email.text, sandi: _sandi.text);
  }

  @override
  void dispose() {
    _email.dispose();
    _sandi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SesiController kendali = widget.controller;
    final bool sibuk = kendali.status == StatusSesi.memproses;
    final String? pesan = kendali.pesan;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        const SizedBox(height: 8),
        const Text(
          'Masuk ke Portal Akademik',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        if (pesan != null) ...<Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              pesan,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _email,
                enabled: !sibuk,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.email],
                validator: _validasiEmail,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FieldKataSandi(
                controller: _sandi,
                enabled: !sibuk,
                validator: (String? nilai) {
                  if (nilai == null || nilai.isEmpty) {
                    return 'Kata sandi wajib diisi.';
                  }
                  if (nilai.length < 8) {
                    return 'Kata sandi minimal 8 karakter.';
                  }
                  return null;
                },
                onSubmitted: _kirim,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: sibuk ? null : _kirim,
            icon: sibuk
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.login_rounded),
            label: Text(sibuk ? 'Memproses…' : 'Masuk'),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: sibuk
              ? null
              : () => setState(() {
                    _email.text = 'student@trpl.test';
                    _sandi.text = 'belajar123';
                  }),
          child: const Text('Isi otomatis akun demo'),
        ),
      ],
    );
  }
}