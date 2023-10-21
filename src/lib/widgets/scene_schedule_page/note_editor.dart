import 'package:flutter/material.dart';
import 'package:voislate/widgets/scene_schedule_page/tag_chips.dart';
import '../../models/slate_schedule.dart';

class NoteEditor extends StatefulWidget {
  final BuildContext context;
  final List<SceneSchedule> scenes;
  final int scnIndex;
  final int? shotIndex;
  final bool? isJustOneButton;

  const NoteEditor({
    super.key,
    required this.context,
    required this.scenes,
    required this.scnIndex,
    this.shotIndex,
    this.isJustOneButton,
  });

  @override
  // ignore: library_private_types_in_public_api
  _NoteEditorState createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late bool isScene;
  late Note note;
  late String editedKey;
  late String editedFix;
  late List<String> fixs;
  late List<String> editedObjects;
  late String editedType;
  late String editedAppend;
  late TextEditingController typeControlller;
  late TextEditingController appendControlller;

  late int? scnIndex;

  late String typeText;
  late String appendText;

  @override
  void initState() {
    super.initState();
    isScene = widget.shotIndex == null;
    note = (isScene)
        ? widget.scenes[widget.scnIndex].info.note
        : widget.scenes[widget.scnIndex][widget.shotIndex!].note;
    editedKey = (isScene)
        ? widget.scenes[widget.scnIndex].info.key
        : widget.scenes[widget.scnIndex][widget.shotIndex!].key;
    editedFix = (isScene)
        ? widget.scenes[widget.scnIndex].info.fix
        : widget.scenes[widget.scnIndex][widget.shotIndex!].fix;
    fixs = List.generate(26, (index) => String.fromCharCode(index + 65));
    fixs = [''] + fixs;
    editedObjects = List.from(note.objects);
    editedType = note.type;
    editedAppend = note.append;
    typeControlller = TextEditingController(text: editedType);
    typeControlller.selection = TextSelection.fromPosition(
        TextPosition(offset: typeControlller.text.length));
    appendControlller = TextEditingController(text: editedAppend);
    appendControlller.selection = TextSelection.fromPosition(
        TextPosition(offset: appendControlller.text.length));
    typeText = isScene ? '场地:' : '镜头类型:';
    appendText = isScene ? '概要' : '内容';
    scnIndex = widget.scnIndex;
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CustomScrollView(
              scrollDirection: Axis.vertical,
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 1.7,
                    padding: const EdgeInsets.all(16.0),
                    child: contentEditor(setState, context),
                  ),
                )
              ],
            ),
            Positioned(
              bottom: 10,
              child: confirmButtons(),
            ),
          ],
        );
      },
    );
  }

  Column contentEditor(StateSetter setState, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          height: 3,
        ),
        // The title
        Text(
          '${isScene ? '场次' : '镜头'}信息修改',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16.0),
        keyFixPicker(setState),
        const SizedBox(height: 16.0),
        objectsTagEditor(context),
        const SizedBox(height: 16.0),
        typeEditor(context),
        const SizedBox(height: 16.0),
        appendEditor(context),
      ],
    );
  }

  Row confirmButtons() {
    var newNote =
        Note(objects: editedObjects, type: editedType, append: editedAppend);
    var newInfo = ScheduleItem(editedKey, editedFix, newNote);
    ScheduleUtils util = ScheduleUtils(
      scenes: widget.scenes,
      currentScnIndex: widget.scnIndex,
      currentShtIndex: widget.shotIndex,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        (widget.isJustOneButton == null || widget.isJustOneButton == false)
            ? ElevatedButton(
                onPressed: () {
                  util.addItem(newInfo, false);
                  Navigator.of(context).pop();
                },
                child: const Row(
                  children: [
                    Icon(Icons.arrow_upward),
                    Text('向前添加'),
                  ],
                ),
              )
            : const SizedBox(),
        ElevatedButton(
          onPressed: () {
            util.saveChanges(newInfo);
            Navigator.of(context).pop();
          },
          child: const Text('保存'),
        ),
        (widget.isJustOneButton == null || widget.isJustOneButton == false)
            ? ElevatedButton(
                onPressed: () {
                  util.addItem(newInfo, true);
                  Navigator.of(context).pop();
                },
                child: const Row(
                  children: [
                    Text('向后添加'),
                    Icon(Icons.arrow_downward),
                  ],
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  Column appendEditor(BuildContext context) {
    return Column(
      children: [
        Text(
          appendText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        TextField(
          scrollPadding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          onChanged: (value) => editedAppend = value,
          controller: appendControlller,
        ),
      ],
    );
  }

  Column typeEditor(BuildContext context) {
    return Column(
      children: [
        Text(
          typeText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        if (isScene)
          TextField(
            // 输入框自动滚动解决方案
            scrollPadding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20),
            onChanged: (value) => editedType = value,
            controller: typeControlller,
          )
        else
          ToggleButtons(
            isSelected: [
              editedType == '特写',
              editedType == '近景',
              editedType == '中景',
              editedType == '全景',
              editedType == '远景',
            ],
            onPressed: (index) {
              setState(() {
                switch (index) {
                  case 0:
                    editedType = '特写';
                    break;
                  case 1:
                    editedType = '近景';
                    break;
                  case 2:
                    editedType = '中景';
                    break;
                  case 3:
                    editedType = '全景';
                    break;
                  case 4:
                    editedType = '远景';
                    break;
                }
              });
            },
            children: const [
              Text('特写'),
              Text('近景'),
              Text('中景'),
              Text('全景'),
              Text('远景'),
            ],
          ),
      ],
    );
  }

  Column objectsTagEditor(BuildContext context) {
    return Column(
      children: [
        const Text(
          '录音轨道:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TagChips(tagList: editedObjects, context: context)
      ],
    );
  }

  Row keyFixPicker(StateSetter setState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<String>(
          value: editedKey,
          onChanged: (String? newValue) {
            setState(() {
              editedKey = newValue!;
            });
          },
          items: List.generate(200, (index) => (index + 1).toString())
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        const SizedBox(
          width: 5,
        ),
        DropdownButton<String>(
          value: editedFix,
          onChanged: (String? newValue) {
            setState(() {
              editedFix = newValue!;
            });
          },
          items: fixs.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        Text(isScene ? '场' : '镜')
      ],
    );
  }
}

class ScheduleUtils {
  final List<SceneSchedule> scenes;
  final int currentScnIndex;
  final int? currentShtIndex;
  late bool isScene;

  ScheduleUtils({
    required this.scenes,
    required this.currentScnIndex,
    this.currentShtIndex,
  }) {
    isScene = currentShtIndex == null;
  }

  void _dupSceneDetect(SceneSchedule newScene) {
    var detectorList = scenes.map((scene) => scene.info.name).toList();
    for (var name in detectorList) {
      if (newScene.info.name == name) {
        throw DuplicateItemException('本场号已存在');
      }
    }
  }

  void _dupShotDetect(ScheduleItem newShot) {
    var detectorList =
        scenes[currentScnIndex].data.map((shot) => shot.name).toList();
    for (var name in detectorList) {
      if (newShot.name == name) {
        throw DuplicateItemException('本镜号已存在');
      }
    }
  }

  String _findFix(List<String> alphas, bool after) {
    if (after) return '';
    if (alphas == ['']) return 'A';
    alphas =
        alphas.where((element) => element.contains(RegExp(r'[A-Z]'))).toList();
    alphas.sort();
    if (alphas.isEmpty) return '';
    String someLetterMax = alphas.last;
    if (someLetterMax == 'Z') {
      int maxGap = 0;
      for (int i = 0; i < alphas.length - 1; i++) {
        int gap = alphas[i + 1].codeUnitAt(0) - alphas[i].codeUnitAt(0);
        if (gap > maxGap) {
          maxGap = gap;
          someLetterMax = alphas[i];
        }
      }
    }
    int nextLetter = someLetterMax.codeUnitAt(0) + 1;
    return String.fromCharCode(nextLetter);
  }

  String _findKey(List<int> keys, int index, bool after) {
    keys.sort();
    int maxKey = keys.last;
    if (!after) {
      int minKey = keys.first;
      return (minKey - 1).toString();
    }
    return (maxKey + 1).toString();
  }

  void saveChanges(ScheduleItem newInfo) {
    if (isScene) {
      scenes[currentScnIndex].info = newInfo;
    } else {
      scenes[currentScnIndex].data[currentShtIndex!] = newInfo;
    }
  }

  void addItem(ScheduleItem inputInfo, bool after) {
    var newObjects = inputInfo.note.objects;
    var newNote = "从${newObjects.join('，')}的【正面】拍【近景】";
    var newShot = ScheduleItem(
        '1', '', Note(objects: newObjects, type: '近景', append: newNote));
    var newInfo = ScheduleItem(inputInfo.key, inputInfo.fix, inputInfo.note);
    var plusIndex = after ? 1 : 0;

    if (isScene) {
      var newScene = SceneSchedule([newShot], newInfo);
      try {
        _dupSceneDetect(newScene);
      } on DuplicateItemException {
        List<int> keys =
            scenes.map((scene) => int.tryParse(scene.info.key) ?? 0).toList();
        newInfo.key = _findKey(keys, currentScnIndex, after);
        List<String> fixs = scenes
            .where((scene) => scene.info.key == newInfo.key)
            .map((scene) => scene.info.fix)
            .toList();
        newInfo.fix = _findFix(fixs, after);
        newScene.info = newInfo;
      }
      (currentScnIndex == scenes.length - 1 && after)
          ? scenes.add(newScene)
          : scenes.insert(currentScnIndex + plusIndex, newScene);
    } else {
      try {
        _dupShotDetect(newInfo);
      } on Exception catch (e) {
        debugPrint(e.toString());
        List<int> keys = scenes[currentScnIndex]
            .data
            .map((shot) => int.tryParse(shot.key) ?? 0)
            .toList();
        newInfo.key = _findKey(keys, currentScnIndex, after);
        List<String> fixs = scenes[currentScnIndex]
            .data
            .where((shot) => shot.key == newInfo.key)
            .map((shot) => shot.fix)
            .toList();
        newInfo.fix = _findFix(fixs, after);
      }
      (currentScnIndex == scenes.length - 1 && after)
          ? scenes[currentScnIndex].add(newInfo)
          : scenes[currentScnIndex]
              .insert(currentShtIndex! + plusIndex, newInfo);
    }
  }

  void addNewShotAtLast() {
    var currentShot = scenes[currentScnIndex].data.last;
    var newInfo =
        ScheduleItem(currentShot.key, currentShot.fix, currentShot.note);
    List<int> keys = scenes[currentScnIndex]
        .data
        .map((shot) => int.tryParse(shot.key) ?? 0)
        .toList();
    newInfo.key = _findKey(keys, currentScnIndex, true);
    List<String> fixs = scenes[currentScnIndex]
        .data
        .where((shot) => shot.key == newInfo.key)
        .map((shot) => shot.fix)
        .toList();
    newInfo.fix = _findFix(fixs, true);
    scenes[currentScnIndex].add(newInfo);
  }

  void addNewSceneAtLast() {
    var currentScene = scenes[currentScnIndex];
    var newInfo = ScheduleItem(
        currentScene.info.key, currentScene.info.fix, currentScene.info.note);
    List<int> keys =
        scenes.map((scn) => int.tryParse(scn.info.key) ?? 0).toList();
    newInfo.key = _findKey(keys, currentScnIndex, true);
    List<String> fixes = scenes
        .where((scn) => scn.info.key == newInfo.key)
        .map((scn) => scn.info.fix)
        .toList();
    newInfo.fix = _findFix(fixes, true);
    var newShot = ScheduleItem(
        '1', '', Note(objects: newInfo.note.objects, type: '近景', append: ''));
    var newScn = SceneSchedule([newShot], newInfo);
    scenes.add(newScn);
  }
}
