import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:app_perfumes/models/user.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

class UserRepository {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _inicializarDB();
    return _db!;
  }

  Future<Database> _inicializarDB() async {
    final pathDB = join(await getDatabasesPath(), 'users_database.db');

    return await openDatabase(
      pathDB,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE usuarios (
            id TEXT PRIMARY KEY,
            name TEXT,
            email TEXT,
            password TEXT,
            age INTEGER,
            profile_image TEXT -- <--- NUEVA COLUMNA EN LA TABLA
          )
        ''');

        final List<User> registradosSemilla = [
          User(
            id: '1',
            name: 'juan',
            email: 'juan@gmail.com',
            password: '1234',
            age: 30,
          ),
          User(
            id: '2',
            name: 'admin',
            email: 'admin@gmail.com',
            password: 'root',
            age: 25,
          ),
          User(
            id: '3',
            name: 'marco',
            email: 'marco@utn.com',
            password: 'utn',
            age: 22,
          ),
          User(
            id: '4',
            name: 'gabi',
            email: 'gabi@utn.com',
            password: 'pds',
            age: 23,
          ),
          User(
            id: '5',
            name: 'lucas',
            email: 'lucas@gmail.com',
            password: 'qwert',
            age: 28,
          ),
          User(
            id: '6',
            name: 'maria',
            email: 'maria@gmail.com',
            password: '7890',
            age: 35,
          ),
          User(
            id: '7',
            name: 'sofia',
            email: 'sofi@hotmail.com',
            password: 'abc',
            age: 19,
          ),
          User(
            id: '8',
            name: 'javi',
            email: 'javi@empresa.com',
            password: 'ai',
            age: 40,
          ),
          User(
            id: '9',
            name: 'leo',
            email: 'leo@futbol.com',
            password: 'gol',
            age: 37,
          ),
          User(
            id: '10',
            name: 'prodigyo',
            email: 'dev@flutter.com',
            password: 'dart',
            age: 21,
          ),
        ];

        for (var usuario in registradosSemilla) {
          await db.insert('usuarios', usuario.toMap());
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE usuarios ADD COLUMN profile_image TEXT',
          );
        }
      },
    );
  }

  Future<User?> obtenerUsuarioPorNombre(String name) async {
    final db = await database;
    final resultado = await db.query(
      'usuarios',
      where: 'LOWER(name) = ?',
      whereArgs: [name.toLowerCase()],
    );

    if (resultado.isEmpty) return null;
    return User.fromMap(resultado.first);
  }

  Future<User?> autenticarUsuario(String name, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> resultado = await db.query(
      'usuarios',
      where: 'LOWER(name) = ? AND password = ?',
      whereArgs: [name.toLowerCase(), password],
    );

    if (resultado.isNotEmpty) {
      return User.fromMap(resultado.first);
    }
    return null;
  }

  Future<void> registrarUsuario(User usuario) async {
    final db = await database;
    await db.insert(
      'usuarios',
      usuario.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  Future<void> actualizarUsuario(User usuario) async {
    final db = await database;
    await db.update(
      'usuarios',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  Future<void> eliminarUsuario(String id) async {
    final db = await database;
    await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
  }
}
