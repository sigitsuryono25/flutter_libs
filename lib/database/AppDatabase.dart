import 'dart:async';
import 'package:floor/floor.dart';
import 'package:flutter_libs/database/BukuDAO.dart';
import 'package:flutter_libs/database/model/Buku.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'AppDatabase.g.dart';

@Database(version: 1, entities: [Buku])
abstract class AppDatabase extends FloorDatabase {
  BukuDAO get bukuDao;
}
