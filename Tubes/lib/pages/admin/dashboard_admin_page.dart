import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pamdes/services/api_service.dart';
import '../../layout/admin_scaffold.dart';

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  int jumlahPelanggan = 0;
  int tahunGrafik = DateTime.now().year;
  List<double> pemasukanBulanan = List.filled(12, 0.0); // Default 12 bulan bernilai 0.0
  bool loading = true;

  // Nama bulan pendek untuk label grafik
  final List<String> namaBulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final response = await ApiService.getDashboardAdminData();

      setState(() {
        jumlahPelanggan = response['jumlahUser'] ?? 0;
        tahunGrafik = response['tahun'] ?? DateTime.now().year;
        
        if (response['pemasukanBulanan'] != null) {
          final List<dynamic> rawList = response['pemasukanBulanan'];
          pemasukanBulanan = rawList.map<double>((val) {
            if (val == null) return 0.0;
            return double.tryParse(val.toString()) ?? 0.0;
          }).toList();
        } else {
          pemasukanBulanan = List.filled(12, 0.0);
        }
        
        loading = false;
      });
    } catch (e) {
      debugPrint("Error loadData Dashboard: $e");
      setState(() {
        loading = false;
      });
    }
  }

  Widget cardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentIndex: 0,
      child: RefreshIndicator(
        onRefresh: loadData,
        color: const Color(0xff0d7db8),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              // CARD WELCOME
              cardContainer(
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat datang di Dashboard Admin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text('Di sini Anda bisa memantau data PAMDES.'),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // CARD JUMLAH PELANGGAN
              cardContainer(
                child: Column(
                  children: [
                    const Text(
                      'Jumlah Pelanggan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff4a4a4a),
                      ),
                    ),
                    const SizedBox(height: 16),
                    loading
                        ? const CircularProgressIndicator()
                        : Text(
                            '$jumlahPelanggan Orang',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff0d7db8),
                            ),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // CARD GRAFIK PEMASUKAN MODERN
              cardContainer(
                child: SizedBox(
                  height: 360, 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pemasukan Tahun $tahunGrafik',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Expanded(
                        child: loading
                            ? const Center(child: CircularProgressIndicator())
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: _buildBarChart(),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    bool isDataEmpty = pemasukanBulanan.every((element) => element == 0);

    if (isDataEmpty) {
      return Center(
        child: Text(
          'Grafik pemasukan belum tersedia',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    double nilaiTertinggi = pemasukanBulanan.reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceBetween,
        groupsSpace: 4, 
        maxY: nilaiTertinggi == 0 ? 1000.0 : nilaiTertinggi * 1.25, 
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => const Color(0xff111827), 
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String rupiahFormat = rod.toY.round().toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
                    (Match m) => '${m[1]}.'
                  );
              return BarTooltipItem(
                '${namaBulan[group.x]}\n',
                const TextStyle(color: Colors.white70, fontSize: 11),
                children: [
                  TextSpan(
                    text: 'Rp $rupiahFormat',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32, 
              getTitlesWidget: (double value, TitleMeta meta) {
                int index = value.toInt();
                if (index >= 0 && index < 12) {
                  return SideTitleWidget(
                    meta: meta, // Berhasil diperbaiki
                    space: 8.0, 
                    child: Text(
                      namaBulan[index],
                      style: TextStyle(
                        color: Colors.grey.shade500, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 10, 
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40, 
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value == meta.max) return const SizedBox.shrink();
                
                String text;
                if (value >= 1000000) {
                  text = '${(value / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
                } else if (value >= 1000) {
                  text = '${(value / 1000).toStringAsFixed(0)}k';
                } else {
                  text = value.toStringAsFixed(0);
                }

                return SideTitleWidget(
                  meta: meta, // Berhasil diperbaiki
                  space: 6, 
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade100, 
              strokeWidth: 1,
              dashArray: [6, 6],
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(12, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: pemasukanBulanan[index],
                width: 10, 
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff38bdf8), 
                    Color(0xff0d7db8), 
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: nilaiTertinggi == 0 ? 1000.0 : nilaiTertinggi * 1.2,
                  color: Colors.grey.withOpacity(0.04), 
                ),
              )
            ],
          );
        }),
      ),
      swapAnimationDuration: const Duration(milliseconds: 500),
      swapAnimationCurve: Curves.easeOutCubic,
    );
  }
}