import 'package:flutter/material.dart';

import '../../layout/admin_scaffold.dart';

class DataUserPage extends StatelessWidget {
  const DataUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentIndex: 3,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
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
                'Data User',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0d7db8),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff4ba3e2),
                      ),
                      icon: const Icon(Icons.search, color: Colors.white),
                      label: const Text(
                        'Cari',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xff0d7db8),
                  ),
                  columns: const [
                    DataColumn(label: HeaderCell('No')),
                    DataColumn(label: HeaderCell('Nama')),
                    DataColumn(label: HeaderCell('Alamat')),
                    DataColumn(label: HeaderCell('NO HP')),
                    DataColumn(label: HeaderCell('Aksi')),
                  ],
                  rows: const [],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Belum ada data user',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeaderCell extends StatelessWidget {
  final String text;

  const HeaderCell(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}