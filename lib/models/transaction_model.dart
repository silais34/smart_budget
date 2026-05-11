class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final bool isIncome;
  final DateTime date;
  final String? note;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.isIncome,
    required this.date,
    this.note,
  });

  // Database'e kayıt için Map'e çevirme
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'isIncome': isIncome ? 1 : 0,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  // Database'den okuma için Map'ten obje oluşturma
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      isIncome: map['isIncome'] == 1,
      date: DateTime.parse(map['date']),
      note: map['note'],
    );
  }
}

// Sadece gelir için olan Kategoriler
class Categories {
  static const List<String> incomeCategories = [
    'Maaş',
    'Bonus',
    'Freelance',
    'Yatırım',
    'Diğer Gelir',
  ];
//Sadece gider için olan Kategoriler
  static const List<String> expenseCategories = [
    'Yemek',
    'Ulaşım',
    'Alışveriş',
    'Eğlence',
    'Faturalar',
    'Sağlık',
    'Eğitim',
    'Kahve & Cafe',
    'Diğer',
  ];
}