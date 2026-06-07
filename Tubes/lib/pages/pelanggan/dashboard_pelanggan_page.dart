import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../layout/pelanggan_scaffold.dart';
import 'package:pamdes/services/api_service.dart';

class DashboardPelangganPage extends StatefulWidget {
  const DashboardPelangganPage({super.key});

  @override
  State<DashboardPelangganPage> createState() => _DashboardPelangganPageState();
}

class _DashboardPelangganPageState extends State<DashboardPelangganPage> {
  bool _loading = true;
  String _error = '';
  Map<String, dynamic> _tagihan = {};
  List _riwayat = [];
  String _nama = '';
  bool _showPilihanBayar = false;
  bool _menungguKonfirmasi = false;
  bool _prosesLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Mengubah return type menjadi Future<void> agar bisa dipakai di RefreshIndicator
  Future<void> _loadData() async {
    setState(() {
      _showPilihanBayar   = false;
      _menungguKonfirmasi = false;
    });
    try {
      final result = await ApiService.getDashboardPelanggan();
      setState(() {
        _nama    = result['nama'] ?? '';
        _tagihan = result['tagihan'] != null
            ? Map<String, dynamic>.from(result['tagihan'])
            : {};
        _riwayat = result['riwayat'] ?? [];
        _loading = false;

        if (_tagihan.isNotEmpty && (
          _tagihan['status'] == 'Menunggu Konfirmasi' ||
          _tagihan['status'] == 'Menunggu Pembayaran'
        )) {
          _menungguKonfirmasi = true;
        }
      });
    } catch (e) {
      setState(() {
        _error   = 'Gagal memuat data';
        _loading = false;
      });
    }
  }

  Future<void> _bayar(String method) async {
    final id = _tagihan['id'];
    if (id == null) return;

    setState(() => _prosesLoading = true);

    try {
      final result = await ApiService.storeMethodApi(id, method);
      print('RESULT: $result');

      if (result['success'] == true) {
        if (method == 'Tunai') {
          setState(() {
            _showPilihanBayar   = false;
            _menungguKonfirmasi = true;
            _prosesLoading      = false;
          });
        } else {
          final redirectUrl = result['redirect'];
          setState(() => _prosesLoading = false);
          if (redirectUrl != null && mounted) {
            await Navigator.push(context, MaterialPageRoute(
              builder: (_) => MidtransWebViewPage(
                url: redirectUrl,
                onSelesai: () {
                  Navigator.pop(context);
                  _loadData();
                },
              ),
            ));
          }
        }
      } else {
        setState(() => _prosesLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal memproses pembayaran'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('ERROR: $e');
      setState(() => _prosesLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat terhubung ke server'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatRupiah(dynamic harga) {
    return 'Rp ${NumberFormat('#,##0', 'id_ID').format(double.tryParse(harga.toString()) ?? 0)}';
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'Lunas': return Colors.green;
      case 'Menunggu Konfirmasi':
      case 'Menunggu Pembayaran': return Colors.blue;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PelangganScaffold(
      // 1. Tambahkan RefreshIndicator di sini
      child: RefreshIndicator(
        onRefresh: _loadData, // Fungsi yang dipanggil saat ditarik ke bawah
        color: const Color(0xff0d7db8),
        child: SingleChildScrollView(
          // 2. physics dicustom agar scroll tetep membal/bisa ditarik walaupun datanya sedikit
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            // 3. Memaksa isi container minimal seukuran layar perangkat agar trigger swipe-nya aktif
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 100, 
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_nama.isNotEmpty)
                    Text(
                      'Halo, $_nama 👋',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0d7db8),
                      ),
                    ),
                  const SizedBox(height: 16),

                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  if (!_loading && _error.isNotEmpty)
                    Text(_error, style: const TextStyle(color: Colors.red)),

                  if (!_loading && _error.isEmpty) ...[

                    // TAGIHAN AKTIF
                    _Card(
                      child: _tagihan.isEmpty
                        ? const _InfoSection(
                            icon: Icons.check_box,
                            iconColor: Colors.green,
                            title: 'Tidak Ada Tagihan',
                            subtitle: 'Semua tagihan kamu sudah lunas. Terima kasih 🙏',
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Tagihan Aktif',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff0d7db8),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _statusColor(_tagihan['status']),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _tagihan['status'] ?? '-',
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _TagihanRow('Harga',       _formatRupiah(_tagihan['harga'])),
                              _TagihanRow('Jatuh Tempo', _tagihan['tanggal'] ?? '-'),
                              _TagihanRow('Meteran',     '${_tagihan['meteran'] ?? '-'} m³'),
                              _TagihanRow('Metode',      _tagihan['metode_pembayaran'] ?? '-'),
                              const SizedBox(height: 16),

                              // TOMBOL BAYAR — hanya muncul kalau Belum Lunas
                              if (!_menungguKonfirmasi &&
                                  !_showPilihanBayar &&
                                  _tagihan['status'] == 'Belum Lunas')
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => setState(() => _showPilihanBayar = true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff0d7db8),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    icon: const Icon(Icons.payment, color: Colors.white),
                                    label: const Text(
                                      '💳 Bayar Sekarang',
                                      style: TextStyle(color: Colors.white, fontSize: 15),
                                    ),
                                  ),
                                ),

                              // PILIHAN TUNAI / NON TUNAI
                              if (_showPilihanBayar && !_menungguKonfirmasi) ...[
                                const Text(
                                  'Pilih metode pembayaran:',
                                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                _prosesLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _bayar('Tunai'),
                                            icon: const Text('💵'),
                                            label: const Text('Tunai'),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              side: const BorderSide(color: Color(0xff0d7db8)),
                                              foregroundColor: const Color(0xff0d7db8),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _bayar('Non Tunai'),
                                            icon: const Text('📱'),
                                            label: const Text('Non Tunai'),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              side: const BorderSide(color: Color(0xff0d7db8)),
                                              foregroundColor: const Color(0xff0d7db8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                              ],

                              // PESAN MENUNGGU
                              if (_menungguKonfirmasi)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xfffff3cd),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.orange.shade300),
                                  ),
                                  child: Row(
                                    children: [
                                      const Text('⏳', style: TextStyle(fontSize: 18)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _tagihan['status'] == 'Menunggu Pembayaran'
                                            ? 'Menunggu pembayaran Non Tunai...'
                                            : 'Silakan tunggu konfirmasi admin...',
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                    ),
                    const SizedBox(height: 16),

                    // RIWAYAT
                    _Card(
                      child: _riwayat.isEmpty
                        ? const _InfoSection(
                            icon: Icons.description_outlined,
                            iconColor: Colors.purple,
                            title: 'Belum Ada Riwayat',
                            subtitle: 'Transaksi pembayaran kamu akan tampil di sini.',
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Riwayat Pembayaran',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff0d7db8),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ..._riwayat.map((r) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xfff0f9ff),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      r['tanggal'] ?? '-',
                                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                    Text(
                                      _formatRupiah(r['harga']),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Lunas',
                                        style: TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── WEBVIEW MIDTRANS ──────────────────────────────────────────
class MidtransWebViewPage extends StatefulWidget {
  final String url;
  final VoidCallback onSelesai;

  const MidtransWebViewPage({
    super.key,
    required this.url,
    required this.onSelesai,
  });

  @override
  State<MidtransWebViewPage> createState() => _MidtransWebViewPageState();
}

class _MidtransWebViewPageState extends State<MidtransWebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (req) {
          if (req.url.contains('finish') ||
              req.url.contains('success') ||
              req.url.contains('unfinish')) {
            widget.onSelesai();
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: const Color(0xff0d7db8),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(IconData(0xe16a, fontFamily: 'MaterialIcons')), // Menggantikan Icons.close agar aman dari masalah font
          onPressed: widget.onSelesai,
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

// ── WIDGET HELPERS ────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: child,
    );
  }
}

class _TagihanRow extends StatelessWidget {
  final String label;
  final String value;
  const _TagihanRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
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
                style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}