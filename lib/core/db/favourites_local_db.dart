import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/favourites/models/favourite_event_model.dart';

class FavouritesLocalDb {
  FavouritesLocalDb._();
  static final FavouritesLocalDb instance = FavouritesLocalDb._();

  static const _dbName = 'eventmate.db';
  static const _dbVersion = 1;
  static const _tableName = 'favourites';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async => _createTable(db),
      onOpen: (db) async => _createTable(db),
      onUpgrade: (db, oldVersion, newVersion) async => _createTable(db),
    );
  }

  Future<List<FavouriteEventModel>> getFavourites() async {
    final db = await database;
    final result = await db.query(_tableName);
    return result.map(_fromDbMap).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> upsertFavourite(FavouriteEventModel event) async {
    final db = await database;
    await db.insert(
      _tableName,
      _toDbMap(event),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteFavourite(String id) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete(_tableName);
  }

  Future<void> replaceAll(List<FavouriteEventModel> events) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(_tableName);
      final batch = txn.batch();
      for (final event in events) {
        batch.insert(
          _tableName,
          _toDbMap(event),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Map<String, dynamic> _toDbMap(FavouriteEventModel event) {
    return {
      'id': event.id,
      'title': event.title,
      'description': event.description,
      'date': event.date.toIso8601String(),
      'location': event.location,
      'isTicketmasterEvent': event.isTicketmasterEvent ? 1 : 0,
      'ticketmasterUrl': event.ticketmasterUrl,
      'imageUrl': event.imageUrl,
      'organizerId': event.organizerId,
    };
  }

  FavouriteEventModel _fromDbMap(Map<String, dynamic> map) {
    return FavouriteEventModel.fromJson({
      'id': map['id'],
      'title': map['title'],
      'description': map['description'],
      'date': map['date'],
      'location': map['location'],
      'isTicketmasterEvent': (map['isTicketmasterEvent'] ?? 0) == 1,
      'ticketmasterUrl': map['ticketmasterUrl'],
      'imageUrl': map['imageUrl'],
      'organizerId': map['organizerId'],
    });
  }

  Future<void> _createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        location TEXT NOT NULL,
        isTicketmasterEvent INTEGER NOT NULL DEFAULT 0,
        ticketmasterUrl TEXT,
        imageUrl TEXT,
        organizerId TEXT
      )
    ''');
  }
}
