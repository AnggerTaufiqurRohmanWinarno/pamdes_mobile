import 'package:flutter/material.dart';
import '../../layout/admin_scaffold.dart';
import 'package:pamdes/services/api_service.dart';
import 'input_meteran_page.dart';

const _blue = Color(0xff0077b6);
const _grayBorder = Color(0xffdddddd);

class DataUserPage extends StatefulWidget {
  const DataUserPage({super.key});

  @override
  State<DataUserPage> createState() => _DataUserPageState();
}

class _DataUserPageState extends State<DataUserPage> {
  List _users = [];
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
      final data = await ApiService.getUsersData();
      setState(() {
        _users    = data;
        _filtered = data;
        _loading  = false;
      });
    } catch (e) {
      setState(() {
        _error   = 'Gagal memuat data';
        _loading = false;
      });
    }
  }

  // FUNGSI PENCARIAN DIUPDATE: Bisa cari Nama, Alamat, dan No HP
  void _cari() {
    final keyword = _searchController.text.toLowerCase().trim();
    setState(() {
      _filtered = _users.where((u) {
        final nama    = u['name'].toString().toLowerCase();
        final alamat  = u['alamat'].toString().toLowerCase();
        final noHp    = u['noHp'].toString().toLowerCase();
        final username = u['username'].toString().toLowerCase();

        // Mencocokkan kata kunci ke semua field yang diinginkan
        return nama.contains(keyword) ||
               alamat.contains(keyword) ||
               noHp.contains(keyword) ||
               username.contains(keyword);
      }).toList();
    });
  }

  void _showHapusUserDialog(Map u) {
    final username = u['username'] ?? '';
    final nama     = u['name']     ?? '-';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus User'),
        content: Text('Yakin ingin menghapus user "$nama"?\nSemua data meterannya juga akan terhapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final result = await ApiService.deleteUser(username);
                if (result['status'] == 'success') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User berhasil dihapus'), backgroundColor: Colors.green),
                  );
                  _loadData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message'] ?? 'Gagal menghapus'), backgroundColor: Colors.red),
                  );
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
      currentIndex: 3,
      child: Container(
        padding: const EdgeInsets.all(18),
        color: const Color(0xfff4f6f9), // Background luar abu-abu
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
              const Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'Data User',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _blue),
                ),
              ),

              // SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari nama, alamat, atau no hp...', // Hint text disesuaikan
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        onChanged: (_) => _cari(), // Otomatis mencari saat admin mengetik teks
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

              // LIST USER VERTikal CARD
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
                                final u = _filtered[i];
                                return _itemCard(context, i + 1, u);
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

  // Widget untuk menampilkan satu card user
  Widget _itemCard(BuildContext context, int index, Map u) {
    return Container(
      width: double.infinity,
      color: index % 2 == 0 ? Colors.white : const Color(0xfff9f9f9),
      child: Column(
        children: [
          _itemField('No', '$index'),
          _itemField('Nama', u['name'] ?? '-'),
          _itemField('Alamat', u['alamat'] ?? '-'),
          _itemField('No HP', u['noHp'] ?? '-'),

          // Tombol Aksi di bagian bawah card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                const Text('Aksi', style: TextStyle(color: _blue, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 12),
                
                // Tombol Edit Input Meteran
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => InputMeteranPage(
                      userId: u['id'],
                      nama  : u['name']   ?? '',
                      alamat: u['alamat'] ?? '',
                      noHp  : u['noHp']   ?? '',
                    ),
                  )),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: const Color(0xff00a65a), borderRadius: BorderRadius.circular(4)),
                    child: const Icon(Icons.edit_note, color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('|', style: TextStyle(color: _grayBorder, fontSize: 16)),
                const SizedBox(width: 8),
                
                // Tombol Hapus User
                GestureDetector(
                  onTap: () => _showHapusUserDialog(u),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: const Color(0xffdd4b39), borderRadius: BorderRadius.circular(4)),
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

  // Widget pembantu untuk menampilkan satu field
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