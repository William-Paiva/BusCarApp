import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> initDb() async {
    if (_db != null) return _db!;

    String path = join(await getDatabasesPath(), 'user_db.db');

    _db = await openDatabase(
      path,
      version: 2, // Alterado para forçar onUpgrade se necessário
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            username TEXT, 
            password TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE saved_buses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE saved_buses(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT
            )
          ''');
        }
      }
    );

    return _db!;
  }

  // ------------------ CRUD para ônibus ------------------
  static Future<int> saveBus(String name) async {
    final db = await initDb();
    return await db.insert('saved_buses', {'name': name});
  }

  static Future<List<Map<String, dynamic>>> getSavedBuses() async {
    final db = await initDb();
    return await db.query('saved_buses');
  }

  static Future<int> updateBus(int id, String newName) async {
    final db = await initDb();
    return await db.update(
      'saved_buses',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteBus(int id) async {
    final db = await initDb();
    return await db.delete('saved_buses', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------ Usuários (login/register) ------------------
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
