import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_android_volume_keydown/flutter_android_volume_keydown.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:voislate/models/slate_log_item.dart';
import 'package:voislate/models/slate_schedule.dart';
import 'package:voislate/models/tk_pending.dart';
import 'package:voislate/models/take_type.dart';
import 'package:voislate/providers/slate_log_notifier.dart';
import 'package:voislate/widgets/scene_schedule_page/note_editor.dart';

import '../models/recorder_file_num.dart';
import '../providers/slate_picker_notifier.dart';
import '../providers/slate_status_notifier.dart';
import '../providers/value_scroll_control.dart';
import '../widgets/record_page/file_counter.dart';
import '../widgets/record_page/prev_note_editor.dart';
import '../widgets/record_page/quick_view_log_dialog.dart';
import '../widgets/record_page/recorder_joystick.dart';
import '../widgets/record_page/shot_ok_dial.dart';
import '../widgets/record_page/slate_picker.dart';
import '../widgets/record_page/take_ok_dial.dart';
import '../widgets/record_page/current_file_monitor.dart';
import '../widgets/record_page/current_take_monitor.dart';

class SlateRecord extends StatefulWidget {
  const SlateRecord({super.key});

  @override
  State<SlateRecord> createState() => _SlateRecordState();
}

class _SlateRecordState extends State<SlateRecord> with WidgetsBindingObserver {
  // Some variables don't need to be in the state

  late Timer _backupTimer;
  late List<SceneSchedule> totalScenes;
  // the indicator of wildtrack
  late bool isLinked;
  final int _counterInit = 1;
  // about the logs
  late TextEditingController shotNoteController;
  late TextEditingController descController;
  // about the slate picker
  var titles = ['Scene', 'Shot', 'Take'];
  final sceneCol = SlateColumnOne();
  final shotCol = SlateColumnTwo();
  final takeCol = SlateColumnThree();
  final fileNum = RecordFileNum();
  // controller for volume key
  late ScrollValueController<SlateColumnThree> scrl3;
  bool _isAbsorbing = false;

  bool _canVibrate = true;

  /// 0: not checked, 1: ok, 2: not ok
  var tkPending = TkPending()
    ..tk = TkStatus.notChecked
    ..sht = ShtStatus.notChecked;

  bool shotChanged = false;

  StreamSubscription<HardwareButton>? subscription;
  late SlateStatusNotifier initValueProvider;

  bool isNextTileNotExpanded = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _initVibrate();
    startListening();
    var box = Hive.box('scenes_box');
    totalScenes = box.values.toList().cast();

    initValueProvider =
        Provider.of<SlateStatusNotifier>(context, listen: false);
    var sceneList = totalScenes.map((e) => e.info.name.toString()).toList();
    var shotList = totalScenes[initValueProvider.selectedSceneIndex]
        .data
        .map((e) => e.name.toString())
        .toList();
    var takeList = List.generate(200, (index) => (index + 1).toString());
    isLinked = initValueProvider.isLinked;
    tkPending.tk = initValueProvider.okTk;
    tkPending.sht = initValueProvider.okSht;
    sceneCol.init(0, sceneList);
    shotCol.init(0, shotList);
    takeCol.init(0, takeList);
    String initDesc = initValueProvider.currentDesc;
    String initNote = initValueProvider.currentNote;
    descController = TextEditingController(text: initDesc);
    shotNoteController = TextEditingController(text: initNote);
    initPickerAndFileNumWidget();
    _backupTimer = Timer.periodic(
        const Duration(minutes: 3), (Timer timer) => backupSlateLogs());
  }

  void initPickerAndFileNumWidget() {
    WidgetsBinding.instance.endOfFrame.then((_) {
      var initS = initValueProvider.selectedSceneIndex;
      var initSh = initValueProvider.selectedShotIndex;
      var initTk = initValueProvider.selectedTakeIndex;
      var initCount = initValueProvider.recordCount;
      var initRecordLinker = initValueProvider.recordLinker;
      var initPrefixType = initValueProvider.prefixType;
      var initCustomPrefix = initValueProvider.customPrefix;
      sceneCol.init(initS);
      shotCol.init(initSh);
      takeCol.init(initTk);
      fileNum.setValue(initCount);
      fileNum.intervalSymbol = initRecordLinker;
      fileNum.recorderType = initPrefixType;
      fileNum.customPrefix = initCustomPrefix;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var horizonPadding = 30.0;
    var pickerHistory = Hive.box('picker_history');
    // everytime setState, the build method will be called again

    return Consumer2<SlateStatusNotifier, SlateLogNotifier>(
        builder: (context, slateNotifier, logNotifier, child) {
      /// Subscribe the notes on this page
      descController
          .addListener(() => slateNotifier.setNote(desc: descController.text));
      shotNoteController.addListener(
          () => slateNotifier.setNote(note: shotNoteController.text));

      List<String> getCurrentTakeInfo() {
        if (pickerHistory.isEmpty) return ['0', '0', '0'];
        var prevTake = pickerHistory.getAt(pickerHistory.length - 1);
        List<String> prevTakeList = prevTake.cast<String>();
        return prevTakeList;
      }

      String getCurrentScn() => getCurrentTakeInfo()[0];
      String getCurrentSht() => getCurrentTakeInfo()[1];
      String getCurrentTk() => getCurrentTakeInfo()[2];
      // objs are appended to take note.
      List<String> getPrevObjs() => getCurrentTakeInfo().length > 3
          ? getCurrentTakeInfo().sublist(3)
          : [];

      void pickerNumSync() {
        setState(() {
          var shotList = totalScenes[sceneCol.selectedIndex]
              .data
              .map((e) => e.name.toString())
              .toList();
          // if the scene is changed manually
          if (sceneCol.selectedIndex != slateNotifier.selectedSceneIndex) {
            shotCol.init(0, shotList);
            takeCol.init();
            shotChanged = true;
          }
          // if the shot is changed manually
          if (shotCol.selectedIndex != slateNotifier.selectedShotIndex) {
            takeCol.init();
            shotChanged = true;
          }
          if (shotCol.selectedIndex == slateNotifier.selectedShotIndex) {
            shotChanged = false;
          }
          slateNotifier.setIndex(
            scene: sceneCol.selectedIndex,
            shot: shotCol.selectedIndex,
            take: takeCol.selectedIndex,
          );
        });
      }

      void addItem([TakeType currentTkType = TakeType.normal]) {
        // The predefined functions
        void addNewLog() {
          String currentScn = getCurrentScn();
          String currentSht = getCurrentSht();
          String currentTkSign = getCurrentTk();
          if (currentTkSign == 'OK') return;
          var isFake = currentTkSign == 'F';
          var isWild = currentTkSign == 'W';
          // obj list is the rest part of prevTake
          String trackLogs = getPrevObjs().map((obj) => "<$obj/>").join();
          // check if the shot is changed or if current take is the end take
          if (shotCol.selected != currentSht || currentTkType == TakeType.end) {
            // if shotCol changed, the status of current take
            // automatically turn to best
            setState(() {
              tkPending
                ..tk = TkStatus.ok
                ..sht = ShtStatus.nice;
            });
          }
          var newLogItem = SlateLogItem(
            scn: currentScn,
            sht: currentSht,
            tk: isFake
                ? 999
                : isWild
                    ? 0
                    : int.parse(currentTkSign),
            filenamePrefix: fileNum.prefix,
            filenameLinker: fileNum.intervalSymbol,
            filenameNum: fileNum.prevFileNum(),
            tkNote: !isFake
                ? (descController.text.isEmpty
                    ? 'S$currentScn Sh$currentSht Tk$currentTkSign'
                    : descController.text)
                : 'Fake Take',
            shtNote: "${shotNoteController.text}$trackLogs",
            scnNote: totalScenes[sceneCol.selectedIndex].info.note.append,
            currentOkTk: !isFake ? tkPending.tk : TkStatus.bad,
            currentOkSht: !isFake ? tkPending.sht : ShtStatus.notChecked,
          );
          if (isWild) {
            newLogItem.tkNote = "wild track ${newLogItem.tkNote}";
          }
          logNotifier.add(fileNum.prevFileName(), newLogItem);
        }

        String getCurrentTakeKeyWord() {
          if (currentTkType == TakeType.end) return 'OK';
          if (currentTkType == TakeType.normal) return takeCol.selected;
          if (currentTkType == TakeType.fake) return 'F';
          if (currentTkType == TakeType.wild) return 'W';
          return 'F';
        }

        void resetOkEnum() {
          setState(() {
            tkPending.tk = TkStatus.notChecked;
            tkPending.sht = ShtStatus.notChecked;
          });
          slateNotifier.setOkStatus(doReset: true);
        }

        void setDescNewText() {
          currentTkType == TakeType.fake
              ? descController.text = "这条跑了"
              : currentTkType == TakeType.end
                  ? descController.text = "收工了,这一镜结束了"
                  : descController.clear();
        }

        // Start to add items
        if (fileNum.prevFileName().isNotEmpty) {
          addNewLog();
        }
        if (!isLinked && currentTkType != TakeType.end) {
          currentTkType = TakeType.wild;
        }
        List currentTakeInfo = [
          sceneCol.selected,
          shotCol.selected,
          getCurrentTakeKeyWord()
        ];
        var objList = totalScenes[sceneCol.selectedIndex][shotCol.selectedIndex]
            .note
            .objects;
        currentTakeInfo.addAll(objList);
        pickerHistory.add(currentTakeInfo);

        setState(() {
          if (currentTkType != TakeType.end) fileNum.increment();
          resetOkEnum();
          slateNotifier.setIndex(
            count: fileNum.number,
          );
          setDescNewText();
        });
        if (_canVibrate) {
          currentTkType == TakeType.fake
              ? Vibrate.feedback(FeedbackType.error)
              : Vibrate.feedback(FeedbackType.heavy);
        }
      }

      ElevatedButton col3IncBtn = ElevatedButton(
          onPressed: () {
            addItem();
            takeCol.scrollToNext(isLinked);
            slateNotifier.setIndex(
              scene: sceneCol.selectedIndex,
              shot: shotCol.selectedIndex,
              take: takeCol.selectedIndex,
            );
          },
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(56, 58),
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF63326E)),
          child: const Icon(
            Icons.add,
          ));

      void drawBackItem() {
        Future<void> removeLastPickerHistory() =>
            pickerHistory.deleteAt(pickerHistory.length - 1);
        void drawBackNotes() {
          descController.text = logNotifier.logToday.last.tkNote;
          var lastShtNote = logNotifier.logToday.last.shtNote.split('<').first;
          shotNoteController.text = lastShtNote;
        }

        if (getCurrentTk() == "OK") {
          removeLastPickerHistory();
          return;
        }
        try {
          setState(() {
            fileNum.decrement();
          });
          slateNotifier.setIndex(count: fileNum.number);
          setState(() => drawBackNotes());
          removeLastPickerHistory();
          logNotifier.removeLast();
          // ignore: empty_catches
        } catch (e) {}
        // remove the last note
        if (_canVibrate) {
          Vibrate.feedback(FeedbackType.warning);
        }
      }

      ElevatedButton col3DecBtn = ElevatedButton(
        onPressed: () {
          Fluttertoast.showToast(msg: "长按撤回上一条场记");
        },
        onLongPress: () {
          if (getCurrentTk() != "OK") {
            takeCol.scrollToPrev(isLinked);
          }
          drawBackItem();
        },
        style: ElevatedButton.styleFrom(
          maximumSize: const Size(87, 50),
          foregroundColor: Colors.red,
        ),
        child: const Icon(Icons.remove),
      );

      Widget buildCurrentTkNoticeCard() {
        return Card(
            elevation: 4,
            color: const Color(0xFFF2F5DE),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  !isNextTileNotExpanded
                      ? CurrentTakeMonitor(
                          currentScn: getCurrentScn(),
                          currentSht: getCurrentSht(),
                          currentTk: getCurrentTk())
                      : const SizedBox(),
                  const SizedBox(height: 10),
                  CurrentFileMonitor(fileNum: fileNum)
                ],
              ),
            ));
      }

      /// initialize the controller of volumekey
      scrl3 = ScrollValueController<SlateColumnThree>(
          context: context,
          textCon: descController,
          inc: () => addItem(),
          dec: () => drawBackItem(),
          col: takeCol,
          slateNotifier: initValueProvider);

      ElevatedButton shotEndBtn = ElevatedButton(
        onPressed: () {
          List<String> prevTake = getCurrentTakeInfo();
          if (fileNum.prevFileName().isEmpty ||
              prevTake.isEmpty ||
              prevTake[2] == 'OK' ||
              prevTake[2] == 'F') return;
          addItem(TakeType.end);
          Fluttertoast.showToast(msg: "镜头结束，画面与声音默认评价为优良");
        },
        style: ElevatedButton.styleFrom(
          // minimumSize: const Size(87, 50),
          maximumSize: const Size(87, 50),
          foregroundColor: Colors.green,
          elevation: 7,
        ),
        // child: const Image(image: AssetImage('lib/assets/bookmark.png')),
        child: const Icon(Icons.save),
      );

      List<MapEntry<String, String>> exportQuickNotes() {
        var logs = logNotifier.logToday;
        var notes = logs.map((log) {
          return MapEntry(log.fileName, log.tkNote);
        }).toList();
        if (notes.length > 40) return notes.sublist(40);
        return notes;
      }

      Widget buildNextPicker() {
        return Column(
          children: [
            Text((shotChanged) ? "长按修改当前镜" : ""),
            SlatePicker(
              titles: titles,
              stateOne: sceneCol,
              stateTwo: shotCol,
              stateThree: takeCol,
              width: screenWidth - 2 * horizonPadding,
              height: screenHeight * 0.15,
              itemHeight: screenHeight * 0.13 - 48,
              resultChanged: ({v1, v2, v3}) {
                if (takeCol.selected == "2") {
                  shotNoteController.text = totalScenes[sceneCol.selectedIndex]
                          [shotCol.selectedIndex]
                      .note
                      .append;
                }
                pickerNumSync();
                debugPrint('v1: , v2: , v3: ');
              },
            ),
          ],
        );
      }

      var fileCounter = FileCounter(
        init: _counterInit,
        num: fileNum,
      );
      Widget buildNextTakeIndicator() {
        Widget buildIndicator() {
          // in normal condition, display the Picker
          if (isLinked) {
            return AbsorbPointer(
              absorbing: true,
              child: SizedBox(
                  width: 120,
                  child:
                      FittedBox(fit: BoxFit.contain, child: buildNextPicker())),
            );
          }
          // else, In Append Recording, display file counter
          return AbsorbPointer(
            absorbing: true,
            child: SizedBox(
                width: 150,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: fileCounter,
                )),
          );
        }

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.play_arrow,
                      color: Colors.blue,
                    ),
                    isLinked
                        ? const Text(
                            "NEXT",
                            style: TextStyle(color: Colors.blue),
                          )
                        : const Card(child: Text("补录")),
                    const Icon(
                      Icons.skip_next_sharp,
                      color: Colors.blue,
                    ),
                  ],
                ),
                !isNextTileNotExpanded
                    ? buildIndicator()
                    : Text(
                        "${sceneCol.selected}场${shotCol.selected}镜${takeCol.selected}次"),
                // Text(fileNum.fullName())
              ],
            ),
          ],
        );
      }

      Widget buildNextTakeScrolls() {
        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            GestureDetector(
              onTap: () {},
              onLongPress: () {
                editCurrentShot(context);
              },
              child: Card(
                  color: isLinked ? Colors.white : Colors.grey,
                  elevation: isLinked ? 3 : 0,
                  child: buildNextPicker()),
            ),
            Padding(
              padding: EdgeInsets.only(left: screenWidth / 20),
              child: const Column(
                children: [
                  Icon(
                    Icons.fast_forward_outlined,
                    color: Colors.blue,
                  ),
                  Text('下'),
                  Text('一'),
                  Text('条'),
                ],
              ),
            )
          ],
        );
      }

      var scrollCounterLinkButton = Transform.rotate(
        angle: 1.5708,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              isLinked = !isLinked;
              slateNotifier.setLink(isLinked);
              Fluttertoast.showToast(
                msg: isLinked ? '已取消补录模式' : '进入补录模式，Take号与文件号解绑',
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isLinked
                ? const Color.fromARGB(210, 255, 255, 255)
                : Colors.grey,
            elevation: 5,
          ),
          child: Icon(isLinked ? Icons.link : Icons.link_off),
        ),
      );
      Widget buildNextTakeMonitor() {
        return Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            Card(
              color: Colors.grey.shade100,
              child: Column(
                children: [
                  buildNextTakeScrolls(),
                  // add an input box to have a note about the number
                  const SizedBox(
                    height: 10,
                  ),
                  fileCounter,
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.1),
              child: scrollCounterLinkButton,
            ),
          ],
        );
      }

      var addAndSkipButtons = [
        Row(
          children: [
            Expanded(
                child:
                    AbsorbPointer(absorbing: _isAbsorbing, child: col3IncBtn))
          ],
        ),
        // A button to add Fake Take
        AbsorbPointer(
          absorbing: _isAbsorbing,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF291711),
            ),
            child: IconButton(
              onPressed: () {
                addItem(TakeType.fake);
              },
              icon: const Icon(
                Icons.move_down,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ];

      var prevTakeEditor = PrevTakeEditor(
        num: fileNum,
        descEditingController: descController,
      );
      var prevShotNote = PrevShotNote(
        currentScn: getCurrentScn(),
        currentSht: getCurrentSht(),
        currentTk: getCurrentTk(),
        controller: shotNoteController,
      );
      var inputArea = [
        AbsorbPointer(
          absorbing: _isAbsorbing,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              prevTakeEditor,
              prevShotNote,
            ],
          ),
        ).greyscale(_isAbsorbing),
        Transform.scale(
          scale: 0.8,
          child: RecorderJoystick(
            width: 120,
            sliderButtonContent: const Icon(Icons.mic),
            backgroundColor: Colors.red.shade200,
            backgroundColorEnd: Colors.green.shade200,
            foregroundColor: Colors.purple.shade50,
            onLeftEdge: () {},
            onRightEdge: () {},
            leftTextController: descController,
            rightTextController: shotNoteController,
          ),
        ),
      ];

      var bottomControlButtons = [
        DisplayNotesButton(
          notes: exportQuickNotes(),
          num: fileNum,
        ),
        TakeOkDial(
          context: context,
          pending: tkPending,
        ),
        ShotOkDial(
          context: context,
          pending: tkPending,
        ),
        AnimatedToggleSwitch.dual(
          dif: 5,
          current: _isAbsorbing,
          first: false,
          second: true,
          onChanged: (value) {
            setState(() => _isAbsorbing = value);
          },
          borderColor: _isAbsorbing ? Colors.red : Colors.grey[300],
          colorBuilder: (bool isLocked) =>
              !isLocked ? Colors.green : Colors.red,
          iconBuilder: (bool isLocked) =>
              Icon(!isLocked ? Icons.lock_open : Icons.lock),
          textBuilder: (bool isLocked) => Text(!isLocked ? '触控' : '锁定'),
        ),
      ];
      return Scaffold(
        body: CustomScrollView(
          scrollDirection: Axis.vertical,
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                // because of the Title of scaffold,
                // the width of the card is 80% of the screen height
                height:
                    isNextTileNotExpanded ? screenHeight * 1.2 : screenHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      height: 20,
                    ),
                    buildCurrentTkNoticeCard(),
                    const SizedBox(
                      height: 20,
                    ),
                    AbsorbPointer(
                      absorbing: _isAbsorbing,
                      child: ExpansionTile(
                        title: buildNextTakeIndicator(),
                        onExpansionChanged: (isExpanded) {
                          Future.delayed(const Duration(milliseconds: 230), () {
                            setState(() {
                              isNextTileNotExpanded = isExpanded;
                              initPickerAndFileNumWidget();
                            });
                          });
                        },
                        children: [
                          AbsorbPointer(
                                  absorbing: _isAbsorbing,
                                  child: buildNextTakeMonitor())
                              .greyscale(_isAbsorbing),
                        ],
                      ),
                    ).greyscale(_isAbsorbing),
                    const Divider(),
                    Stack(
                      children: addAndSkipButtons,
                    ).greyscale(_isAbsorbing),
                    const Divider(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AbsorbPointer(
                          absorbing: _isAbsorbing,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [col3DecBtn, shotEndBtn],
                          ),
                        ).greyscale(_isAbsorbing),
                        Stack(
                          alignment: AlignmentDirectional.topCenter,
                          children: inputArea,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: bottomControlButtons,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void editCurrentShot(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return NoteEditor(
            context: context,
            scenes: totalScenes,
            scnIndex: sceneCol.selectedIndex,
            shotIndex: shotCol.selectedIndex,
            isJustOneButton: true);
      },
    ).then((value) {
      var shotList = totalScenes[sceneCol.selectedIndex]
          .data
          .map((e) => e.name.toString())
          .toList();
      setState(() => shotCol.init(shotCol.selectedIndex, shotList));
      Hive.box('scenes_box')
          .putAt(sceneCol.selectedIndex, totalScenes[sceneCol.selectedIndex]);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _backupTimer.cancel();
    super.dispose();
    stopListening();
  }

  void startListening() {
    subscription = FlutterAndroidVolumeKeydown.stream.listen((event) {
      if (event == HardwareButton.volume_down) {
        scrl3.valueDec(isLinked);
      } else if (event == HardwareButton.volume_up) {
        scrl3.valueInc(isLinked);
      }
    });
  }

  void stopListening() {
    subscription?.cancel();
  }

  Future<void> _initVibrate() async {
    // init the vibration
    bool canVibrate = await Vibrate.canVibrate;
    setState(() {
      _canVibrate = canVibrate;
      _canVibrate
          ? debugPrint('This device can vibrate')
          : debugPrint('This device cannot vibrate');
    });
  }

  Future<bool> backupSlateLogs() async {
    Directory directory;
    try {
      directory = await getExternalStorageDirectory() ??
          Directory('/storage/emulated/0/Android');
      String newPath = "";
      List<String> paths = directory.path.split("/");
      for (var folder in paths) {
        if (folder != "Android") {
          newPath += "/$folder";
        } else {
          break;
        }
      }
      newPath = "$newPath/Documents/VoiSlate Logs";
      directory = Directory(newPath);
      final nowTime = DateTime.now();
      // final dateAbbr = "${nowTime.month}-${nowTime.day}-${nowTime.hour}-00";
      final dateAbbr = "${RecordFileNum.today}-${nowTime.hour}clock";

      File saveFile = File("${directory.path}/slate_backup$dateAbbr.json");
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        final json = serializeSlate();
        saveFile.writeAsString(json);
        print(directory.path);
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  String serializeSlate() {
    final slate = SlateLogNotifier();
    List<SlateLogItem> logItemList = slate.boxToday.values.toList();
    final json = JsonMapper.serialize(logItemList);
    return json;
  }
}

extension GreyScale on Widget {
  Widget greyscale(bool isUnabled) {
    return Container(
        foregroundDecoration: BoxDecoration(
          color: isUnabled
              ? const Color.fromARGB(180, 255, 255, 255)
              : const Color.fromARGB(0, 255, 255, 255),
          backgroundBlendMode: BlendMode.saturation,
        ),
        child: this);
  }
}
