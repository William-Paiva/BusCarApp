import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> initDb() async {
    if (_db != null) return _db!;
    
    String path = join(await getDatabasesPath(), 'user_db.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT)',
        );
      },
    );
    return _db!;
  }

  static Future<int> registerUser(String username, String password) async {
    final db = await initDb();
    return await db.insert('users', {'username': username, 'password': password});
  }

  static Future<bool> loginUser(String username, String password) async {
    final db = await initDb();
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }
}
