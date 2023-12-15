import 'package:hive_flutter/hive_flutter.dart';
import 'package:dart_json_mapper/dart_json_mapper.dart';

part 'slate_log_item.g.dart';

/// The status of the file.
/// * 0: not checked
/// * 1: ok
/// * 2: bad
@JsonSerializable()
@HiveType(typeId: 4)
enum TkStatus {
  @HiveField(0)
  notChecked,
  @HiveField(1)
  ok,
  @HiveField(2)
  bad,
}

/// The status of the slate.
/// * 0: not checked
/// * 1: ok
/// * 2: nice
@JsonSerializable()
@HiveType(typeId: 5)
enum ShtStatus {
  @HiveField(0)
  notChecked,
  @HiveField(1)
  ok,
  @HiveField(2)
  nice,
}

@JsonSerializable()
@HiveType(typeId: 6)
class SlateLogItem {
  @HiveField(0)
  String scn;
  @HiveField(1)
  String sht;
  @HiveField(2)
  int tk;
  @HiveField(3)
  String filenamePrefix;
  @HiveField(4)
  String filenameLinker;
  @HiveField(5)
  int filenameNum;
  String get fileName {
    return filenamePrefix +
        filenameLinker +
        filenameNum.toString().padLeft(3, '0');
  }

  @HiveField(6)
  String tkNote;
  @HiveField(7)
  String shtNote;
  @HiveField(8)
  String scnNote;
  @HiveField(9)
  TkStatus okTk;
  @HiveField(10)
  ShtStatus okSht;

  SlateLogItem({
    required this.scn,
    required this.sht,
    required this.tk,
    required this.filenamePrefix,
    required this.filenameLinker,
    required this.filenameNum,
    required this.tkNote,
    required this.shtNote,
    required this.scnNote,
    @JsonProperty(name: 'okTk') TkStatus currentOkTk = TkStatus.notChecked,
    @JsonProperty(name: 'okSht') ShtStatus currentOkSht = ShtStatus.notChecked,
  })  : okTk = currentOkTk,
        okSht = currentOkSht;
}
