import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pamdes/services/api_service.dart';
import '../../layout/admin_scaffold.dart';
import '../../layout/app_button.dart';
import 'tampil_data_page.dart';

class InputMeteranPage extends StatefulWidget {
  final int userId;
  final String nama;
  final String alamat;
  final String noHp;

  const InputMeteranPage({
    super.key,
    required this.userId,
    required this.nama,
    required this.alamat,
    required this.noHp,
  });

  @override
  State<InputMeteranPage> createState() => _InputMeteranPageState();
}

class _InputMeteranPageState extends State<InputMeteranPage> {
  final tanggalController = TextEditingController();
  final meteranController = TextEditingController();
  bool _loading = false;
  int _harga = 0;

  @override
  void initState() {
    super.initState();
    meteranController.addListener(() {
      final meteran = int.tryParse(meteranController.text) ?? 0;
      setState(() => _harga = meteran * 500);
    });
  }

  @override
  void dispose() {
    tanggalController.dispose();
    meteranController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      tanggalController.text =
          '${picked.year}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Widget label(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
  );

  void submit() async {
    final tanggal = tanggalController.text.trim();
    final meteran = meteranController.text.trim();

    if (tanggal.isEmpty || meteran.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_harga == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meteran harus lebih dari 0'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await ApiService.inputMeteran({
        'user_id' : widget.userId,
        'meteran' : meteran,
        'harga'   : _harga,
        'tanggal' : tanggal,
      });

      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data meteran berhasil disimpan'), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const TampilDataPage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal menyimpan'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat terhubung ke server'), backgroundColor: Colors.red),
      );
    }

    setState(() => _loading = false);
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
              BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Input Meteran',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xff0d7db8)),
              ),
              const SizedBox(height: 24),

              // INFO USER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xfff0f9ff),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow('Nama',   widget.nama),
                    _InfoRow('Alamat', widget.alamat),
                    _InfoRow('No HP',  widget.noHp),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              label('Tanggal Tagihan'),
              const SizedBox(height: 6),
              TextField(
                controller: tanggalController,
                readOnly: true,
                onTap: pickDate,
                decoration: InputDecoration(
                  hintText: 'Pilih tanggal',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: pickDate,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              label('Input Meteran'),
              const SizedBox(height: 6),
              TextField(
                controller: meteranController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Masukkan angka meteran'),
              ),
              const SizedBox(height: 16),

              label('Harga (otomatis)'),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xfff0f9ff),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  'Rp ${NumberFormat('#,###', 'id_ID').format(_harga)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff0d7db8)),
                ),
              ),
              const SizedBox(height: 24),

              _loading
                ? const CircularProgressIndicator()
                : AppButton(text: 'Submit', onPressed: submit),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          const Text(': ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}