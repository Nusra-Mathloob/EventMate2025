import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/events/models/event_model.dart';

class EventLocalDb {
  EventLocalDb._();
  static final EventLocalDb instance = EventLocalDb._();

  static const _dbName = 'eventmate.db';
  static const _dbVersion = 2;
  static const _eventTable = 'events';

  Database? _db;
  final _eventStreamController = StreamController<List<EventModel>>.broadcast();

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

  Future<void> replaceUserEvents(String userId, List<EventModel> events) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(_eventTable, where: 'userId = ?', whereArgs: [userId]);
      final batch = txn.batch();
      for (final event in events) {
        batch.insert(
          _eventTable,
          _toDbMap(event),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
    await _emitFromDb(userId: userId);
  }

  Future<void> upsertEvents(List<EventModel> events) async {
    if (events.isEmpty) return;
    final db = await database;
    final batch = db.batch();
    for (final event in events) {
      batch.insert(
        _eventTable,
        _toDbMap(event),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
    await _emitFromDb(userId: events.first.userId);
  }

  Future<void> deleteEvent(String id) async {
    final db = await database;
    await db.delete(_eventTable, where: 'id = ?', whereArgs: [id]);
    await _emitFromDb(); // emits current user's view if listener exists
  }

  Future<List<EventModel>> getEvents({String? userId}) async {
    final db = await database;
    final result = await db.query(
      _eventTable,
      where: userId != null ? 'userId = ?' : null,
      whereArgs: userId != null ? [userId] : null,
    );
    return result.map((row) => EventModel.fromDbMap(row)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Stream<List<EventModel>> watchEvents({String? userId}) {
    // Kick off an initial emit for current subscriber.
    _emitFromDb(userId: userId);
    if (userId != null) {
      // Emit filtered view for the subscriber by mapping the base stream.
      return _eventStreamController.stream.map((events) =>
          events.where((e) => e.userId == userId).toList()
            ..sort((a, b) => a.date.compareTo(b.date)));
    }
    return _eventStreamController.stream;
  }

  Future<void> _emitFromDb({String? userId}) async {
    final events = await getEvents(userId: userId);
    if (!_eventStreamController.isClosed) {
      _eventStreamController.add(events);
    }
  }

  Map<String, dynamic> _toDbMap(EventModel event) => event.toDbMap();

  Future<void> _createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_eventTable(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        location TEXT NOT NULL,
        userId TEXT NOT NULL,
        userName TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');
  }

  Future<void> ensureTableExists() async {
    final db = await database;
    await _createTable(db);
  }
}
