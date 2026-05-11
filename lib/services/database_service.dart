import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:smart_budget/models/transaction_model.dart';

class DatabaseService {
  // Singleton yapısı: uygulamada tek bir database instance çalışsın diye
  static final DatabaseService instance = DatabaseService._init();

  // Veritabanı nesnesi (başta null)
  static Database? _database;

  // Özel constructor
  DatabaseService._init();

  // Eğer veritabanı zaten açıksa onu döner, değilse yeni açar
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('transactions.db');
    return _database!;
  }

  // Veritabanını başlatma fonksiyonu
  Future<Database> _initDB(String filePath) async {
    // Cihazın veritabanı klasörünün yolunu alıyoruz
    final dbPath = await getDatabasesPath();
    // Veritabanı dosyasının tam yolunu oluşturuyoruz
    final path = join(dbPath, filePath);

    // Veritabanını açıyoruz (yoksa oluşturuyor)
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,  // İlk oluşturulursa tabloyu kur
    );
  }

  // Veritabanı ilk oluşturulurken çalışacak fonksiyon (tabloyu oluşturur)
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,   -- birincil anahtar
        title TEXT NOT NULL,                    -- işlem adı
        amount REAL NOT NULL,                   -- miktar
        category TEXT NOT NULL,                 -- kategori
        isIncome INTEGER NOT NULL,              -- gelir/gider (1/0)
        date TEXT NOT NULL,                     -- tarih
        note TEXT                               -- isteğe bağlı not
      )
    ''');
  }

  // İşlem ekleme
  Future<int> addTransaction(TransactionModel transaction) async {
    final db = await database;
  
    return await db.insert('transactions', transaction.toMap());
  }

  // Tüm işlemleri çekme
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;

    // Tablodaki tüm satırları map olarak çek
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',   // Son eklenen en üstte olsun
    );

    // Map → Model dönüşümü
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  // İşlem silme
  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',        // id'si verilen kaydı sil
      whereArgs: [id],
    );
  }

  // İşlem güncelleme
  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(), 
      where: 'id = ?',       // id'ye göre güncelle
      whereArgs: [transaction.id],
    );
  }

  // Veritabanını kapatma (isteğe bağlı)
  Future close() async {
    final db = await database;
    db.close();
  }
}
