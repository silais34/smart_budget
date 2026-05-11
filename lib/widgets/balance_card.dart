import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    // TransactionProvider'dan gelir/gider/bakiye verilerini alıyoruz
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Card(
          elevation: 4, 
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Kart başlığı
                const Text(
                  'Toplam Bakiye',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),

                // Toplam bakiye değeri
                Text(
                  '₺${provider.balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Gelir ve gider bilgisi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Gelir sütunu
                    _buildStatColumn(
                      icon: Icons.arrow_downward,
                      label: 'Gelir',
                      amount: provider.totalIncome,
                      color: Colors.green[300]!,
                    ),

                    // Ortadaki dikey çizgi
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.white30,
                    ),

                    // Gider sütunu
                    _buildStatColumn(
                      icon: Icons.arrow_upward,
                      label: 'Gider',
                      amount: provider.totalExpense,
                      color: Colors.red[300]!,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Gelir/Gider sütunu için tekrar kullanılabilir widget
  Widget _buildStatColumn({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
  }) {
    return Column(
      children: [
        // Gelir/Gider simgesi
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),

        // Label (Gelir/Gider)
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),

        // Miktar
        Text(
          '₺${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
