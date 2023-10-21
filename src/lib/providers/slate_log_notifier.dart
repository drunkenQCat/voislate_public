
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:voislate/models/slate_log_item.dart';
import '../models/recorder_file_num.dart';

class SlateLogNotifier with ChangeNotifier {
  var dates = Hive.box('dates').values.map((e) => e as String).toList();
  var today = RecordFileNum.today;
  late Box<SlateLogItem> boxToday;
  late List<SlateLogItem> logToday;

  SlateLogNotifier() {
    boxToday = Hive.box(today);
    logToday = boxToday.values.map((e) => e).toList();
  }

  void add(String logKey, SlateLogItem item) {
    logToday.add(item);
    boxToday.put(logKey, item);
    notifyListeners();
  }

  void removeLast() {
    logToday.removeLast();
    boxToday.deleteAt(boxToday.length - 1);
    notifyListeners();
  }

  void removeAt(int index) {
    logToday.removeAt(index);
    boxToday.deleteAt(index);
    notifyListeners();
  }

  void removeFile(String key) {
    logToday.removeWhere((element) =>
        element.fileName == key);
    boxToday.delete(key);
    notifyListeners();
  }

  void clear() {
    logToday.clear();
    boxToday.clear();
    notifyListeners();
  }

  get length => logToday.length;

  operator [](int index) => logToday[index];

  operator []=(int index, SlateLogItem item) {
    logToday[index] = item;
    boxToday.putAt(index, item);
    notifyListeners();
  }
}
