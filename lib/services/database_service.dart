import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';
import '../models/task.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes(
            id TEXT PRIMARY KEY,
            title TEXT,
            content TEXT,
            createdAt TEXT,
            updatedAt TEXT,
            tags TEXT,
            aiSummary TEXT,
            isAIEnhanced INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE tasks(
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            isCompleted INTEGER,
            createdAt TEXT,
            dueDate TEXT,
            priority TEXT,
            subtasks TEXT,
            aiSuggestion TEXT
          )
        ''');
      },
    );
  }

  // Note operations
  Future<void> insertNote(Note note) async {
    final db = await database;
    final noteMap = note.toJson();
    noteMap['tags'] = jsonEncode(note.tags);
    noteMap['isAIEnhanced'] = note.isAIEnhanced ? 1 : 0;

    await db.insert(
      'notes',
      noteMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes');
    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      map['tags'] = jsonDecode(map['tags']);
      map['isAIEnhanced'] = map['isAIEnhanced'] == 1;
      return Note.fromJson(map);
    });
  }

  Future<void> updateNote(Note note) async {
    final db = await database;
    final noteMap = note.toJson();
    noteMap['tags'] = jsonEncode(note.tags);
    noteMap['isAIEnhanced'] = note.isAIEnhanced ? 1 : 0;

    await db.update('notes', noteMap, where: 'id = ?', whereArgs: [note.id]);
  }

  Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // Task operations
  Future<void> insertTask(Task task) async {
    final db = await database;
    final taskMap = task.toJson();
    taskMap['isCompleted'] = task.isCompleted ? 1 : 0;
    taskMap['subtasks'] = jsonEncode(task.subtasks);

    await db.insert(
      'tasks',
      taskMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      map['isCompleted'] = map['isCompleted'] == 1;
      map['subtasks'] = jsonDecode(map['subtasks'] ?? '[]');
      return Task.fromJson(map);
    });
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    final taskMap = task.toJson();
    taskMap['isCompleted'] = task.isCompleted ? 1 : 0;
    taskMap['subtasks'] = jsonEncode(task.subtasks);

    await db.update('tasks', taskMap, where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
