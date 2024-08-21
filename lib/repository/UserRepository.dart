import 'dart:typed_data';
import 'package:authentication/Doc.dart';
import 'package:authentication/User.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class UserRepository {
  static const _dbName = 'users_database.db';
  static const _users = 'users';
  static const _docs = 'docs';
  static Future<Database> _database() async {
    final database = openDatabase(
      join(await getDatabasesPath(), _dbName),
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE $_users(id TEXT PRIMARY KEY, profile TEXT)',
        );
        await db.execute(
          '''
        CREATE TABLE $_docs(
          id TEXT PRIMARY KEY, 
          userId TEXT,
          title TEXT,
          description TEXT,
          files TEXT,
          FOREIGN KEY(userId) REFERENCES $_users(id)
        )
        ''',
        );

        User admin=User(id: '52:83:29:3F',);
        await db.insert(_users,admin.toMap());
      },
    );
    return database;
  }

  static Future<void> insert(User user) async {
    final db = await _database();
    await db.insert(
      _users,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<User>> getUsers() async {
    final db = await _database();
    final List<Map<String, Object?>> userMaps = await db.query(_users);
    return [
      for (final {
      'id': id as String,
      'profile': profile as String,
      } in userMaps)
        User(id: id, profile: profile),
    ];
  }

  static Future<User?> getUserById(String id) async {
    final db = await _database();
    final List<Map<String, dynamic>> userMap = await db.query(
      _users,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (userMap.isNotEmpty) {
      final List<Map<String, dynamic>> docsMap = await db.query(
        _docs,
        where: 'userId = ?',
        whereArgs: [id],
      );
      List<Doc> docs = docsMap.isNotEmpty
          ? docsMap.map((map) => Doc.fromMap(map)).toList()
          : [];
      return User(
        id: userMap.first['id'] as String,
        profile: userMap.first['profile'] as String?,
        docs: docs,
      );
    }
    return null;
  }




  static Future<void> updateUser(User user) async {
    final db = await _database();
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );

    // Delete old docs associated with the user
    await db.delete(
      'docs',
      where: 'userId = ?',
      whereArgs: [user.id],
    );

    // Insert new docs
    if (user.docs != null) {
      for (var doc in user.docs!) {
        await db.insert('docs', {
          'userId': user.id,
          ...doc.toMap(),
        });
      }
    }
  }


}
