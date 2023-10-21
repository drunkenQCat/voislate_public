import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:voislate/models/slate_log_item.dart';
import '../models/recorder_file_num.dart';

class SlateStatusNotifier extends ChangeNotifier {
  int _selectedSceneIndex =
      Hive.box('scn_sht_tk').get('scnIndex', defaultValue: 0) as int;
  int _selectedShotIndex =
      Hive.box('scn_sht_tk').get('shtIndex', defaultValue: 0) as int;
  int _selectedTakeIndex =
      Hive.box('scn_sht_tk').get('tkIndex', defaultValue: 0) as int;
  bool _isLinked =
      Hive.box('scn_sht_tk').get('isLinked', defaultValue: true) as bool;
  final String _date = Hive.box('scn_sht_tk')
      .get('date', defaultValue: RecordFileNum.today) as String;
  late int _recordCount = (RecordFileNum.today == _date)
      ? Hive.box('scn_sht_tk').get('recordCount', defaultValue: 1) as int
      : 1;
  String _recordLinker =
      Hive.box('scn_sht_tk').get('recordLinker', defaultValue: "-T") as String;
  String _prefixType = 
      Hive.box('scn_sht_tk').get('prefixType', defaultValue: "default") as String;
  String _customPrefix = 
      Hive.box('scn_sht_tk').get('customPrefix', defaultValue: "custom") as String;

  String _currentDesc =
      Hive.box('scn_sht_tk').get('desc', defaultValue: "") as String;
  String _currentNote =
      Hive.box('scn_sht_tk').get('note', defaultValue: "") as String;

  TkStatus _okTk = Hive.box('scn_sht_tk')
      .get('oktk', defaultValue: TkStatus.notChecked) as TkStatus;
  ShtStatus _okSht = Hive.box('scn_sht_tk')
      .get('oksht', defaultValue: ShtStatus.notChecked) as ShtStatus;
      

  int get selectedSceneIndex => _selectedSceneIndex;
  int get selectedShotIndex => _selectedShotIndex;
  int get selectedTakeIndex => _selectedTakeIndex;
  bool get isLinked => _isLinked;
  String get date => _date;
  int get recordCount => _recordCount;
  String get recordLinker => _recordLinker;
  String get prefixType => _prefixType;
  String get customPrefix => _customPrefix;
  String get currentDesc => _currentDesc;
  String get currentNote => _currentNote;
  TkStatus get okTk => _okTk;
  ShtStatus get okSht => _okSht;
  void setIndex({int? scene, int? shot, int? take, int? count}) {
    if (scene != null) {
      _selectedSceneIndex = scene;
      Hive.box('scn_sht_tk').put('scnIndex', _selectedSceneIndex);
    }
    if (shot != null) {
      _selectedShotIndex = shot;
      Hive.box('scn_sht_tk').put('shtIndex', _selectedShotIndex);
    }
    if (take != null) {
      _selectedTakeIndex = take;
      Hive.box('scn_sht_tk').put('tkIndex', _selectedTakeIndex);
    }
    if (count != null) {
      _recordCount = count;
      Hive.box('scn_sht_tk').put('recordCount', _recordCount);
    }
    Hive.box('scn_sht_tk').put('date', RecordFileNum.today);
    notifyListeners();
  }

  void setNote({String? desc, String? note}) {
    if (desc != null) {
      _currentDesc = desc;
      Hive.box('scn_sht_tk').put('desc', desc);
    }
    if (note != null) {
      _currentNote = note;
      Hive.box('scn_sht_tk').put('note', note);
    }
  }

  void setLink(bool link) {
    _isLinked = link;
    Hive.box('scn_sht_tk').put('isLinked', link);
    notifyListeners();
  }

  void setRecordLinker(String linker) {
    _recordLinker = linker;
    Hive.box('scn_sht_tk').put('recordLinker', _recordLinker);
    notifyListeners();
  }

  void setPrefixType(String newValue) {
    _prefixType = newValue;
    Hive.box('scn_sht_tk').put('prefixType', newValue);
    notifyListeners();
  }

  void setCustomPrefix(String newValue) {
    _customPrefix = newValue;
    Hive.box('scn_sht_tk').put('customPrefix', newValue);
    notifyListeners();
  }

  void setOkStatus(
      {TkStatus? currentTk,
      ShtStatus? currentSht,
      bool? doReset}) {
    _okTk = currentTk ?? _okTk;
    _okSht = currentSht ?? _okSht;
    doReset = doReset??false;
    if (doReset) {
      _okTk = TkStatus.notChecked;
      _okSht = ShtStatus.notChecked;
    }
    Hive.box('scn_sht_tk').put('oktk', _okTk);
    Hive.box('scn_sht_tk').put('oksht', _okSht);
    notifyListeners();
  }
}
