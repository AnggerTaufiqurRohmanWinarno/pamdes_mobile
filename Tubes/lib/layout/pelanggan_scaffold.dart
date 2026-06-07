import 'package:flutter/material.dart';
import 'package:pamdes/services/api_service.dart';

class PelangganScaffold extends StatelessWidget {
  final Widget child;

  const PelangganScaffold({
    super.key,
    required this.child,
  });

  void showContactUs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Row(
            children: [
              Icon(Icons.contact_support, color: Color(0xff0d7db8)),
              SizedBox(width: 10),
              Text(
                'Contact Us',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Silakan hubungi admin PAMDES untuk bantuan lebih lanjut.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Tutup',
                style: TextStyle(
                  color: Color(0xff0d7db8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Fungsi konfirmasi sebelum melakukan logout akun pelanggan
  void showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Color(0xff0d7db8)),
              SizedBox(width: 10),
              Text(
                'Konfirmasi Keluar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi PAMDES?'),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(), // Menutup dialog
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffd32f2f), // Warna merah tegas
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Tutup modal konfirmasi
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              },
              child: const Text(
                'Keluar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),

      appBar: AppBar(
        title: Text(
          ApiService.nama ?? 'Pelanggan',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: const Color(0xff0d7db8),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),

      body: SafeArea(
        child: child,
      ),

      bottomNavigationBar: BottomNavigationBar(
        // Di-set -1 atau biarkan tetap agar tidak ada tab yang terlihat aktif secara permanen 
        // karena keduanya bersifat tombol aksi (Trigger dialog/navigasi langsung)
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            showContactUs(context);
          } else if (index == 1) {
            showLogoutConfirmation(context); // Diarahkan ke modal konfirmasi dulu
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xff0d7db8),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_support),
            label: 'Contact Us',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
      ),
    );
  }
}