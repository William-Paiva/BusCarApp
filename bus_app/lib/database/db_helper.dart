import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/bus_model.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> initDb() async {
    if (_db != null) return _db!;
    
    String path = join(await getDatabasesPath(), 'user_db.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabela de usuários
        await db.execute(
          'CREATE TABLE users('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'username TEXT, '
          'password TEXT)',
        );

        // Tabela de ônibus favoritos
        await db.execute(
          'CREATE TABLE buses('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'linha TEXT, '
          'sentido TEXT, '
          'apelido TEXT)',
        );
      },
    );
    return _db!;
  }

  // ===== Usuários =====
  static Future<int> registerUser(String username, String password) async {
    final db = await initDb();
    return await db.insert('users', {
      'username': username,
      'password': password,
    });
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

  // ===== Ônibus Favoritos =====
  static Future<int> insertBus(BusModel bus) async {
    final db = await initDb();
    return await db.insert('buses', bus.toMap());
  }

  static Future<List<BusModel>> getAllBuses() async {
    final db = await initDb();
    final result = await db.query('buses');
    return result.map((map) => BusModel.fromMap(map)).toList();
  }

  static Future<int> updateBus(BusModel bus) async {
    final db = await initDb();
    return await db.update(
      'buses',
      bus.toMap(),
      where: 'id = ?',
      whereArgs: [bus.id],
    );
  }

  static Future<int> deleteBus(int id) async {
    final db = await initDb();
    return await db.delete(
      'buses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
