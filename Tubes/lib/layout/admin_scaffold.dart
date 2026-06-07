import 'package:flutter/material.dart';

import '../pages/admin/dashboard_admin_page.dart';
import '../pages/admin/tampil_data_page.dart';
import '../pages/admin/tambah_pelanggan_page.dart';
import '../pages/admin/data_user_page.dart';

class AdminScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const AdminScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  void goToPage(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // Fungsi untuk memunculkan modal dialog konfirmasi keluar dari sistem PAMDES
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
          content: const Text('Apakah Anda yakin ingin keluar dari akun Admin PAMDES?'),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(), // Menutup dialog saja
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
                backgroundColor: const Color(0xffd32f2f), // Warna merah untuk aksi krusial/logout
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Tutup dialog konfirmasi terlebih dahulu
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

  void onMenuTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    if (index == 0) {
      goToPage(context, const DashboardAdminPage());
    } else if (index == 1) {
      goToPage(context, const TampilDataPage());
    } else if (index == 2) {
      goToPage(context, const TambahPelangganPage());
    } else if (index == 3) {
      goToPage(context, const DataUserPage());
    } else if (index == 4) {
      // Mengalihkan logika langsung ke fungsi dialog konfirmasi
      showLogoutConfirmation(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeef0f3),

      appBar: AppBar(
        title: const Text(
          'PAMDES ADMIN',
          style: TextStyle(
            fontWeight: FontWeight.bold,
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
        currentIndex: currentIndex,
        onTap: (index) => onMenuTap(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xff0d7db8),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart),
            label: 'Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Tambah',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.speed),
            label: 'Meteran',
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