import 'package:flutter/material.dart';

import '../../layout/admin_scaffold.dart';
import '../../layout/app_button.dart';

class InputMeteranPage extends StatefulWidget {
  const InputMeteranPage({super.key});

  @override
  State<InputMeteranPage> createState() => _InputMeteranPageState();
}

class _InputMeteranPageState extends State<InputMeteranPage> {
  final namaController = TextEditingController();
  final alamatController = TextEditingController();
  final teleponController = TextEditingController();
  final tanggalController = TextEditingController();
  final meteranController = TextEditingController();
  final hargaController = TextEditingController();

  Future<void> pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: now,
    );

    if (picked != null) {
      tanggalController.text =
          '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.year}';
    }
  }

  Widget label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  void submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fungsi input meteran belum disambungkan ke API'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentIndex: 3,
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
                'Input Meteran',
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
              ),
              const SizedBox(height: 16),

              label('Alamat'),
              const SizedBox(height: 6),
              TextField(
                controller: alamatController,
              ),
              const SizedBox(height: 16),

              label('No Telepon'),
              const SizedBox(height: 6),
              TextField(
                controller: teleponController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              label('Tanggal Tagihan'),
              const SizedBox(height: 6),
              TextField(
                controller: tanggalController,
                readOnly: true,
                onTap: pickDate,
                decoration: InputDecoration(
                  hintText: 'dd/mm/yyyy',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: pickDate,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              label('Input meteran'),
              const SizedBox(height: 6),
              TextField(
                controller: meteranController,
                decoration: const InputDecoration(
                  hintText: 'Masukkan meter',
                ),
              ),
              const SizedBox(height: 16),

              label('Harga'),
              const SizedBox(height: 6),
              TextField(
                controller: hargaController,
                keyboardType: TextInputType.number,
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