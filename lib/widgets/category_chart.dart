import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';

class CategoryChart extends StatelessWidget {
  const CategoryChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        // Kategori bazlı giderleri al
        final categoryExpenses = provider.expenseByCategory;

        // Eğer veri yoksa boş widget döndür
        if (categoryExpenses.isEmpty) {
          return const SizedBox.shrink();
        }

        // Kart içerisinde grafik göster
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                const Text(
                  'Gider Dağılımı',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Pasta grafik
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2, // Dilimler arası boşluk
                      centerSpaceRadius: 40, // Ortadaki boşluk
                      sections: _buildSections(categoryExpenses, context), // Dilimler
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Grafik altındaki renkli etiketler (kategori ve miktar)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categoryExpenses.entries.map((entry) {
                    final color = _getColorForIndex(
                      categoryExpenses.keys.toList().indexOf(entry.key),
                    );
                    return Chip(
                      avatar: CircleAvatar(backgroundColor: color),
                      label: Text('${entry.key}: ₺${entry.value.toStringAsFixed(0)}'),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // PieChart için dilimleri oluştur
  List<PieChartSectionData> _buildSections(
    Map<String, double> data,
    BuildContext context,
  ) {
    final total = data.values.fold(0.0, (sum, val) => sum + val); // toplam gider
    int index = 0;

    return data.entries.map((entry) {
      final color = _getColorForIndex(index++);
      final percentage = (entry.value / total * 100).toStringAsFixed(1);

      return PieChartSectionData(
        value: entry.value, // dilim değeri
        title: '$percentage%', // dilim yüzdesi
        color: color, // dilim rengi
        radius: 60, // dilim yarıçapı
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  // Her kategoriye renk atamak için yardımcı fonksiyon
  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
    ];
    return colors[index % colors.length]; // renkler döngüsel
  }
}
