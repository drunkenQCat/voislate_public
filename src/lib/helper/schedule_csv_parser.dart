import 'dart:io';
import 'package:csv/csv.dart';

class ScheduleItem {
  final String key;
  final String fix;
  final Note note;

  ScheduleItem(this.key, this.fix, this.note);
}

class Note {
  final List<String> objects;
  final String type;
  final String append;

  Note({required this.objects, required this.type, required this.append});
}

List<ScheduleItem> parseCSVData(String filePath) {
  final file = File(filePath);
  final csvString = file.readAsStringSync();
  final csvData = const CsvToListConverter().convert(csvString);

  List<ScheduleItem> scheduleItems = [];

  for (var row in csvData) {
    String keyFix = row[0];
    List<String> objects = row[1].split(',');
    String type = row[2];
    String append = row[3];

    RegExp regExp = RegExp(r'(\d+)([A-Z]+)');
    Match? match = regExp.firstMatch(keyFix);

    if (match != null) {
      String key = match.group(1)!;
      String fix = match.group(2) ?? "";

      Note note = Note(objects: objects, type: type, append: append);
      ScheduleItem scheduleItem = ScheduleItem(key, fix, note);
      scheduleItems.add(scheduleItem);
    } else {
      throw const FormatException('Invalid keyFix format');
    }
  }

  return scheduleItems;
}

// void main() {
//   String filePath = 'path/to/csv/file.csv';
//   List<ScheduleItem> scheduleItems = parseCSVData(filePath);
//
//   // Do something with the parsed data
//   for (var item in scheduleItems) {
//     print('Key: ${item.key}, Fix: ${item.fix}, Objects: ${item.note.objects}, Type: ${item.note.type}, Append: ${item.note.append}');
//   }
// }
