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
  @override
  String toString() => "$num-$fix";
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
  if (inputRow[2].isEmpty) return null;
  var currentShtNum = getShtNum(inputRow) ?? "0";
  final shtNum = ItemInfoExtractor.numRegExp.stringMatch(currentShtNum) ?? "0";
  final shtFix = ItemInfoExtractor.fixRegExp.stringMatch(currentShtNum) ?? "";
  final currentShtType = getShtType(inputRow);
  final shtType = currentShtType.isEmpty ? "近景" : currentShtType;
  return ItemInfoExtractor(num: shtNum, fix: shtFix, type: shtType);
}

String? getScnContent(List<String> inputRow) =>
    inputRow[1].isEmpty ? null : "${inputRow[1]}，${inputRow[3]}";
String? getShtNum(List<String> inputRow) =>
    inputRow[2].isEmpty ? null : inputRow[2];
String getShtType(List<String> inputRow) =>
    inputRow[4].isEmpty ? "近景" : inputRow[4];
String getShtContent(List<String> inputRow) => inputRow[5];
String getShtAppend(List<String> inputRow) => inputRow[6];
ScheduleItem getCurrentScnInfo(ScnMap m) => m.keys.first;
SeperatedRows getCurrentShts(ScnMap m) => m.values.first;

SeperatedTable divideScns(List<List<String>> csvData) {
  SeperatedTable result = [];
  Set<String> processedInfo = <String>{}; // 用于跟踪处理过的scnBasicInfo

  for (List<String> row in csvData) {
    if (row.isEmpty) continue; // 跳过空行

    var scnBasicInfo = getScnNumAndLocation(row);
    var shtBasicInfo = getShtNumAndType(row);
    if (scnBasicInfo == null && shtBasicInfo == null)
      continue; // 跳过scn 和 sht 都为null的行
    if (scnBasicInfo == null && shtBasicInfo != null && result.isNotEmpty) {
      var lastScn = result.last;
      lastScn.add(row);
      continue;
    }

    // 转换scnBasicInfo为字符串形式，以便于在Set中比较
    String infoKey = scnBasicInfo.toString();
    if (processedInfo.contains(infoKey)) continue; // 如果已处理过此scnBasicInfo，跳过

    // 如果是新的scnBasicInfo，添加到结果中并记录
    processedInfo.add(infoKey);
    result.add([row]); // 创建一个新的SeperatedRows并添加到result中
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
  var shotsRow = getCurrentShts(inputMap);
  List<ScheduleItem> currentShts = getShtList(shotsRow);
  return SceneSchedule(currentShts, scnInfo);
}

List<ScheduleItem> getShtList(SeperatedRows scnShtsText) {
  Set<String> uniqueKeys = {};
  List<ScheduleItem> results = scnShtsText
      .map((item) {
        var basicInfo = getShtNumAndType(item);
        if (basicInfo == null) return null;

        String key = basicInfo.toString();
        if (uniqueKeys.contains(key)) {
          return null; // 如果已存在，则跳过
        }
        uniqueKeys.add(key); // 记录新的组合

        return spawnNewShtInfo(basicInfo, item);
      })
      .where((item) => item != null)
      .cast<ScheduleItem>()
      .toList();

  return results;
}

List<SceneSchedule> parseCSVData(String filePath) {
  final file = File(filePath);
  final csvString = file.readAsStringSync();
  final List<List<String>> csvData =
      const CsvToListConverter().convert(csvString, shouldParseNumbers: false);
  csvData.removeAt(0);

  var seperatedTable = divideScns(csvData);
  var newScnMaps = generateScns(seperatedTable);
  var finalSchedule = newScnMaps.map((scn) => generateNewScn(scn)).toList();

  return finalSchedule;
}
