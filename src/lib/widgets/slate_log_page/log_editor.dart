import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import 'package:voislate/helper/mic_objects_extractor.dart';
import 'package:voislate/widgets/scene_schedule_page/tag_chips.dart';
import '../../models/slate_log_item.dart';

class LogEditor extends StatefulWidget {
  final BuildContext context;
  final Box logsBox;
  final List<SlateLogItem> logItems;
  final int index;

  const LogEditor({
    super.key,
    required this.context,
    required this.logItems,
    required this.index,
    required this.logsBox,
  });

  @override
  // ignore: library_private_types_in_public_api
  _LogEditorState createState() => _LogEditorState();
}

class _LogEditorState extends State<LogEditor> {
  late List<SlateLogItem> _logs;
  late Box _logsBox;
  late int _index;
  late String _scn;
  late String _sht;
  late int _tkNum;
  late String _filenamePrefix;
  late String _filenameLinker;
  late int _filenameNum;
  late TextEditingController _tkNoteController;
  late TextEditingController _shtNoteController;
  late TextEditingController _scnNoteController;
  late TkStatus _okTk;
  late ShtStatus _okSht;
  late TextStyle? textStyle;
  late TextStyle fixedWordsStyle;
  late TextStyle selectableWordsStyle;
  late List<String> trackList;
  @override
  void initState() {
    super.initState();
    _logsBox = widget.logsBox;
    _logs = widget.logItems;
    _index = widget.index;
    _scn = _logs[_index].scn;
    _sht = _logs[_index].sht;
    _tkNum = _logs[_index].tk;
    _filenamePrefix = _logs[_index].filenamePrefix;
    _filenameLinker = _logs[_index].filenameLinker;
    _filenameNum = _logs[_index].filenameNum;
    _tkNoteController = TextEditingController(text: _logs[_index].tkNote);
    var extractedShtNote = MicObjectsExtractor().extract(_logs[_index]);
    _shtNoteController = TextEditingController(text: extractedShtNote.item1);
    trackList = extractedShtNote.item2;
    _scnNoteController = TextEditingController(text: _logs[_index].scnNote);
    _okTk = _logs[_index].okTk;
    _okSht = _logs[_index].okSht;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    textStyle = Theme.of(context).textTheme.titleLarge;
    fixedWordsStyle = TextStyle(
      shadows: const [Shadow(color: Colors.black12, offset: Offset(2, 4))],
      fontSize: textStyle!.fontSize,
      fontWeight: FontWeight.normal,
      color: Colors.black54,
    );
    selectableWordsStyle = TextStyle(
      fontSize: textStyle!.fontSize,
      fontWeight: FontWeight.normal,
      color: Colors.blue[400],
    );
  }

  @override
  void dispose() {
    _tkNoteController.dispose();
    _shtNoteController.dispose();
    _scnNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Slate Log Item'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              fileNumPicker(),
              tkNumPicker(),
              TextField(
                controller: _tkNoteController,
                decoration: const InputDecoration(
                  labelText: '录音描述',
                ),
              ),
              TextField(
                controller: _shtNoteController,
                decoration: const InputDecoration(
                  labelText: '镜头标注',
                ),
              ),
              TagChips(context: context, tagList: trackList),
              TextField(
                controller: _scnNoteController,
                decoration: const InputDecoration(
                  labelText: '本场信息',
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    tkStatusPicker(),
                    const VerticalDivider(
                        indent: 10, endIndent: 2, color: Colors.grey),
                    shtStatusPicker(),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  saveChanges();
                },
                child: const Text('Save'),
              ),
              ElevatedButton(
                onPressed: () {
                  deleteItem(_index);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget fileNumPicker() {
    var fileNumList = List.generate(500, (index) => index + 1);
    List<int> originalNumList =
        _logs.map((logItem) => logItem.filenameNum).toList();
    // find the nums that probably make duplicate num
    fileNumList =
        fileNumList.toSet().difference(originalNumList.toSet()).toList();
    fileNumList.insert(0, _filenameNum);
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        '$_filenamePrefix $_filenameLinker  ',
        style: fixedWordsStyle,
      ),
      DropdownButton<int>(
        value: _filenameNum,
        onChanged: (value) {
          setState(() {
            _filenameNum = value!;
          });
        },
        items: fileNumList.map((number) {
          return DropdownMenuItem<int>(
            value: number,
            child: Text(
              number.toString(),
              style: selectableWordsStyle,
            ),
          );
        }).toList(),
      ),
    ]);
  }

  Row shtStatusPicker() {
    return Row(
      children: [
        const Icon(
          Icons.movie,
          color: Colors.blue,
        ),
        const Text('镜头评价'),
        const SizedBox(
          width: 4,
        ),
        DropdownButton<ShtStatus>(
          value: _okSht,
          onChanged: (value) {
            setState(() {
              _okSht = value!;
            });
          },
          items: ShtStatus.values.map((status) {
            var noPending = const Row(
              children: [
                Icon(
                  Icons.videocam,
                  color: Colors.grey,
                ),
                Text('无')
              ],
            );
            var goodPending = const Row(
              children: [
                Icon(
                  Icons.movie_filter,
                  color: Colors.blue,
                ),
                Text('保')
              ],
            );
            var nicePending = const Row(
              children: [
                Icon(
                  Icons.thumb_up_alt_outlined,
                  color: Colors.green,
                ),
                Text('过')
              ],
            );
            return DropdownMenuItem<ShtStatus>(
              value: status,
              child: status == ShtStatus.notChecked
                  ? noPending
                  : status == ShtStatus.ok
                      ? goodPending
                      : nicePending,
            );
          }).toList(),
        ),
      ],
    );
  }

  Row tkStatusPicker() {
    return Row(
      children: [
        const Icon(
          Icons.radio_button_checked,
          color: Colors.red,
        ),
        const Text('录音评价'),
        const SizedBox(
          width: 4,
        ),
        DropdownButton<TkStatus>(
          value: _okTk,
          onChanged: (value) {
            setState(() {
              _okTk = value!;
            });
          },
          items: TkStatus.values.map((status) {
            var noPending = const Row(
              children: [
                Icon(
                  Icons.headphones,
                  color: Colors.grey,
                ),
                Text('无')
              ],
            );
            var nicePending = const Row(
              children: [
                Icon(
                  Icons.gpp_good,
                  color: Colors.green,
                ),
                Text('过')
              ],
            );
            var badPending = const Row(
              children: [
                Icon(
                  Icons.hearing_disabled,
                  color: Colors.red,
                ),
                Text('弃')
              ],
            );
            return DropdownMenuItem<TkStatus>(
              value: status,
              child: status == TkStatus.notChecked
                  ? noPending
                  : status == TkStatus.ok
                      ? nicePending
                      : badPending,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget tkNumPicker() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      // TODO: 修改场镜的功能
      Row(children: [
        Text(_scn, style: fixedWordsStyle),
        Text('场', style: textStyle),
        const SizedBox(
          width: 10,
        ),
        Text(_sht, style: fixedWordsStyle),
        Text('镜', style: textStyle),
      ]),
      const SizedBox(
        width: 10,
      ),
      DropdownButton<int>(
        value: _tkNum,
        onChanged: (value) {
          setState(() {
            _tkNum = value!;
          });
        },
        items: List.generate(500, (index) => index + 1).map((number) {
          return DropdownMenuItem<int>(
            value: number,
            child: Text(
              number.toString(),
              style: selectableWordsStyle,
              textAlign: TextAlign.center,
            ),
          );
        }).toList(),
      ),
      Text('次', style: textStyle),
    ]);
  }

  void saveChanges() {
    // Save changes to the SlateLogItem object
    _logs[_index].tk = _tkNum;
    _logs[_index].filenameNum = _filenameNum;
    _logs[_index].tkNote = _tkNoteController.text;
    var trackListText = trackList.map((obj) => "<$obj/>").join();
    _logs[_index].shtNote = _shtNoteController.text + trackListText;
    _logs[_index].scnNote = _scnNoteController.text;
    _logs[_index].okTk = _okTk;
    _logs[_index].okSht = _okSht;
    _logsBox.putAt(_index, _logs[_index]);
    Navigator.of(context).pop();
  }

  void deleteItem(int index) {
    _logs.removeAt(index);
    _logsBox.deleteAt(index);
    Navigator.of(context).pop();
  }
}

class TestSlateLogList extends StatefulWidget {
  const TestSlateLogList({Key? key}) : super(key: key);

  @override
  State<TestSlateLogList> createState() => _TestSlateLogListState();
}

class _TestSlateLogListState extends State<TestSlateLogList> {
  final String boxName = 'test';

  @override
  Widget build(BuildContext context) {
    final logsBox = Hive.box<SlateLogItem>(boxName);
    List<SlateLogItem> logItemList = logsBox.values.toList();

    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        Row(
          children: [
            Flexible(
              child: ListView.builder(
                itemCount: logItemList.length,
                itemBuilder: (context, index) {
                  final log = logItemList[index];
                  return ListTile(
                    title: Text(log.fileName),
                    subtitle: Text(log.tkNote),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LogEditor(
                            context: context,
                            logItems: logItemList,
                            logsBox: logsBox,
                            index: index,
                          ),
                        ),
                      ).then((value) => setState(
                            () => {},
                          ));
                    },
                  );
                },
              ),
            ),
            Flexible(
              child: ListView.builder(
                itemCount: logsBox.length,
                itemBuilder: (context, index) {
                  final log = logsBox.getAt(index);
                  return ListTile(
                    title: Text(log!.fileName),
                    subtitle: Text(log.tkNote),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LogEditor(
                            context: context,
                            logItems: logItemList,
                            logsBox: logsBox,
                            index: index,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () {
            var json = JsonMapper.serialize(logItemList);
            Share.share(json);
            // Share.shareXFiles(['${directory.path}/image.jpg'], text: 'Great picture');
            // showDialog(
            //   context: context,
            //   builder: (BuildContext context) {
            //     return AlertDialog(
            //       title: const Text('JSON'),
            //       content: SingleChildScrollView(child: Text(json)),
            //       actions: [
            //         TextButton(
            //           onPressed: () {
            //             Navigator.of(context).pop();
            //           },
            //           child: const Text('Close'),
            //         ),
            //         TextButton(
            //           onPressed: () {
            //             var _ =JsonMapper.deserialize<List<SlateLogItem>>(json);
            //             print(_![0].fileName);
            //           },
            //           child: const Text('DeSe'),
            //         ),
            //       ],
            //     );
            //   },
            // );
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
  }
}
