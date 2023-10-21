import 'dart:io';

import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:voislate/models/slate_log_item.dart';

import 'package:voislate/providers/slate_log_notifier.dart';
import 'package:flutter/services.dart';

void quitApp() {
  // Check if the platform is Android or iOS
  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
}

class SettingsConfiguePage extends StatelessWidget {
  final TextEditingController projectNameController =
      TextEditingController(text: Hive.box("settings").get("project"));
  SettingsConfiguePage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget cancelButton = TextButton(
      child: const Text(
        "取消",
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () => Navigator.pop(context),
    );

    Widget clearTodayLogsConfirmButton = TextButton(
      child: const Text(
        "确认",
      ),
      onPressed: () {
        var logProvider = Provider.of<SlateLogNotifier>(context, listen: false);
        logProvider.clear();
        Navigator.pop(context);
      },
    );

    Widget clearSchedulesButton = TextButton(
      child: const Text(
        "清空拍摄计划",
      ),
      onPressed: () {
        var scheduleBox = Hive.box('scenes_box');
        scheduleBox.clear();
        Hive.box('scn_sht_tk').clear();
        Hive.box('picker_history').clear();
        quitApp();
        Navigator.pop(context);
      },
    );
    Widget clearAllConfirmButton = TextButton(
      child: const Text(
        "确认",
      ),
      onPressed: () {
        var logProvider = Provider.of<SlateLogNotifier>(context, listen: false);
        logProvider.clear();
        var dateBox = Hive.box('dates');
        for (String date in dateBox.values.toList().cast()) {
          if (date != logProvider.today) {
            Hive.box<SlateLogItem>(date).close();
            Hive.box<SlateLogItem>(date).deleteFromDisk();
          }
        }
        // if dates are more than one, delete all except the last one(today)
        dateBox.clear();
        dateBox.put(logProvider.today, logProvider.today);
        quitApp();
        Navigator.pop(context);
      },
    );

    String exoprtAllLogs() {
      var dateBox = Hive.box('dates');
      var allLogs = "";
      List<SlateLogItem> logItems = [];
      for (String date in dateBox.values.toList().cast()) {
        var box = Hive.box<SlateLogItem>(date);
        logItems += box.values.toList();
      }
      var json = JsonMapper.serialize(logItems);
      allLogs += json;
      return allLogs;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('VoiSlate 设置'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Text('工程名'),
            title: TextField(
              controller: projectNameController,
              decoration: const InputDecoration(),
              onChanged: (value) => Hive.box("settings").put("project", value),
            ),
          ),
          ListTile(
            title: const Text('操作模式'),
            trailing: DropdownButton<String>(
              value: '左手',
              onChanged: (newValue) {},
              items: <String>['左手', '右手', '中间']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          SwitchListTile(
            title: const Text('音量键控制'),
            value: true,
            onChanged: (bool value) {},
          ),
          TextButton(
              onPressed: () {
                var logs = exoprtAllLogs();
                final tempDir = Directory.systemTemp.createTempSync();
                final timeStamp = DateTime.timestamp()
                    .toLocal()
                    .toString()
                    .split('.')[0]; // get current time stamp
                final slateLogDestiny = File(
                    '${tempDir.path}/${projectNameController.text}_all_$timeStamp.json'); // create file with time stamp suffix
                slateLogDestiny.writeAsStringSync(logs);
                // Share.share(json);
                Share.shareXFiles([XFile(slateLogDestiny.path)]);
              },
              child: const Text(
                '导出所有场记',
                style: TextStyle(color: Colors.blue),
              )),
          TextButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('清除场记'),
                        content: const Text('是否确认要清除场记？'),
                        actions: [
                          cancelButton,
                          clearTodayLogsConfirmButton,
                        ],
                      );
                    });
              },
              child: const Text(
                '清空今日场记',
                style: TextStyle(color: Colors.red),
              )),
          TextButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('重置场记'),
                        content: const Text('是否确认要清除场记？之后需手动重启App'),
                        actions: [
                          cancelButton,
                          clearAllConfirmButton,
                        ],
                      );
                    });
              },
              child: const Text(
                '清空所有场记',
                style: TextStyle(color: Colors.red),
              )),
          TextButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('重置拍摄计划'),
                        content: const Text('是否确认要清除拍摄计划？之后需手动重启App'),
                        actions: [
                          cancelButton,
                          clearSchedulesButton,
                        ],
                      );
                    });
              },
              child: const Text(
                '清空所有拍摄计划',
                style: TextStyle(color: Colors.red),
              ))
        ],
      ),
    );
  }
}
