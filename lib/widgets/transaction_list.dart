import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';


class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        // Filtrelenmiş işlemleri al
        final transactions = provider.transactions;

        // Eğer işlem yoksa kullanıcıya bir kart göster
        if (transactions.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz işlem yok',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        // İşlemler varsa listele
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kart başlığı ve işlem sayısı
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Son İşlemler',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),//kart başlığı
                    ),
                    Text(
                      '${transactions.length} işlem',//işlem sayısı
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Liste halinde işlemleri göster
              ListView.separated(
                shrinkWrap: true, // kendi boyutuna göre sığdır
                physics: const NeverScrollableScrollPhysics(), // dış ListView ile kaydırmayı engelle
                itemCount: transactions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final transaction = transactions[index];

                  return ListTile(
                    // Gelir veya gider olduğunu gösteren avatar
                    leading: CircleAvatar(
                      backgroundColor: transaction.isIncome
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      child: Icon(
                        transaction.isIncome ? Icons.add : Icons.remove,
                        color: transaction.isIncome ? Colors.green : Colors.red,
                      ),
                    ),

                    // İşlem başlığı
                    title: Text(
                      transaction.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),

                    // İşlem kategorisi ve tarihi
                    subtitle: Text(
                      '${transaction.category} • ${DateFormat('dd MMM yyyy', 'tr').format(transaction.date)}',
                    ),

                    // Tutarı göster, gelirse yeşil, giderse kırmızı
                    trailing: Text(
                      '${transaction.isIncome ? '+' : '-'}₺${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: transaction.isIncome ? Colors.green : Colors.red,
                      ),
                    ),

                    // Uzun basıldığında silme dialogu aç
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('İşlemi Sil'),
                          content: const Text('Bu işlemi silmek istediğinize emin misiniz?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('İptal'),
                            ),
                            FilledButton(
                              onPressed: () {
                                provider.deleteTransaction(transaction.id!);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('İşlem silindi')),
                                );
                              },
                              child: const Text('Sil'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
