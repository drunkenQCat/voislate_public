import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voislate/models/recorder_type.dart';
import 'package:voislate/providers/slate_status_notifier.dart';

import '../../models/recorder_file_num.dart';

class FileCounter extends StatefulWidget {
  final RecordFileNum num;
  final int initCounter;
  const FileCounter({
    super.key,
    required int init,
    required this.num,
  }) : initCounter = init;

  @override
  FileCounterState createState() => FileCounterState();
}

class FileCounterState extends State<FileCounter> {
  @override
  Widget build(BuildContext context) {
    final TextStyle? textStyle = Theme.of(context).textTheme.headlineMedium;

    return StreamBuilder<int>(
      stream: widget.num.value,
      initialData: widget.initCounter,
      builder: (context, snapshot) {
        return Center(
          child: FileNameDisplayCard(
              num: widget.num, snapshot: snapshot, style: textStyle),
        );
      },
    );
  }
}

class FileNameDisplayCard extends StatefulWidget {
  final AsyncSnapshot snapshot;
  final TextStyle? style;
  final RecordFileNum num;

  const FileNameDisplayCard({
    super.key,
    required this.num,
    required this.snapshot,
    required this.style,
  });

  @override
  State<FileNameDisplayCard> createState() => FileNameDisplayCardState();
}

class FileNameDisplayCardState extends State<FileNameDisplayCard> {
  Recorder recorder = Recorder();

  @override
  void initState() {
    super.initState();
    judgeRecorderType();
  }

  void judgeRecorderType() {
    var type = RecorderType.defaultRecorder;
    var typeText = widget.num.recorderType;
    switch (typeText) {
      case "default":
        type = RecorderType.defaultRecorder;
        break;
      case "sound devices":
        type = RecorderType.soundDevices;
        break;
      case "custom":
        type = RecorderType.custom;
        break;
      default:
        type = RecorderType.defaultRecorder;
        break;
    }
    recorder.type = type;
  }

  String getRecorderTypeText(RecorderType type) {
    switch (type) {
      case RecorderType.defaultRecorder:
        return "default";
      case RecorderType.soundDevices:
        return "sound devices";
      case RecorderType.custom:
        return "custom";
      default:
        return "default";
    }
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle tagStyle = TextStyle(
      fontSize: 16,
      color: Colors.white70,
      fontWeight: FontWeight.w400,
    );
    var prefixCard = Card(
      color: Colors.white,
      shape: const RoundedRectangleBorder(),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          widget.num.prefix,
          style: widget.num.prefix.length > 6
              ? const TextStyle(fontSize: 20)
              : widget.style,
        ),
      ),
    );
    var prefixSegment = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          // TODO: fix the display of prefix
          widget.num.prefix.contains(RegExp(r'^[0-9]+$')) ? 'Date' : 'Custom',
          style: tagStyle,
        ),
        prefixCard,
      ],
    );
    var diviCard = Card(
      color: Colors.white,
      shape: const RoundedRectangleBorder(),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11),
        child: Text(
          widget.num.intervalSymbol,
          style: const TextStyle(
            fontSize: 26,
            color: Colors.black45,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
    var dividerSegment = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Divider',
          style: tagStyle,
        ),
        GestureDetector(
          onLongPress: () => editNameDivider(context),
          child: diviCard,
        ),
      ],
    );
    var numCard = Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Text(
          widget.snapshot.data.toString().padLeft(3, '0'),
          style: widget.style,
        ),
      ),
    );
    var fileNumSegment = Column(
      children: [
        const Text(
          'Num',
          style: tagStyle,
        ),
        GestureDetector(
            onLongPress: () => editFileNum(context), child: numCard),
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25),
      child: Card(
        color: Colors.blueGrey[100],
        margin: const EdgeInsets.fromLTRB(21, 5, 16, 5),
        child: GestureDetector(
          onLongPress: () {
            showDialog(context: context, builder: (context) => prefixEditor());
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              prefixSegment,
              dividerSegment,
              const SizedBox(
                width: 10,
              ),
              fileNumSegment,
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> editFileNum(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        String value = widget.snapshot.data.toString();
        return AlertDialog(
          title: const Text('编辑录音编号（不需要输入0）'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (newValue) {
              value = newValue;
            },
            onSubmitted: (newValue) {
              value = newValue;
              var newNum = int.parse(newValue);
              widget.num.setValue(newNum);
              Provider.of<SlateStatusNotifier>(context, listen: false)
                  .setIndex(count: newNum);
              Navigator.of(context).pop();
            },
            controller: TextEditingController(text: value),
          ),
        );
      },
    );
  }

  Future<dynamic> editNameDivider(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        String value = widget.num.intervalSymbol;
        return AlertDialog(
          title: const Text('Edit Divider'),
          content: TextField(
            onChanged: (newValue) {
              value = newValue;
            },
            onSubmitted: (newValue) {
              setState(() {
                widget.num.intervalSymbol = newValue;
              });
              Provider.of<SlateStatusNotifier>(context, listen: false)
                  .setRecordLinker(newValue);
              Navigator.of(context).pop();
            },
            controller: TextEditingController(text: value),
          ),
        );
      },
    );
  }

  Widget prefixEditor() {
    String value = widget.num.prefix;
    var editCon = TextEditingController(text: value);
    var prefixEditField = TextField(
      onSubmitted: (newValue) {
        setState(() {
          widget.num.customPrefix = newValue;
        });
        Provider.of<SlateStatusNotifier>(context, listen: false)
            .setCustomPrefix(newValue);
        Navigator.of(context).pop();
      },
      controller: editCon,
    );
    return AlertDialog(
      title: const Text('请选择前缀形式'),
      content: SizedBox(
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ToggleButtons(
                isSelected: [
                  recorder.type == RecorderType.defaultRecorder,
                  recorder.type == RecorderType.soundDevices,
                  recorder.type == RecorderType.custom,
                ],
                onPressed: (int index) {
                  switch (index) {
                    case 0:
                      recorder.type = RecorderType.defaultRecorder;
                      break;
                    case 1:
                      recorder.type = RecorderType.soundDevices;
                      break;
                    case 2:
                      recorder.type = RecorderType.custom;
                      break;
                  }
                  widget.num.recorderType = getRecorderTypeText(recorder.type);
                  Provider.of<SlateStatusNotifier>(context, listen: false)
                      .setPrefixType(widget.num.recorderType);
                  setState(() {
                    editCon.text = widget.num.prefix;
                  });
                },
                children: const [
                  Text("Date"),
                  Text("Sound Devices"),
                  Text("Custom")
                ]),
            prefixEditField,
          ],
        ),
      ),
    );
  }
}
