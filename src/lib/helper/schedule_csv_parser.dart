import 'dart:io';
import 'package:csv/csv.dart';
import 'package:voislate/models/slate_schedule.dart';

typedef SeperatedTable = List<List<List<String>>>;
typedef SeperatedRows = List<List<String>>;
typedef ScnMap = Map<ScheduleItem, List<List<String>>>;

class ItemInfoExtractor {
  static RegExp numRegExp = RegExp(r'\d+');
  static RegExp locRegExp = RegExp(r'[^\d、\n]+');
  static RegExp fixRegExp = RegExp(r'[a-zA-z]');

  String num;
  String fix;
  String type;

  ItemInfoExtractor({required this.num, required this.fix, required this.type});
}

ScheduleItem spawnNewScnInfo(ItemInfoExtractor basicInfo, List<String> scnRow) {
  ScheduleItem emptyScnInfo = ScheduleItem(
    basicInfo.num,
    basicInfo.fix,
    Note(
      objects: ['Boom'],
      type: basicInfo.type,
    append: getScnContent(scnRow) ?? "",
    ),
  );
  return emptyScnInfo;
}

ScheduleItem spawnNewShtInfo(ItemInfoExtractor basicInfo, List<String> shtRow) {
  ScheduleItem emptyShtInfo = ScheduleItem(
    basicInfo.num,
    basicInfo.fix,
    Note(
        objects: ['Boom'],
        type: basicInfo.type,
        append: getShtContent(shtRow) + getShtAppend(shtRow)),
  );
  return emptyShtInfo;
}

ItemInfoExtractor? getScnNumAndLocation(List<String> inputRow) {
  if (inputRow[0].isEmpty) return null;
  final scnNum = ItemInfoExtractor.numRegExp.stringMatch(inputRow[0]) ?? "0";
  final scnFix = ItemInfoExtractor.fixRegExp.stringMatch(inputRow[0]) ?? "";
  final scnLoc = ItemInfoExtractor.locRegExp.stringMatch(inputRow[0]) ?? "";
  return ItemInfoExtractor(num: scnNum, fix: scnFix, type: scnLoc);
}

ItemInfoExtractor? getShtNumAndType(List<String> inputRow) {
  if (inputRow[0].isEmpty) return null;
  var currentShtNum = getShtNum(inputRow) ?? "0";
  final shtNum = ItemInfoExtractor.numRegExp.stringMatch(currentShtNum) ?? "0";
  final shtFix = ItemInfoExtractor.fixRegExp.stringMatch(currentShtNum) ?? "";
  final currentShtType = getShtType(inputRow);
  final shtType = currentShtType.isEmpty ? "近景" : currentShtType;
  return ItemInfoExtractor(num: shtNum, fix: shtFix, type: shtType);
}

String? getScnContent(List<String> inputRow) =>
    inputRow[1].isEmpty ? null : inputRow[1];
String? getShtNum(List<String> inputRow) =>
    inputRow[2].isEmpty ? null : inputRow[2];
String getShtType(List<String> inputRow) =>
    inputRow[4].isEmpty ? "近景" : inputRow[4];
String getShtContent(List<String> inputRow) => inputRow[5];
String getShtAppend(List<String> inputRow) => inputRow[6];
ScheduleItem getCurrentScnInfo(ScnMap m) => m.keys.first;
SeperatedRows getCurrentShts(ScnMap m) => m.values.first;

SeperatedTable devideScns(List<List<String>> csvData) {
  SeperatedTable result = [];
  SeperatedRows currentList = [];

  for (List<String> row in csvData) {
    var scnBasicInfo = getScnNumAndLocation(row);
    if (row.isNotEmpty && scnBasicInfo != null) {
      if (currentList.isNotEmpty) {
        result.add(currentList);
        currentList = [];
      }
    }
    currentList.add(row);
  }

  if (currentList.isNotEmpty) {
    result.add(currentList);
  }

  return result;
}

List<ScnMap> generateScns(SeperatedTable scnTable) {
  List<ScnMap> kv = scnTable.map((table) {
    var numAndLoc = getScnNumAndLocation(table[0]);
    var k = spawnNewScnInfo(numAndLoc!, table[0]);
    return {k: table};
  }).toList();

  return kv;
}

SceneSchedule generateNewScn(ScnMap inputMap) {
  var scnInfo = getCurrentScnInfo(inputMap);
  var scnShtsText = getCurrentShts(inputMap);
  List<ScheduleItem> currentShts = getShtList(scnShtsText);
  return SceneSchedule(currentShts, scnInfo);
}

List<ScheduleItem> getShtList(SeperatedRows scnShtsText) {
  List<ScheduleItem> results = scnShtsText.map((item) {
    var basicInfo = getShtNumAndType(item);
    var newSht = spawnNewShtInfo(basicInfo!, item);
    return newSht;
  }).toList();
  return results;
}

List<SceneSchedule> parseCSVData(String filePath) {
  final file = File(filePath);
  final csvString = file.readAsStringSync();
  final List<List<String>> csvData =
      const CsvToListConverter().convert(csvString);

  var seperatedTable = devideScns(csvData);
  var newScnMaps = generateScns(seperatedTable);
  var finalSchedule = newScnMaps.map((scn) => generateNewScn(scn)).toList();

  return finalSchedule;
}
