import 'package:flutter/material.dart';

import '../../layout/pelanggan_scaffold.dart';

class DashboardPelangganPage extends StatelessWidget {
  const DashboardPelangganPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PelangganScaffold(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoSection(
                  icon: Icons.description_outlined,
                  iconColor: Colors.purple,
                  title: 'Belum Ada Riwayat',
                  subtitle: 'Transaksi pembayaran kamu akan tampil di sini.',
                ),
                SizedBox(height: 28),
                _InfoSection(
                  icon: Icons.check_box,
                  iconColor: Colors.green,
                  title: 'Tidak Ada Tagihan',
                  subtitle: 'Semua tagihan kamu sudah lunas. Terima kasih 🙏',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _InfoSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}