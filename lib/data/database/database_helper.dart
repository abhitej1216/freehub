import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart' as p;
import '../../core/constants/app_constants.dart';
import '../../core/constants/database_constants.dart';
import 'migrations/migration_v1.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath;
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      dbPath = AppConstants.dbName;
    } else {
      if (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      final databasesPath = await getDatabasesPath();
      dbPath = p.join(databasesPath, AppConstants.dbName);
    }

    return await openDatabase(
      dbPath,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    try {
      await db.execute('PRAGMA foreign_keys = ON');
    } catch (_) {}
    if (!kIsWeb) {
      try {
        await db.execute('PRAGMA journal_mode = WAL');
      } catch (_) {}
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await MigrationV1.up(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations go here
    // if (oldVersion < 2) await MigrationV2.up(db);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  // Generic CRUD helpers

  Future<int> insert(String table, Map<String, dynamic> data,
      {ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace}) async {
    final db = await database;
    return db.insert(table, data, conflictAlgorithm: conflictAlgorithm);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return db.rawQuery(sql, arguments);
  }

  Future<int> rawDelete(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return db.rawDelete(sql, arguments);
  }

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return db.transaction(action);
  }

  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final db = await database;
    final websiteCount = Sqflite.firstIntValue(
          await db.rawQuery(
              'SELECT COUNT(*) FROM ${DatabaseConstants.tableWebsites}'),
        ) ??
        0;
    final categoryCount = Sqflite.firstIntValue(
          await db.rawQuery(
              'SELECT COUNT(*) FROM ${DatabaseConstants.tableCategories}'),
        ) ??
        0;
    final historyCount = Sqflite.firstIntValue(
          await db.rawQuery(
              'SELECT COUNT(*) FROM ${DatabaseConstants.tableVisitHistory}'),
        ) ??
        0;
    final bookmarkCount = Sqflite.firstIntValue(
          await db.rawQuery(
              'SELECT COUNT(*) FROM ${DatabaseConstants.tableWebsites} WHERE ${DatabaseConstants.colIsBookmarked} = 1'),
        ) ??
        0;

    return {
      'website_count': websiteCount,
      'category_count': categoryCount,
      'history_count': historyCount,
      'bookmark_count': bookmarkCount,
      'db_version': AppConstants.dbVersion,
      'db_path': db.path,
    };
  }

  Future<void> clearVisitHistory() async {
    final db = await database;
    await db.delete(DatabaseConstants.tableVisitHistory);
  }
}
