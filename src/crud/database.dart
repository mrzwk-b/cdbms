import 'dart:io';
import 'table.dart';

class Database {
  String databasePath;
  Map<String, Table> tables;

  Database(this.databasePath): tables = {};


  Future<bool> create(String tableName) async {
    try {
      tables[tableName] = await Table.open(databasePath, tableName);
      return true;
    }
    on PathExistsException {
      return false;
    }
  }
}