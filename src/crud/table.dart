import 'dart:io';

class Table {
  late File file;

  /// list of records in the table, each record is a list of attributes
  /// 
  /// the first attribute is the primary key
  List<List<String>> records = [];
  int numAttributes = -1;

  Table._constructor();

  /// creates a table based on the given path
  static Future<Table> open(String name, [String? path]) async {
    Table table = Table._constructor();

    table.file = await File("${path == null ? '' : "$path\\"}$name.csv").create();
    table.fromFile();
    return table;
  }

  // void close({bool save = true}) {
  //   if (save) {
  //     this.toFile();
  //   }
  //   // potentially more to do if we change how file works
  // }


  /// updates the [records] of this [Table] to reflect the data found in its [file]
  void fromFile() {
    records = [];
    for (String line in file.readAsLinesSync()) {
      records.add(line.split(','));
      if (numAttributes == -1) {
        numAttributes = records.last.length;
      }
      else if (records.last.length != numAttributes) {
        throw FormatException("Expected $numAttributes attributes, found ${records.last.length}", records.last);
      }
    }
  }

  /// updates the contents of this [Table]'s [file] to reflect the data in [records]
  void toFile() {
    // TODO
  }

  /// adds a [record] to [records]
  void create(List<String> record) {
    records.add(record);
  }

  /// returns a list of all elements of [records]
  /// that match [filter] and are in the domain established by [rows]
  List<List<String>> read({
    bool Function(int)? rows,
    bool Function(List<String>?)? filter
  }) {
    bool Function(dynamic) tautology = (_) => true;
    List<List<String>> output = [];
    for (int i = 0; i < records.length; i++) {
      if ((rows ?? tautology)(i) && (filter ?? tautology)(records[i])) {
        output.add(records[i]);
      }
    }
    return output;
  }

  /// finds the record with the appropriate primary key and sets its attributes
  void update(List<String> target) {
    records
      .firstWhere((source) => source.first == target.first)
      .setRange(1, records.first.length, target, 1)
    ;
  }

  void delete(
    bool Function(int)? rows,
    bool Function(List<String>?)? filter
  ) {
    bool Function(dynamic) tautology = (_) => true;
    for (int i = 0; i < records.length;) {
      if ((rows ?? tautology)(i) && (filter ?? tautology)(records[i])) {
        records.removeAt(i);
      }
      else {
        i++;
      }
    }
  }
}