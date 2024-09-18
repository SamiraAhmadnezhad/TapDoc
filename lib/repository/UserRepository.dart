
import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/Doc.dart';
import 'package:authentication/User.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';


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
          '''
        CREATE TABLE $_users(
          id TEXT PRIMARY KEY,
          profile TEXT,
          name TEXT
           )
          ''',
        );
        await db.execute(
          '''
        CREATE TABLE $_docs(
          userId TEXT,
          title TEXT,
          description TEXT,
          files TEXT,
          FOREIGN KEY(userId) REFERENCES $_users(id)
          )
        ''',
        );
      },
    );
    return database;
  }

  //create users and key for each user
  static Future<String> insertSpecial(String id) async {
    final aeskKey = Key.fromSecureRandom(32);
    final iv = IV.fromSecureRandom(16);
    // create Key String
    final keyBase64 = aeskKey.base64;
    final ivBase64 = iv.base64;
    // public key
    final extractedIv = IV.fromBase64("Ex4wZq6z78w/ouApgdOlMQ==");
    final extractedKey = Key.fromBase64("UKQU7oFLzAAEkUnoxIgSppkcKv1ObTvqhQ5HhT80/Ms=");
    final encrypter = Encrypter(AES(extractedKey));

    //add key
    User user=User(id: id, key: ivBase64+keyBase64, isWritable: true,);
    //add user to db
    final db = await _database();
    await db.insert(
      _users,
      {
        ...user.toMap(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return base64.encode(encrypter.encrypt(ivBase64+keyBase64, iv: extractedIv).bytes);
  }

  static Future<bool?> checkUserById(String id) async {
    final db = await _database();
    final List<Map<String, dynamic>> userMap = await db.query(
      _users,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (userMap.isNotEmpty){
      return true;
    }
    return false;
  }

  static Future<void> insertRegular(String id) async {
    final key = _generateAesKeyFromId(id);
    final keyBase64 = base64Url.encode(key.bytes);
    final iv = IV.fromUtf8(id.padRight(16, '0'));
    final ivBase64 = base64Url.encode(iv.bytes);
    User user = User(id: id, key: ivBase64 + keyBase64, isWritable: false);
    final db = await _database();
    await db.insert(
      _users,
      {
        ...user.toMap(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Key _generateAesKeyFromId(String id) {
    final idBytes = utf8.encode(id);
    final digest = sha256.convert(idBytes);
    final keyBytes = Uint8List.fromList(digest.bytes.sublist(0, 32));
    return Key(keyBytes);
  }


  static Future<User?> getUserById(String id, String inputKey,bool isWritable) async {
    final encrypter;
    final extractedIv;
    final extractedKey;
    final key;
    if (isWritable==false){
      extractedKey = _generateAesKeyFromId(id);
      extractedIv = IV.fromUtf8(id.padRight(16, '0'));
      encrypter = Encrypter(AES(extractedKey));
      key=base64Url.encode(extractedKey.bytes);
    }
    else {
      final extractedIv0 = IV.fromBase64("Ex4wZq6z78w/ouApgdOlMQ==");
      final extractedKey0 = Key.fromBase64("UKQU7oFLzAAEkUnoxIgSppkcKv1ObTvqhQ5HhT80/Ms=");
      final encrypter0 = Encrypter(AES(extractedKey0));
      key = encrypter0.decrypt(Encrypted.fromBase64(inputKey), iv: extractedIv0);
      extractedIv = IV.fromBase64(key.substring(0, 24));
      extractedKey = Key.fromBase64(key.substring(24));
      encrypter = Encrypter(AES(extractedKey));
    }
      //decrypt db
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
        List<Doc> docs = [];
        for (var map in docsMap) {
          docs.add(Doc(
            userId: map['userId'] ,
            title: encrypter.decrypt(Encrypted.fromBase64(map['title']), iv: extractedIv),
            description: map['description']!=null ? encrypter.decrypt(Encrypted.fromBase64(map['description']), iv: extractedIv) : null,
            files: map['files']!=null ? encrypter.decrypt(Encrypted.fromBase64(map['files']), iv: extractedIv): null,
          ));
        }
        return User(
          id: userMap.first['id'],
          profile:  (userMap.first['profile']!=null) ? encrypter.decrypt(Encrypted.fromBase64(userMap.first['profile']), iv: extractedIv): null,
          name:  (userMap.first['name']!=null) ? encrypter.decrypt(Encrypted.fromBase64(userMap.first['name']), iv: extractedIv): null,
          key: key,
          docs: docs,
          isWritable: isWritable,
        );
      }
      return null;
  }


  static Future<void> updateUser(User user) async {
    final db = await _database();
    await db.update(
      _users,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );

    await db.delete(
      _docs,
      where: 'userId = ?',
      whereArgs: [user.id],
    );

    if (user.docs != null) {
      for (var doc in user.docs!) {
        await db.insert(_docs, {
          'userId': user.id,
          ...doc.toMap(user.key,user.isWritable),
        });
      }
    }
  }

}
