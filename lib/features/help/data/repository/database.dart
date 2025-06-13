import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../domain/entities/history_entities.dart';

class HistoryDatabase {
  static final HistoryDatabase instance = HistoryDatabase._init();

  static Database? _database;

  HistoryDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('history.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      imageLink TEXT NOT NULL,
      description TEXT,
      name TEXT NOT NULL,
      scientificName TEXT NOT NULL,
      probability REAL NOT NULL,
      treatments TEXT, -- store as JSON string
      createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
  ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

extension HistoryDao on HistoryDatabase {
  Future<int> insertHistory(HistoryModel history) async {
    final db = await HistoryDatabase.instance.database;
    return await db.insert('history', history.toMap());
  }

  Future<List<HistoryModel>> getAllHistory() async {
    final db = await HistoryDatabase.instance.database;
    final result = await db.query(
      'history',
      orderBy: 'datetime(createdAt) DESC',
    );
    return result.map((json) => HistoryModel.fromMap(json)).toList();
  }

  Future<int> deleteHistory(int id) async {
    final db = await HistoryDatabase.instance.database;
    return await db.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearAllHistory() async {
    final db = await HistoryDatabase.instance.database;
    return await db.delete('history');
  }
}
