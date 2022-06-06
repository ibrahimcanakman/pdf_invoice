import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._internal();
      return _databaseHelper!;
    } else {
      return _databaseHelper!;
    }
  }

  DatabaseHelper._internal();

  Future<Database> _getDatabase() async {
    if (_database == null) {
      _database = await _initialiseDatabase();
      return _database!;
    } else {
      return _database!;
    }
  }

  Future<Database> _initialiseDatabase() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "pdf_database.db");

    var exists = await databaseExists(path);

    if (!exists) {
      print("Creating new copy from asset");

      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data =
          await rootBundle.load(join("assets", "pdf_database.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }
    return await openDatabase(path, readOnly: false);
  }

  Future<int> aciklamaekle(String aciklama) async{
    var db = await _getDatabase();
    var a = await db.insert('aciklamalar', {
      'aciklama': aciklama
    });
    return a;
  }

  Future<List<Map<String, dynamic>>> aciklamalarigetir() async {
    var db = await _getDatabase();
    var sonuc = await db.query('aciklamalar');
    return sonuc;
  }

  

  /* Future<int> kaydet(String firma) async {
    var db = await _getDatabase();
    var a = await db.delete('firma');
    var sonuc = await db.insert('firma', {'firmaAdi': firma});
    return sonuc;
  }

  Future<List<Map<String, dynamic>>> getir() async {
    var db = await _getDatabase();
    var sonuc = await db.query('firma');
    return sonuc;
  } */

  













}