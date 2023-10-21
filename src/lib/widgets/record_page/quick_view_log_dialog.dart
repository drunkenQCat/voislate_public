import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voislate/models/recorder_file_num.dart';
import 'package:voislate/providers/slate_log_notifier.dart';
import 'package:voislate/widgets/slate_log_page/log_editor.dart';

class DisplayNotesButton extends StatelessWidget {
  final List<MapEntry<String, String>> notes;
  final RecordFileNum num;

  const DisplayNotesButton({
    super.key,
    required this.notes,
    required this.num,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'display_notes',
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('场记速览'),
              content: LogQuickViewer(notes: notes, num: num),
            );
          },
        );
      },
      tooltip: '显示场记速览',
      child: const Icon(Icons.notes),
    );
  }
}

class LogQuickViewer extends StatefulWidget {
  final List<MapEntry<String, String>> notes;
  final RecordFileNum num;

  const LogQuickViewer({
    super.key,
    required this.notes,
    required this.num,
  });

  @override
  State<LogQuickViewer> createState() => _LogQuickViewerState();
}

class _LogQuickViewerState extends State<LogQuickViewer> {
  final ScrollController controller = ScrollController();
  late SlateLogNotifier _logNotifier;

  @override
  void initState() {
    super.initState();
    _logNotifier = Provider.of<SlateLogNotifier>(context, listen: false);
    WidgetsBinding.instance.endOfFrame.then((_) {
      //   controller.jumpTo(controller.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var logsBox = _logNotifier.boxToday;
    var logItems = _logNotifier.logToday;
    Widget listHead = Container(
      color: Colors.purple[100],
      child: itemRow(const MapEntry('File Name', 'Note'), -1),
    );
    List<Widget> logs = widget.notes.asMap().entries.map((notePair) {
      var index = notePair.key;
      var note = notePair.value;
      int logIndex = logItems.indexWhere((item) => item.fileName == note.key);
      return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LogEditor(
                          context: context,
                          logItems: logItems,
                          logsBox: logsBox,
                          index: logIndex,
                        )));
          },
          child: Container(
            color: index % 2 == 0 ? Colors.white : Colors.grey[200],
            child: itemRow(note, index),
          ));
    }).toList();
    var promptIndicator = Container(
      color: Colors.blue[100],
      child: itemRow(
          MapEntry(widget.num.prevFileName(), '等待输入...'), widget.notes.length),
    );

    return SizedBox(
        width: screenWidth * 0.618,
        height: screenHeight * 0.7,
        child: (widget.num.number == 1 || widget.notes.isEmpty)
            ? const Center(child: Text('尚未开始记录'))
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: controller,
                child: Column(children: [
                  listHead,
                  Column(
                    children: logs,
                  ),
                  promptIndicator
                ]),
              ));
  }

  Row itemRow(MapEntry<String, String> note, int index) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              note.key,
              style: TextStyle(
                color: index % 2 == 0 ? Colors.black : Colors.grey[700],
              ),
            ),
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              note.value,
              style: TextStyle(
                color: index % 2 == 0 ? Colors.black : Colors.grey[700],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
