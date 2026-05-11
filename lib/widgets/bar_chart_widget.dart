import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';

class BarChartWidget extends StatelessWidget {
  const BarChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        // Kategori bazlı gider verilerini alıyoruz
        final categoryExpenses = provider.expenseByCategory;

        // Eğer veri yoksa kullanıcıya mesaj göster
        if (categoryExpenses.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: Center(
                child: Text('Gösterilecek veri yok'),
              ),
            ),
          );
        }

        // Veri varsa çubuk grafiği oluştur
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kart başlığı
                const Text(
                  'Kategori Bazlı Harcamalar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Grafik
                SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      // Y ekseni maksimum değeri belirle (en yüksek kategori * 1.2)
                      maxY: categoryExpenses.values.reduce((a, b) => a > b ? a : b) * 1.2,

                      // Dokunma ve tooltip ayarları
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final category = categoryExpenses.keys.elementAt(groupIndex);
                            return BarTooltipItem(
                              '$category\n₺${rod.toY.toStringAsFixed(2)}',
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),

                      // Eksen başlıkları ve görünüm
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              // Eğer index kategorilerden büyükse boş göster
                              if (value.toInt() >= categoryExpenses.length) {
                                return const Text('');
                              }
                              final category = categoryExpenses.keys.elementAt(value.toInt());
                              // Uzun kategori isimlerini kısalt
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  category.length > 8 
                                      ? '${category.substring(0, 8)}...' 
                                      : category,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '₺${value.toInt()}',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),

                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(show: false),

                      // Çubuk gruplarını oluştur
                      barGroups: _buildBarGroups(categoryExpenses, context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Her bir kategori için BarChartGroupData oluşturur
  List<BarChartGroupData> _buildBarGroups(
    Map<String, double> data,
    BuildContext context,
  ) {
    return data.entries.map((entry) {
      final index = data.keys.toList().indexOf(entry.key); // kategori index'i
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value, // çubuğun yüksekliği
            color: Theme.of(context).primaryColor,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)), // üst köşe yumuşatma
          ),
        ],
      );
    }).toList();
  }
}
