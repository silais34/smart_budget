import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_list.dart';
import 'package:smart_budget/widgets/category_chart.dart';
import 'add_transaction_screen.dart';
import 'analytics_screen.dart';

// Uygulamanın ana ekranı (alt navigasyon + appbar + FAB yönetimi)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Alt sekme seçimini tutar (0 = Ana Sayfa, 1 = Analiz)
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Tema provider'ını alıyoruz (tema değiştirmek için)
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Alt sekmelerin gösterdiği ekranlar
    final screens = [
      const HomeTab(),
      const AnalyticsScreen(),
    ];

    return Scaffold(
      // Üst bar (başlık + tema butonu)
      appBar: AppBar(
        title: const Text('SmartBudget', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // Tema değiştirici (ikon tema durumuna göre değişir)
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),

      body: screens[_selectedIndex],

      // İşlem ekleme ekranına gider
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('İşlem Ekle'),
            )
          : null,

      // Alt navigasyon çubuğu (sekme değiştirir)
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          NavigationDestination(icon: Icon(Icons.analytics), label: 'Analiz'),
        ],
      ),
    );
  }
}

// Ana sayfa içeriği (bakiye kartı, kategori grafiği, işlem listesi)
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      // Pull-to-refresh: verileri veritabanından yeniden yükler
      onRefresh: () => Provider.of<TransactionProvider>(context, listen: false).loadTransactions(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const BalanceCard(),

          const SizedBox(height: 20),

          CategoryChart(),

          const SizedBox(height: 20),

          const TransactionList(),
        ],
      ),
    );
  }
}
