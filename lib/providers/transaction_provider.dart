import 'package:flutter/material.dart';
import 'package:smart_budget/models/transaction_model.dart';
import '../services/database_service.dart';

class TransactionProvider extends ChangeNotifier {

 
  List<TransactionModel> _transactions = [];

  
  String _selectedCategory = 'Tümü';

  DateTime? _startDate;
  DateTime? _endDate;

  // Filtrelenmiş işlemleri dışarıya dönen getter
  List<TransactionModel> get transactions => _filteredTransactions();

  String get selectedCategory => _selectedCategory;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  // Provider ilk oluşturulduğunda veritabanından verileri çek
  TransactionProvider() {
    loadTransactions();
  }

  // ----------------------- VERİTABANI -----------------------

  // Veritabanından işlemleri yükler
  Future<void> loadTransactions() async {
    _transactions = await DatabaseService.instance.getAllTransactions();
    notifyListeners(); 
  }

  // ----------------------- FİLTRELEME -----------------------

  // Kategori + tarih filtreleme fonksiyonu
  List<TransactionModel> _filteredTransactions() {
    return _transactions.where((transaction) {
      
      // Kategori filtresi
      if (_selectedCategory != 'Tümü' &&
          transaction.category != _selectedCategory) {
        return false;
      }
      
      if (_startDate != null && transaction.date.isBefore(_startDate!)) {
        return false;
      }

      // Bitiş tarih filtresi (günü tam almak için +1 gün)
      if (_endDate != null && transaction.date.isAfter(_endDate!.add(const Duration(days: 1)))) {
        return false;
      }

      return true; 
    }).toList();
  }

  // ----------------------- CRUD İŞLEMLERİ -----------------------

 
  Future<void> addTransaction(TransactionModel transaction) async {
    await DatabaseService.instance.addTransaction(transaction);
    await loadTransactions(); // listeyi yenile
  }

  Future<void> deleteTransaction(int id) async {
    await DatabaseService.instance.deleteTransaction(id);
    await loadTransactions();
  }

  // ----------------------- FİLTRE AYARLARI -----------------------

  // Kategori filtresini değiştir
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Tarih aralığını değiştir
  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  // Tüm filtreleri temizle
  void clearFilters() {
    _selectedCategory = 'Tümü';
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  // ----------------------- ANALİZ ve TOPLAMLAR -----------------------

  // Toplam gelir
  double get totalIncome {
    return _transactions
        .where((t) => t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Toplam gider
  double get totalExpense {
    return _transactions
        .where((t) => !t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Bakiye (gelir - gider)
  double get balance => totalIncome - totalExpense;

  // Kategori bazlı gider toplamı grafiği
  Map<String, double> get expenseByCategory {
    Map<String, double> categoryMap = {};
    
    // Sadece giderleri topluyoruz
    for (var transaction in _transactions.where((t) => !t.isIncome)) {
      categoryMap[transaction.category] =
          (categoryMap[transaction.category] ?? 0) + transaction.amount;
    }

    return categoryMap;
  }


  List<String> getSmartSuggestions() {
    List<String> suggestions = [];
    final categoryExpenses = expenseByCategory;

    if (categoryExpenses['Kahve & Cafe'] != null &&
        categoryExpenses['Kahve & Cafe']! > 300) {
      suggestions.add(
          '☕ Bu ay kahveye ${categoryExpenses['Kahve & Cafe']!.toStringAsFixed(0)}₺ harcadın. Evde kahve yapmayı dene!');
    }

    if (categoryExpenses['Yemek'] != null &&
        categoryExpenses['Yemek']! > 1000) {
      suggestions.add(
          '🍽️ Yemek harcamaların yüksek (${categoryExpenses['Yemek']!.toStringAsFixed(0)}₺). Evde yemek pişirerek tasarruf edebilirsin!');
    }

    if (totalExpense > totalIncome * 0.8) {
      suggestions.add(
          '⚠️ Harcamalarının gelirinin %${((totalExpense / totalIncome) * 100).toStringAsFixed(0)}\'ini oluşturuyor. Daha dikkatli ol!');
    }

    if (balance > 0 && totalExpense < totalIncome * 0.5) {
      suggestions.add(
          '🎉 Harika! Gelirinin yarısından azını harcıyorsun. Böyle devam et!');
    }

    if (suggestions.isEmpty) {
      suggestions.add('👍 Finansal durumun iyi görünüyor. Tasarruf yapmaya devam et!');
    }

    return suggestions;
  }
}
