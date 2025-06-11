import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/fidelity_card.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fidelity_cards.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE fidelity_cards(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        barcode TEXT,
        barcodeType TEXT,
        colorValue INTEGER,
        openCount INTEGER,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE fidelity_cards ADD COLUMN colorValue INTEGER;');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE fidelity_cards ADD COLUMN openCount INTEGER DEFAULT 0;');
    }
    // Add future migrations here
  }

  Future<void> insertCard(FidelityCard card) async {
    final db = await database;
    await db.insert(
      'fidelity_cards',
      {
        'id': card.id,
        'name': card.name,
        'description': card.description,
        'barcode': card.barcode,
        'barcodeType': card.barcodeType,
        'colorValue': card.colorValue,
        'openCount': card.openCount,
        'created_at': card.createdAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FidelityCard>> getAllCards() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('fidelity_cards');

    return List.generate(maps.length, (i) {
      return FidelityCard(
        id: maps[i]['id'],
        name: maps[i]['name'],
        description: maps[i]['description'],
        barcode: maps[i]['barcode'],
        barcodeType: maps[i]['barcodeType'],
        colorValue: maps[i]['colorValue'],
        openCount: maps[i]['openCount'] ?? 0,
        createdAt: DateTime.parse(maps[i]['created_at']),
      );
    });
  }

  Future<void> updateCard(FidelityCard card) async {
    final db = await database;
    await db.update(
      'fidelity_cards',
      {
        'name': card.name,
        'description': card.description,
        'barcode': card.barcode,
        'barcodeType': card.barcodeType,
        'colorValue': card.colorValue,
        'openCount': card.openCount,
      },
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<void> deleteCard(String id) async {
    final db = await database;
    await db.delete(
      'fidelity_cards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
} 