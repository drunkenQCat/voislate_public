import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:voislate/models/slate_log_item.dart';

import 'pages/main_page.dart';
import 'models/slate_schedule.dart';
import 'data/dummy_data.dart';
import 'models/recorder_file_num.dart';
import 'main.mapper.g.dart';

void main() async {
  // initializations
  initializeJsonMapper(adapters: [
    JsonMapperAdapter(converters: {Enum: EnumConverterShort()})
  ]);
  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(ScheduleItemAdapter());
  Hive.registerAdapter(DataListAdapter());
  Hive.registerAdapter(SceneScheduleAdapter());
  Hive.registerAdapter(SlateLogItemAdapter());
  Hive.registerAdapter(ShtStatusAdapter());
  Hive.registerAdapter(TkStatusAdapter());

  await Hive.openBox('scenes_box');
  if (Hive.box('scenes_box').isEmpty) {
    await Hive.box('scenes_box').addAll([sceneSchedule, scene2ASchedule]);
  }
  await Hive.openBox('settings');
  if (Hive.box('settings').isEmpty) {
    await Hive.box('settings').put("project", "NewProject");
  }
  await Hive.openBox('scn_sht_tk');
  await Hive.openBox('dates');
  await Hive.openBox('picker_history');
  if (kDebugMode) {
    var testBox = await Hive.openBox<SlateLogItem>('test');
    await testBox.clear();
    await testBox.addAll(slateLogItems);
  }
  var today = RecordFileNum.today;

  // if today is not in the dates box, add it
  if (Hive.box('dates').isEmpty) {
    Hive.box('dates').put(today, today);
  }
  if (!Hive.box('dates').containsKey(today)) {
    Hive.box('dates').put(today, today);
    Hive.box('picker_history').clear();
    Hive.box('scn_sht_tk').put('recordCount', 1);
  }

  var dates = Hive.box('dates').values.map((e) => e as String).toList();
  for (var date in dates) {
    await Hive.openBox<SlateLogItem>(date);
  }
  // the slate log of today
  runApp(const VoiSlate());
}
