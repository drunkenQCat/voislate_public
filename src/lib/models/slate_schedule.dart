// the template of the schedule items
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
part 'slate_schedule.g.dart';

@HiveType(typeId: 0)
class ScheduleItem {
  @HiveField(0)
  String _key;
  String get key => _key;
  set key(String newKey) {
    _key = newKey;
    name = _key + _fix;
  }


  @HiveField(1)
  String _fix;
  String get fix => _fix;
  set fix(String newFix) {
    _fix = newFix;
    name = _key + _fix;
  }

  @HiveField(2)
  String name;
  @HiveField(3)
  Note note;
  // constructor
  ScheduleItem(this._key, this._fix, this.note) : name = _key + _fix;

  static fromJson() {}
}

@HiveType(typeId: 1)
class Note {
  @HiveField(0)
  late List<String> objects;
  @HiveField(1)
  late String type;
  @HiveField(2)
  final String append;
  //constructor
  Note({required this.objects, required this.type, required this.append});
  @override
  String toString() {
    // concatenate the objects list into a string
    String objectsString = objects.join(', ');
    return 'Note{objects: $objectsString, type: $type, append: $append}';
  }
}

// this abstract class is used to store the data of the schedule, literally a list of schedule items
@HiveType(typeId: 2)
class DataList extends HiveObject with ChangeNotifier {
  @HiveField(0)
  List<ScheduleItem> _data = [];
  List<ScheduleItem> get data => _data;
  set data(List<ScheduleItem> newData) {
    _listDupDetect(newData);
    _data = newData;
    refresh();
  }

  DataList(List<ScheduleItem>? shots, [ScheduleItem? info]) {
    // detect that if the _data has duplicate items
    // if it does, throw an error
    if (shots == null) {
      _data = [];
      return;
    }
    _listDupDetect(shots);
    refresh();
  }

  get length {
    return _data.length;
  }

  void _listDupDetect(List<ScheduleItem> shots) {
    var set = <String>{};
    // if empty list, it is running in the constructor
    // if not, it is running in the setter
    var toBeDetected = _data == [] ? _data + shots : shots;
    for (var item in toBeDetected) {
      if (set.contains(item.name)) {
        throw DuplicateItemException('Duplicate items in the list');
      }
      set.add(item.name);
    }
    _data = toBeDetected;
  }

  void _dupDetect(ScheduleItem shot) {
    for (var item in _data) {
      if (shot.name == item.name) {
        throw DuplicateItemException('Duplicate items in the list');
      }
    }
  }

  void add(ScheduleItem item) {
    _dupDetect(item);
    _data.add(item);
    refresh();
  }

  void remove(ScheduleItem item) {
    _data.remove(item);
    refresh();
  }

  ScheduleItem removeAt(int index) {
    var removed = _data.removeAt(index);
    refresh();
    return removed;
  }

  void insert(int index, ScheduleItem item) {
    _dupDetect(item);
    _data.insert(index, item);
    refresh();
  }

  void update(int oldIndex, ScheduleItem newItem) {
    // detect if the new item is duplicate to any other item
    var _ = List<ScheduleItem>.from(_data);
    _.removeAt(oldIndex);
    for (var item in _) {
      if (newItem.name == item.name) {
        throw DuplicateItemException('Duplicate items in the list');
      }
    }
    _data[oldIndex] = newItem;
    refresh();
  }

  void refresh() {
    notifyListeners();
  }
}

@HiveType(typeId: 3)
class SceneSchedule extends DataList {
  @HiveField(1)
  ScheduleItem info;
  SceneSchedule(inputShots, this.info) : super(inputShots, info);

  ScheduleItem operator [](int index) => data[index];
  void operator []=(int index, ScheduleItem item) => data[index] = item;
}

class DuplicateItemException implements Exception {
  final String message;
  DuplicateItemException(this.message);
  @override
  String toString() => message;
}
