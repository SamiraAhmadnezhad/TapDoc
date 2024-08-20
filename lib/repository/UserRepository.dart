import 'dart:typed_data';
import 'package:authentication/User.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class UserRepository {
  static const _dbName = 'users_database.db';
  static const _tableName = 'users';

  static Future<Database> _database() async {
    final database = openDatabase(
      join(await getDatabasesPath(), _dbName),
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE $_tableName(id TEXT PRIMARY KEY, profile TEXT)',
        );
        User admin=User(id: '52:83:29:3F',);
        await db.insert(_tableName,admin.toMap());
      },
    );
    return database;
  }

  static Future<void> insert(User user) async {
    final db = await _database();
    await db.insert(
      _tableName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<User>> getUsers() async {
    final db = await _database();
    final List<Map<String, Object?>> userMaps = await db.query(_tableName);
    return [
      for (final {
      'id': id as String,
      'profile': profile as String,
      } in userMaps)
        User(id: id, profile: profile),
    ];
  }

  static Future<User?> getUserByNFCID(String nfcID) async {

    final db = await _database();
    final List<Map<String, Object?>> userMaps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [nfcID],
    );
    if (userMaps.isNotEmpty) {
      final userMap = userMaps.first;

      String? profile;
      if (userMap['profile'] != null) {
        profile = userMap['profile'] as String;
      }

      return User(
        id: userMap['id'] as String,
        profile: profile,
      );
    } else {
      return null;
    }
  }


  static Future<void> updateUser(User user) async {
    final db = await _database();
    await db.update(
      _tableName,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

}
