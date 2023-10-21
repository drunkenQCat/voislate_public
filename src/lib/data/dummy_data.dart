import '../models/slate_schedule.dart';
import '../models/slate_log_item.dart';
// the default data for the scene schedule
ScheduleItem sceneInfo1A = ScheduleItem(
  '1',
  'A',
  Note(
    objects: ['缪尔赛斯', '塞雷娅', '克里斯滕'],
    type: '万星园',
    append: '三人会面，缪尔赛斯提出了她的计划，塞雷娅和克里斯滕都表示了支持。',
  ),
);

ScheduleItem shotInfo1A = ScheduleItem(
  '1',
  'A',
  Note(
    objects: ['缪尔赛斯', '塞雷娅'],
    type: '近景',
    append: '小插曲',
  ),
);

ScheduleItem shotInfo2B = ScheduleItem(
  '2',
  'B',
  Note(
    objects: ['克里斯滕', '塞雷娅'],
    type: '特写',
    append: '两人对峙',
  ),
);

ScheduleItem shotInfo3C = ScheduleItem(
  '3',
  'C',
  Note(
    objects: ['缪尔赛斯', '塞雷娅'],
    type: '中景',
    append: '缪尔赛斯向塞雷娅介绍生态园',
  ),
);

ScheduleItem sceneInfo2A = ScheduleItem(
  '2',
  'A',
  Note(
    objects: ['Dr', '凯尔希', '迷迭香'],
    type: '洛肯实验室',
    append: '三人准备准备会面洛肯',
  ),
);

ScheduleItem twoAshotInfo1A = ScheduleItem(
  '1',
  'A',
  Note(
    objects: ['缪尔赛斯', '塞雷娅'],
    type: '近景',
    append: '小插曲',
  ),
);

ScheduleItem twoAshotInfo2B = ScheduleItem(
  '2',
  'B',
  Note(
    objects: ['克里斯滕', '塞雷娅'],
    type: '特写',
    append: '两人对峙',
  ),
);

ScheduleItem twoAshotInfo3C = ScheduleItem(
  '3',
  'C',
  Note(
    objects: ['缪尔赛斯', '塞雷娅'],
    type: '中景',
    append: '缪尔赛斯向塞雷娅介绍生态园',
  ),
);

SceneSchedule sceneSchedule = SceneSchedule(
  [shotInfo1A, shotInfo2B, shotInfo3C],
  sceneInfo1A,
);
SceneSchedule scene2ASchedule = SceneSchedule(
  [twoAshotInfo1A, twoAshotInfo2B, twoAshotInfo3C],
  sceneInfo2A,
);


List<SlateLogItem> slateLogItems = [
  SlateLogItem(
    scn: 'Scene 1',
    sht: 'Shot 1',
    tk: 1,
    filenamePrefix: '230522',
    filenameLinker: '-T',
    filenameNum: 1,
    tkNote: 'TK Note 1',
    shtNote: 'Shot Note 1',
    scnNote: 'Scene Note 1',
    currentOkTk: TkStatus.ok,
    currentOkSht: ShtStatus.ok,
  ),
  SlateLogItem(
    scn: 'Scene 1',
    sht: 'Shot 1',
    tk: 2,
    filenamePrefix: '230522',
    filenameLinker: '-T',
    filenameNum: 2,
    tkNote: 'TK Note 2',
    shtNote: 'Shot Note 2',
    scnNote: 'Scene Note 2',
    currentOkTk: TkStatus.ok,
    currentOkSht: ShtStatus.ok,
  ),
  SlateLogItem(
    scn: 'Scene 1',
    sht: 'Shot 1',
    tk: 3,
    filenamePrefix: '230522',
    filenameLinker: '-T',
    filenameNum: 3,
    tkNote: 'TK Note 3',
    shtNote: 'Shot Note 3',
    scnNote: 'Scene Note 3',
    currentOkTk: TkStatus.ok,
    currentOkSht: ShtStatus.ok,
  ),
  SlateLogItem(
    scn: 'Scene 1',
    sht: 'Shot 2',
    tk: 4,
    filenamePrefix: '230522',
    filenameLinker: '-T',
    filenameNum: 4,
    tkNote: 'TK Note 4',
    shtNote: 'Shot Note 4',
    scnNote: 'Scene Note 4',
    currentOkTk: TkStatus.ok,
    currentOkSht: ShtStatus.ok,
  ),
  SlateLogItem(
    scn: 'Scene 1',
    sht: 'Shot 2',
    tk: 5,
    filenamePrefix: '230522',
    filenameLinker: '-T',
    filenameNum: 5,
    tkNote: 'TK Note 5',
    shtNote: 'Shot Note 5',
    scnNote: 'Scene Note 5',
    currentOkTk: TkStatus.ok,
    currentOkSht: ShtStatus.ok,
  ),
  // Scene 2 Shot2
  SlateLogItem(
    scn: 'Scene 2',
    sht: 'Shot 2',
    tk: 2,
    filenamePrefix: '230522',
    filenameLinker: '-T',
    filenameNum: 2,
    tkNote: 'TK Note 2',
    shtNote: 'Shot Note 2',
    scnNote: 'Scene Note 2',
    currentOkTk: TkStatus.bad,
    currentOkSht: ShtStatus.nice,
  ),
  SlateLogItem(
    scn: 'Scene 2',
    sht: 'Shot 2',
    tk: 3,
    filenamePrefix: '230522',
    filenameLinker: '-T',
    filenameNum: 3,
    tkNote: 'TK Note 3',
    shtNote: 'Shot Note 3',
    scnNote: 'Scene Note 3',
    currentOkTk: TkStatus.bad,
    currentOkSht: ShtStatus.nice,
  ),
  SlateLogItem(
    scn: 'Scene 2',
    sht: 'Shot 2',
    tk: 4,
    filenamePrefix: '230522',
    filenameLinker: '-T',
    filenameNum: 4,
    tkNote: 'TK Note 4',
    shtNote: 'Shot Note 4',
    scnNote: 'Scene Note 4',
    currentOkTk: TkStatus.bad,
    currentOkSht: ShtStatus.nice,
  ),
  SlateLogItem(
    scn: 'Scene 2',
    sht: 'Shot 1',
    tk: 3,
    filenamePrefix: 'Prefix 3',
    filenameLinker: 'Linker 3',
    filenameNum: 3,
    tkNote: 'TK Note 3',
    shtNote: 'Shot Note 3',
    scnNote: 'Scene Note 3',
    currentOkTk: TkStatus.notChecked,
    currentOkSht: ShtStatus.ok,
  ),
];