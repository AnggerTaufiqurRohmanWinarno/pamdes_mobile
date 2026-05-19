import 'package:flutter/material.dart';

import '../../layout/admin_scaffold.dart';
import '../../layout/app_button.dart';

class TambahPelangganPage extends StatefulWidget {
  const TambahPelangganPage({super.key});

  @override
  State<TambahPelangganPage> createState() => _TambahPelangganPageState();
}

class _TambahPelangganPageState extends State<TambahPelangganPage> {
  final namaController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final konfirmasiController = TextEditingController();
  final alamatController = TextEditingController();
  final teleponController = TextEditingController();

  bool showPassword = false;
  bool showKonfirmasi = false;

  Widget label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget jarak() {
    return const SizedBox(height: 16);
  }

  void submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fungsi submit belum disambungkan ke API'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentIndex: 2,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Tambah Pelanggan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0d7db8),
                ),
              ),
              const SizedBox(height: 24),

              label('Nama'),
              const SizedBox(height: 6),
              TextField(
                controller: namaController,
                decoration: const InputDecoration(
                  hintText: 'Masukkan nama lengkap',
                ),
              ),
              jarak(),

              label('Username'),
              const SizedBox(height: 6),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  hintText: 'Masukkan username',
                ),
              ),
              jarak(),

              label('Password'),
              const SizedBox(height: 6),
              TextField(
                controller: passwordController,
                obscureText: !showPassword,
                decoration: InputDecoration(
                  hintText: 'Masukkan password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    icon: Icon(
                      showPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
              ),
              jarak(),

              label('Konfirmasi Password'),
              const SizedBox(height: 6),
              TextField(
                controller: konfirmasiController,
                obscureText: !showKonfirmasi,
                decoration: InputDecoration(
                  hintText: 'Masukkan password lagi',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        showKonfirmasi = !showKonfirmasi;
                      });
                    },
                    icon: Icon(
                      showKonfirmasi ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
              ),
              jarak(),

              label('Alamat'),
              const SizedBox(height: 6),
              TextField(
                controller: alamatController,
                decoration: const InputDecoration(
                  hintText: 'Masukkan alamat',
                ),
              ),
              jarak(),

              label('No Telepon'),
              const SizedBox(height: 6),
              TextField(
                controller: teleponController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Masukkan nomor telepon',
                ),
              ),
              const SizedBox(height: 20),

              AppButton(
                text: 'Submit',
                onPressed: submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}