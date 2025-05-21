import 'package:final_project/models/course.dart';
import 'package:final_project/models/course_material.dart';
import 'package:final_project/models/section.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'courses.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE courses (
            id TEXT PRIMARY KEY,
            name TEXT,
            description TEXT,
            authorId TEXT,
            themes TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE sections (
            id TEXT PRIMARY KEY,
            courseId TEXT,
            name TEXT,
            description TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE materials (
            id TEXT PRIMARY KEY,
            title TEXT,
            url TEXT,
            sizeBytes INTEGER,
            sectionId TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE enrollments (
            userId TEXT,
            courseId TEXT
          )
        ''');
      },
    );
  }

  // Insertar
  Future<void> insertCourse(Course course) async {
    final db = await database;
    await db.insert(
      'courses',
      course.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertSection(Section section) async {
    final db = await database;
    await db.insert(
      'sections',
      section.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertMaterial(CourseMaterial material) async {
    final db = await database;
    await db.insert(
      'materials',
      material.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Consultar
  Future<List<Course>> getCourses() async {
    final db = await database;
    final maps = await db.query('courses');
    return maps.map((map) => Course.fromMap(map)).toList();
  }

  Future<List<Section>> getSectionsByCourseId(String courseId) async {
    final db = await database;
    final maps = await db.query(
      'sections',
      where: 'courseId = ?',
      whereArgs: [courseId],
    );
    return maps.map((map) => Section.fromMap(map)).toList();
  }

  Future<List<CourseMaterial>> getMaterialsBySectionId(String sectionId) async {
    final db = await database;
    final maps = await db.query(
      'materials',
      where: 'sectionId = ?',
      whereArgs: [sectionId],
    );
    return maps.map((map) => CourseMaterial.fromMap(map)).toList();
  }

  // Eliminar (opcional)
  Future<void> deleteCourse(String id) async {
    final db = await database;
    await db.delete('courses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteSection(String id) async {
    final db = await database;
    await db.delete('sections', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteMaterial(String id) async {
    final db = await database;
    await db.delete('materials', where: 'id = ?', whereArgs: [id]);
  }

  // Limpiar todo (opcional)
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('materials');
    await db.delete('sections');
    await db.delete('courses');
  }

  Future<List<Map<String, dynamic>>> getEnrollmentsByUser(String userId) async {
    final db = await database;
    return await db.query(
      'enrollments',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }
}