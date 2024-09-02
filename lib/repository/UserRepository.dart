
import 'package:authentication/Doc.dart';
import 'package:authentication/User.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt.dart' as encrypt;


class UserRepository {

  // create key and pem
  static Future<Map<String, String>> generateAndConvertKeys() async {
    var helper = RsaKeyHelper();
    var keyPair = await helper.computeRSAKeyPair(helper.getSecureRandom());
    String publicKeyString = helper.encodePublicKeyToPemPKCS1(keyPair!.publicKey as RSAPublicKey);
    String privateKeyString = helper.encodePrivateKeyToPemPKCS1(keyPair!.privateKey as RSAPrivateKey);
    return {
      'publicKey': publicKeyString,
      'privateKey': privateKeyString,
    };
  }

  //pem to public key
  static RSAPublicKey pemToPublicKey(String pem) {
    var helper = RsaKeyHelper();
    return helper.parsePublicKeyFromPem(pem);
  }
  // pem to private key
  static RSAPrivateKey pemToPrivateKey(String pem) {
    var helper = RsaKeyHelper();
    return helper.parsePrivateKeyFromPem(pem);
  }


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
           publicKey TEXT,
           privateKey TEXT
           )
          ''',
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

        // add admin
        User admin = User(
          id: '52:83:29:3F',
          publicKey: "no need", privateKey: 'no need',
        );
        await db.insert(_users, admin.toMap());
      },
    );
    return database;
  }

  //create users and privatekey and publickey for each user

  static Future<String> insert(String id) async {
    final aeskKey = Key.fromSecureRandom(32);
    final iv = IV.fromSecureRandom(16);
    final keyBase64 = aeskKey.base64;
    final ivBase64 = iv.base64;
    print("AES Key : " + keyBase64);
    print("iv Key : " + ivBase64);
    Map<String,String> key=await generateAndConvertKeys();
    print("private Key : " + key['privateKey']!.substring(0, 100)+ key['privateKey']!.substring(key['privateKey']!.length-50) + "end");
    final encrypter = Encrypter(AES(aeskKey));
    final encrypted = encrypter.encrypt(key['privateKey']!, iv: iv);
    print("encrypted private Key : " + encrypted.base64.substring(0, 02) + encrypted.base64.substring(encrypted.base64.length-50)+ "end");
    var publicKey=pemToPublicKey(key['publicKey']!);
    User user=User(id: id, publicKey: key['publicKey']!, privateKey:encrypted.base64);
    final db = await _database();
    await db.insert(
      _users,
      {
        ...user.toMap(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return ivBase64+keyBase64;
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


  static Future<User?> getUserById(String id, String key) async {
    final extractedIv = IV.fromBase64(key.substring(0, 24));
    final extractedKey = Key.fromBase64(key.substring(24));
    print("iv : "+ extractedIv.base64);
    print("keyAES : " +extractedKey.base64);
    final encrypter = Encrypter(AES(extractedKey));

    final db = await _database();
    final List<Map<String, dynamic>> userMap = await db.query(
      _users,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (userMap.isNotEmpty) {
      var encryptedKey=userMap.first['privateKey'];
      print("encrypted Key : "+encryptedKey.substring(0,50)+encryptedKey.substring(encryptedKey.length-50)+"end" );
      final decrypted = encrypter.decrypt64(encryptedKey, iv: extractedIv);
      print ("dercrypted Key : " +decrypted.substring(0,50)+decrypted.substring(decrypted.length-50)+"end" );
      var privateKey=pemToPrivateKey(decrypted);
      final List<Map<String, dynamic>> docsMap = await db.query(
        _docs,
        where: 'userId = ?',
        whereArgs: [id],
      );
      List<Doc> docs = [];
      for (var map in docsMap) {
        docs.add(Doc(
            userId: map['userId'] ,
            title: decrypt(map['title'], privateKey),
            description: map['description']!=null ? decrypt(map['description'], privateKey) : null,
            files: map['files']!=null ? decrypt(map['files'], privateKey) : null,
        ));
      }
      return User(
        id: userMap.first['id'],
        profile:  (userMap.first['profile']!=null) ?decrypt(userMap.first['profile'],privateKey) : null,
        publicKey: userMap.first['publicKey'],
        docs: docs,
        privateKey: userMap.first['privateKey'],
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
        await db.insert('docs', {
          'userId': user.id,
          ...doc.toMap(user.publicKey),
        });
      }
    }
  }

}
