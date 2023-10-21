import 'dart:io';

import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:voislate/models/slate_schedule.dart';
import '../models/slate_log_item.dart';
import '../providers/slate_log_notifier.dart';
import '../providers/slate_status_notifier.dart';
import '../widgets/slate_log_page/log_editor.dart';

// ignore: must_be_immutable
class SlateLog extends StatefulWidget {
  var controller = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: false,
  );
  String date;
  SlateLog(this.date, {super.key});

  @override
  SlateLogState createState() => SlateLogState();
}

class SlateLogState extends State<SlateLog> {
  late SceneSchedule currentSceneData;
  late Box<SlateLogItem> logBox;
  late List<SlateLogItem> logList;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.endOfFrame.then((_) {
      widget.controller.jumpTo(widget.controller.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SlateLogNotifier, SlateStatusNotifier>(
      builder: (context, slateLogs, slateStatus, child) {
        currentSceneData = Hive.box('scenes_box')
            .getAt(slateStatus.selectedSceneIndex) as SceneSchedule;
        logBox = Hive.box(widget.date);
        logList = logBox.values.toList().cast<SlateLogItem>();
        var currentScn = currentSceneData.info.name;
        var currentShot = currentSceneData[slateStatus.selectedShotIndex].name;

        Map<String, Map<String, Map<int, SlateLogItem>>> sortedItems = {};

        for (int i = 0; i < logList.length; i++) {
          // i is the index in logList
          SlateLogItem item = logList[i];
          if (!sortedItems.containsKey(item.scn)) {
            sortedItems[item.scn] = {};
          }
          if (!sortedItems[item.scn]!.containsKey(item.sht)) {
            sortedItems[item.scn]![item.sht] = {};
          }
          sortedItems[item.scn]![item.sht]![i] = item;
        }

        return Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            ListView.builder(
              controller: widget.controller,
              itemCount: sortedItems.length,
              itemBuilder: (BuildContext context, int index) {
                String scn = sortedItems.keys.elementAt(index);
                Map<String, Map<int, SlateLogItem>> shtItems =
                    sortedItems[scn]!;

                return ExpansionTile(
                  backgroundColor: Colors.grey,
                  initiallyExpanded: (scn == currentScn),
                  title: Center(child: Text(scn)),
                  subtitle: const Center(child: Text('场')),
                  children: shtItems.keys.map((sht) {
                    Map<int, SlateLogItem> items = shtItems[sht]!;

                    return ExpansionTile(
                      backgroundColor: Colors.grey[200],
                      initiallyExpanded: (sht == currentShot),
                      title: Text(sht),
                      subtitle: const Text('镜'),
                      children: items.entries.map((item) {
                        return logViewItem(item);
                      }).toList(),
                    );
                  }).toList(),
                );
              },
            ),
            ElevatedButton(
              onPressed: () {
                var json = JsonMapper.serialize(logList);
                final tempDir = Directory.systemTemp.createTempSync();
                final String projectName = Hive.box("settings").get("project");
                final timeStamp = DateTime.timestamp()
                    .toLocal()
                    .toString()
                    .split('.')[0]; // get current time stamp
                final slateLogDestiny = File(
                    '${tempDir.path}/${projectName}_$timeStamp.json'); // create file with time stamp suffix
                slateLogDestiny.writeAsStringSync(json);
                // Share.share(json);
                Share.shareXFiles([XFile(slateLogDestiny.path)]);
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.all(16),
              ),
              child: const Icon(Icons.share),
            ),
          ],
        );
      },
    );
  }

  Container logViewItem(MapEntry<int, SlateLogItem> item) {
    var shtNotePreParse = item.value.shtNote.split('<');
    var shtNote = shtNotePreParse[0];
    List<String> trackList = [];
    if (shtNotePreParse.length > 1) {
      shtNotePreParse.removeAt(0);
      for (var element in shtNotePreParse) {
        // iterate through the remaining elements
        trackList.add(
            element.replaceAll('/>', '')); // strip "/>" and add to trackList
      }
    }
    var tracks = trackList.join(","); // concate trackList with ","

    return Container(
      color: _getTkStatusColor(item.value.okTk),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LogEditor(
                context: context,
                logItems: logList,
                logsBox: logBox,
                index: item.key,
              ),
            ),
          ).then((value) => setState(
                // TODO:不要整页刷新
                () {},
              ));
        },
        leading: CircleAvatar(
          child: Text(item.value.tk.toString()),
        ),
        // title: RichText(
        //   text: TextSpan(
        //     style: const TextStyle(
        //       fontWeight: FontWeight.bold,
        //       color: Colors.black,
        //     ),
        //     children: [
        //       TextSpan(
        //         text: item.value.filenamePrefix,
        //       ),
        //       const TextSpan(text: ' '),
        //       TextSpan(text: item.value.filenameLinker),
        //       const TextSpan(text: ' '),
        //       TextSpan(text: item.value.filenameNum.toString().padLeft(3, '0')),
        //     ],
        //   ),
        // ),
        title: Text(
          item.value.fileName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TK Note: ${item.value.tkNote}'),
            Text('Shot Note: $shtNote\ntracks:$tracks'),
            Text('Scene Note: ${item.value.scnNote}'),
          ],
        ),
        trailing: Icon(
          _getShtStatusIcon(item.value.okSht),
        ),
      ),
    );
  }

  IconData _getShtStatusIcon(ShtStatus status) {
    switch (status) {
      case ShtStatus.notChecked:
        return Icons.check_box_outline_blank;
      case ShtStatus.ok:
        return Icons.check_circle_outline;
      case ShtStatus.nice:
        return Icons.thumb_up_alt_outlined;
      default:
        return Icons.error_outline;
    }
  }

  Color _getTkStatusColor(TkStatus status) {
    switch (status) {
      case TkStatus.notChecked: // changed enum name to TkStatus.notChecked
        return Colors.grey;
      case TkStatus.ok: // changed enum name to TkStatus.ok
        return Colors.green;
      case TkStatus.bad: // changed enum name to TkStatus.nice
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
