import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import 'package:smart_budget/models/transaction_model.dart';
import '../widgets/bar_chart_widget.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ------------------- AKILLI ÖNERİLER KARTI -------------------
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Akıllı Öneriler',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // provider içindeki öneriler burada listeleniyor
                    ...provider.getSmartSuggestions().map(
                      (suggestion) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text('• $suggestion'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ------------------- FİLTRELER KARTI -------------------
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtreler',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    // ----------- KATEGORİ FİLTRESİ -----------
                    DropdownButtonFormField<String>(
                      initialValue: provider.selectedCategory, // seçili kategori
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                      ),
                      // Dropdown içine kategoriler ekleniyor
                      items: [
                        'Tümü',
                        ...Categories.expenseCategories,
                        ...Categories.incomeCategories
                      ]
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ))
                          .toList(),
                      onChanged: (value) => provider.setCategory(value!), // kategori değiştiğinde güncellenir
                    ),
                    const SizedBox(height: 12),

                    // ----------- TARİH FİLTRESİ -----------
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              // Takvim açar → kullanıcı tarih aralığı seçer
                              final DateTimeRange? picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                                initialDateRange: provider.startDate != null &&
                                        provider.endDate != null
                                    ? DateTimeRange(
                                        start: provider.startDate!,
                                        end: provider.endDate!,
                                      )
                                    : null,
                              );

                              // Tarih seçildiyse provider'a kaydedilir
                              if (picked != null) {
                                provider.setDateRange(picked.start, picked.end);
                              }
                            },
                            icon: const Icon(Icons.date_range),

                            // Eğer tarih seçilmişse göster, seçilmemişse "Tarih Seç"
                            label: Text(
                              provider.startDate != null
                                  ? '${DateFormat('dd.MM.yy').format(provider.startDate!)} - ${DateFormat('dd.MM.yy').format(provider.endDate!)}'
                                  : 'Tarih Seç',
                            ),
                          ),
                        ),

                        // Filtre varsa temizleme butonu gösterilir
                        if (provider.startDate != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => provider.clearFilters(), // tüm filtreleri temizler
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ------------------- GRAFİK -------------------
            const BarChartWidget(), // işlem verilerinden oluşturulmuş grafik
          ],
        );
      },
    );
  }
}
