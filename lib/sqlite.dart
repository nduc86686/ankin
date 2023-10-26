import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Note {
  int? id;
  String? guid;
  int? mid;
  int? mod;
  int? usn;
  String? tags;
  String? flds;
  dynamic? sfld;
  int? csum;
  int? flags;
  String? data;

  Note({
    this.id,
    this.guid,
    this.mid,
    this.mod,
    this.usn,
    this.tags,
    this.flds,
    this.sfld,
    this.csum,
    this.flags,
    this.data,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      guid: map['guid'],
      mid: map['mid'],
      mod: map['mod'],
      usn: map['usn'],
      tags: map['tags'],
      flds: map['flds'],
      sfld: map['sfld'],
      csum: map['csum'],
      flags: map['flags'],
      data: map['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guid': guid,
      'mid': mid,
      'mod': mod,
      'usn': usn,
      'tags': tags,
      'flds': flds,
      'sfld': sfld,
      'csum': csum,
      'flags': flags,
      'data': data,
    };
  }
}

Future<void> copyAndReadDatabase() async {
  final ByteData data = await rootBundle.load('assets/collection.anki21');
  final List<int> bytes = data.buffer.asUint8List();
  final String path = await getDatabasesPath();
  final String dbPath = join(path, 'your_database_name.db');

  if (await FileSystemEntity.type(dbPath) == FileSystemEntityType.notFound) {
    await File(dbPath).writeAsBytes(bytes);
  }

  final Database database = await openDatabase(dbPath);

  final List<Map<String, dynamic>> results = await database.query('notes');
  final List<Note> notes =
      results.map((result) => Note.fromMap(result)).toList();

  database.close();

  // Chuyển đổi danh sách các đối tượng Note thành JSON
  final jsonData = notes.map((note) => note.toJson()).toList();

  // print(json.encode(jsonData));
  print('data ${notes[0].flds}');
  print('data ${notes.length}');
}

Future<List<Map<String, dynamic>>> queryDatabase() async {
  // Mở kết nối đến tệp SQLite
  Database database = await openDatabase(
      join(await getDatabasesPath(), 'your_database_name.db'));

  // Thực hiện truy vấn SQL
  List<Map<String, dynamic>> results =
      await database.rawQuery('SELECT * FROM notes');

  // Đóng kết nối
  await database.close();

  return results;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await copyAndReadDatabase(); // Sao chép tệp SQLite vào bộ nhớ của ứng dụng
  List<Map<String, dynamic>> data =
      await queryDatabase(); // Truy vấn dữ liệu từ SQLite

  // Chuyển đổi dữ liệu thành định dạng JSON
  String jsonData = jsonEncode(data);
  // print(jsonData);
}
