import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/fidelity_card.dart';
import '../models/card_location.dart';

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
      version: 4,
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
        isFavorite INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE card_locations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_id TEXT NOT NULL,
        address TEXT NOT NULL,
        lat REAL NOT NULL,
        lng REAL NOT NULL,
        radius REAL NOT NULL DEFAULT 200,
        FOREIGN KEY (card_id) REFERENCES fidelity_cards(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final columns = await db.rawQuery('PRAGMA table_info(fidelity_cards)');
      final hasIsFavorite = columns.any((col) => col['name'] == 'isFavorite');
      if (!hasIsFavorite) {
        await db.execute('ALTER TABLE fidelity_cards ADD COLUMN isFavorite INTEGER NOT NULL DEFAULT 0;');
      }
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS card_locations(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          card_id TEXT NOT NULL,
          address TEXT NOT NULL,
          lat REAL NOT NULL,
          lng REAL NOT NULL,
          radius REAL NOT NULL DEFAULT 200,
          FOREIGN KEY (card_id) REFERENCES fidelity_cards(id) ON DELETE CASCADE
        )
      ''');
    }
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
        'isFavorite': card.isFavorite ? 1 : 0,
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
        isFavorite: (maps[i]['isFavorite'] as int? ?? 0) == 1,
        createdAt: DateTime.parse(maps[i]['created_at']),
      );
    });
  }

  Future<FidelityCard?> getCardById(String id) async {
    final db = await database;
    final maps = await db.query('fidelity_cards', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    final m = maps.first;
    return FidelityCard(
      id: m['id'] as String,
      name: m['name'] as String,
      description: m['description'] as String? ?? '',
      barcode: m['barcode'] as String?,
      barcodeType: m['barcodeType'] as String?,
      colorValue: m['colorValue'] as int?,
      openCount: m['openCount'] as int? ?? 0,
      isFavorite: (m['isFavorite'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(m['created_at'] as String),
    );
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
        'isFavorite': card.isFavorite ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<void> deleteCard(String id) async {
    final db = await database;
    await db.delete('card_locations', where: 'card_id = ?', whereArgs: [id]);
    await db.delete('fidelity_cards', where: 'id = ?', whereArgs: [id]);
  }

  // --- Card Locations ---

  Future<void> insertLocation(CardLocation location) async {
    final db = await database;
    await db.insert('card_locations', location.toMap());
  }

  Future<List<CardLocation>> getLocationsForCard(String cardId) async {
    final db = await database;
    final maps = await db.query('card_locations', where: 'card_id = ?', whereArgs: [cardId]);
    return maps.map((m) => CardLocation.fromMap(m)).toList();
  }

  Future<List<CardLocation>> getAllCardLocations() async {
    final db = await database;
    final maps = await db.query('card_locations');
    return maps.map((m) => CardLocation.fromMap(m)).toList();
  }

  Future<void> deleteLocationsForCard(String cardId) async {
    final db = await database;
    await db.delete('card_locations', where: 'card_id = ?', whereArgs: [cardId]);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
