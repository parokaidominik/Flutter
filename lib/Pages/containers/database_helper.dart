import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  final String databaseName = 'your_database.db';

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, databaseName);
    return await openDatabase(path, version: 1, onCreate: (db, version) {
      // Create database tables here if needed
      db.execute('CREATE TABLE your_table (ID INTEGER PRIMARY KEY, Name TEXT)');
    });
  }

  Future<void> insertRecord(Map<String, dynamic> record) async {
    final db = await database;
    await db.insert('your_table', record);
  }

  Future<List<Map<String, dynamic>>> queryAllRecords() async {
    final db = await database;
    return await db.query('your_table');
  }

  // Other database operations...
}
