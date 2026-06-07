import 'package:flutter/material.dart';
import '../../layout/admin_scaffold.dart';
import 'package:pamdes/services/api_service.dart';
import 'package:intl/intl.dart';

final format = NumberFormat('#,##0', 'id_ID');
const _blue = Color(0xff0077b6);
const _grayBorder = Color(0xffdddddd);

class TampilDataPage extends StatefulWidget {
  const TampilDataPage({super.key});

  @override
  State<TampilDataPage> createState() => _TampilDataPageState();
}

class _TampilDataPageState extends State<TampilDataPage> {
  List _data = [];
  List _filtered = [];
  bool _loading = true;
  String _error = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final result = await ApiService.getTampilData();
      setState(() {
        _data     = result;
        _filtered = result;
        _loading  = false;
      });
    } catch (e) {
      setState(() {
        _error   = 'Gagal memuat data';
        _loading = false;
      });
    }
  }

  // FUNGSI PENCARIAN MULTI-FIELD (Nama, Status, No HP, Alamat)
  void _cari() {
    final keyword = _searchController.text.toLowerCase().trim();
    setState(() {
      _filtered = _data.where((d) {
        final user = d['user'] ?? {};
        
        // Ambil data teks keamanan dari null
        final nama = user['name'].toString().toLowerCase();
        final alamat = user['alamat'].toString().toLowerCase();
        final noHp = user['noHp'].toString().toLowerCase();
        final status = d['status'].toString().toLowerCase();

        // COCOKKAN KEYWORD
        return nama.contains(keyword) ||
               status.contains(keyword) ||
               noHp.contains(keyword) ||
               alamat.contains(keyword);
      }).toList();
    });
  }

  void _showEditDialog(Map d) {
    final rawStatus = d['status'] ?? 'Belum Lunas';
    String selectedStatus = (rawStatus == 'Lunas' || rawStatus == 'Belum Lunas')
        ? rawStatus : 'Belum Lunas';
    final slug = d['slug'] ?? '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Edit Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Status', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                items: const [
                  DropdownMenuItem(value: 'Belum Lunas', child: Text('Belum Lunas')),
                  DropdownMenuItem(value: 'Lunas',       child: Text('Lunas')),
                ],
                onChanged: (val) => setStateDialog(() => selectedStatus = val!),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _blue),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  final result = await ApiService.updateData(slug, {
                    'status'           : selectedStatus,
                    'metode_pembayaran': d['metode_pembayaran'] ?? 'Menunggu Konfirmasi',
                  });
                  if (result['status'] == 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Status berhasil diupdate'), backgroundColor: Colors.green),
                    );
                    _loadData();
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal mengupdate status'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showHapusDialog(Map d) {
    final slug = d['slug'] ?? '';
    final nama = d['user']?['name'] ?? '-';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Data'),
        content: Text('Yakin ingin menghapus data meteran milik "$nama"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final result = await ApiService.deleteData(slug);
                if (result['status'] == 'success') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data berhasil dihapus'), backgroundColor: Colors.green),
                  );
                  _loadData();
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tidak dapat terhubung ke server'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentIndex: 1,
      child: Container(
        padding: const EdgeInsets.all(18),
        color: const Color(0xfff4f6f9),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: Column(
            children: [
              // JUDUL
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                child: const Text(
                  'Tampil Data',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _blue),
                ),
              ),

              // SEARCH BAR (Petunjuk teks disesuaikan)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari nama, status, atau no hp...',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        onChanged: (_) => _cari(), // Real-time search saat mengetik
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _cari,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff3498db),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text('Cari', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),

              if (!_loading && _error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_error, style: const TextStyle(color: Colors.red)),
                ),

              // KONTEN CARD VERTIKAL
              if (!_loading && _error.isEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: _grayBorder),
                        ),
                        child: Column(
                          children: [
                            if (_filtered.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                color: Colors.white,
                                child: const Center(
                                  child: Text('Data tidak ditemukan', style: TextStyle(color: Colors.grey)),
                                ),
                              )
                            else
                              ...List.generate(_filtered.length, (i) {
                                final d = _filtered[i];
                                return _buildVerticalCard(i + 1, d);
                              }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalCard(int index, Map d) {
    final user = d['user'] ?? {};
    final hargaFormatted = 'Rp ${format.format(double.tryParse(d['harga'].toString()) ?? 0)}';
    final isEven = index % 2 == 0;

    return Container(
      width: double.infinity,
      color: isEven ? Colors.white : const Color(0xfff9f9f9),
      child: Column(
        children: [
          _itemField('No', '$index'),
          _itemField('Nama', user['name'] ?? '-'),
          _itemField('Alamat', user['alamat'] ?? '-'),
          _itemField('No HP', user['noHp'] ?? '-'),
          _itemField('Harga', hargaFormatted),
          _itemField('Jatuh Tempo', d['tanggal'] ?? '-'),
          _itemField('Pembayaran', d['metode_pembayaran'] ?? '-'),
          _itemField('Status', d['status'] ?? '-'),
          
          // Bagian Tombol Aksi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                const Text('Aksi', style: TextStyle(color: _blue, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 12),
                
                // Tombol Edit
                GestureDetector(
                  onTap: () => _showEditDialog(d),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: const Color(0xff5cb85c), borderRadius: BorderRadius.circular(4)),
                    child: const Icon(Icons.edit_note, color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('|', style: TextStyle(color: _grayBorder, fontSize: 16)),
                const SizedBox(width: 8),
                
                // Tombol Hapus
                GestureDetector(
                  onTap: () => _showHapusDialog(d),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: const Color(0xffd9534f), borderRadius: BorderRadius.circular(4)),
                    child: const Icon(Icons.delete, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _grayBorder),
        ],
      ),
    );
  }

  Widget _itemField(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xffeeeeee), width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: _blue, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}