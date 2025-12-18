import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/profile/models/user_profile_model.dart';

class UserLocalDb {
  UserLocalDb._();
  static final UserLocalDb instance = UserLocalDb._();

  static const _dbName = 'eventmate.db';
  static const _dbVersion = 1;
  static const _userTable = 'users';

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
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_userTable(
            id TEXT PRIMARY KEY,
            fullName TEXT NOT NULL,
            email TEXT NOT NULL,
            phoneNo TEXT NOT NULL,
            profileImage TEXT,
            createdAt TEXT
          )
        ''');
      },
    );
  }

  Future<void> upsertUser(UserProfileModel user) async {
    if (user.id == null) return;
    final db = await database;
    await db.insert(
      _userTable,
      user.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserProfileModel?> getUser() async {
    final db = await database;
    final result = await db.query(_userTable, limit: 1);
    if (result.isEmpty) return null;
    final row = result.first;
    return UserProfileModel.fromMap(row, id: row['id']?.toString());
  }

  Future<void> deleteUser() async {
    final db = await database;
    await db.delete(_userTable);
  }
}
