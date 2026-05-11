import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:smart_budget/models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // Form doğrulama anahtarı
  final _formKey = GlobalKey<FormState>();

  // Text alanları için controller'lar
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  // Varsayılan olarak gider seçili
  bool _isIncome = false;

  // Kullanıcının seçtiği kategori
  String? _selectedCategory;

  // Varsayılan tarih bugün
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    // Bellek sızıntısını önlemek için controller'ları kapat
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Gelir/gider durumuna göre kategori listesini döndürür
  List<String> get _categories {
    return _isIncome ? Categories.incomeCategories : Categories.expenseCategories;
  }

  // Tarih seçme işlemi
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    // Kullanıcı bir tarih seçtiyse güncelle
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // İşlemi kaydetme fonksiyonu
  void _saveTransaction() async {
    // Form geçerli mi ve kategori seçili mi?
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      
      // Model nesnesi oluşturuluyor
      final transaction = TransactionModel(
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        category: _selectedCategory!,
        isIncome: _isIncome,
        date: _selectedDate,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );

      // Provider üzerinden veritabanına kaydediliyor
      await Provider.of<TransactionProvider>(context, listen: false)
          .addTransaction(transaction);

      // Eğer ekran hala aktifse kullanıcıya mesaj göster ve geri dön
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İşlem başarıyla eklendi!')),
        );
        Navigator.pop(context);
      }

    } 
    // Kategori seçilmemişse uyarı ver
    else if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen kategori seçin')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İşlem Ekle')),
      //form Hepsini tek seferde kontrol etmek
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // Gelir / Gider seçimi
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Gider'), icon: Icon(Icons.remove_circle)),
                ButtonSegment(value: true, label: Text('Gelir'), icon: Icon(Icons.add_circle)),
              ],
              selected: {_isIncome},
              onSelectionChanged: (Set<bool> selection)
               {
                //state Seçimleri saklar
                setState(() {
                  _isIncome = selection.first;
                  _selectedCategory = null; // Kategoriyi sıfırla
                });
              },
            ),
            const SizedBox(height: 20),

            // Başlık alanı
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Başlık',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Başlık girin' : null,
            ),
            const SizedBox(height: 16),

            // Tutar alanı
            TextFormField(
              controller: _amountController,
              //controller kullanıcının yazdığı veriyi alır
              decoration: const InputDecoration(
                labelText: 'Tutar (₺)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,// sayı klavyesi
              validator: (value) 
              //validator Hatalı girişleri engeller
              {
                if (value?.isEmpty ?? true) return 'Tutar girin';
                if (double.tryParse(value!) == null) return 'Geçerli bir tutar girin';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Kategori seçimi
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),
            const SizedBox(height: 16),

            // Tarih seçimi
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              leading: const Icon(Icons.calendar_today),
              title: const Text('Tarih'),
              subtitle: Text(DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDate)),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),

            // Not (opsiyonel)
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Not (Opsiyonel)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Kaydet butonu
            FilledButton.icon(
              onPressed: _saveTransaction,
              icon: const Icon(Icons.save),
              label: const Text('Kaydet'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

