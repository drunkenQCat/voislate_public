import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:voislate/pages/slate_log_tabs.dart';
// import 'package:voislate/pages/voice_recg_test.dart';
import 'package:voislate/providers/slate_log_notifier.dart';
import 'package:voislate/pages/scene_schedule_page.dart';
import 'package:voislate/pages/record_page.dart';
import 'package:voislate/pages/settings_configue_page.dart';
import 'package:voislate/pages/scene_schedule_page_test.dart';
import 'package:voislate/providers/slate_status_notifier.dart';

class VoiSlate extends StatelessWidget {
  const VoiSlate({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SlateStatusNotifier()),
        ChangeNotifierProvider(create: (_) => SlateLogNotifier()),
      ],
      child: MaterialApp(
        title: 'Voislate',
        theme: FlexThemeData.light(
          scheme: FlexScheme.bahamaBlue,
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Voislate Home Page'),
        builder: EasyLoading.init(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({Key? key, this.title = "VoiSlate"}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _tabController = TabController(vsync: this, length: 4, initialIndex: 1);
    } else {
      _tabController = TabController(vsync: this, length: 3, initialIndex: 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VoiSlate'),
        toolbarHeight: 40,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsConfiguePage()),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabController.index,
        onTap: (index) {
          setState(() {
            _tabController.index = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_calendar_outlined),
            label: '计划',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.record_voice_over_outlined),
            label: '记录',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted_outlined),
            label: '场记',
          ),
          if (kDebugMode)
            BottomNavigationBarItem(
              icon: Icon(Icons.mic_outlined),
              label: '识别测试',
            ),
        ],
      ),
      body: DoubleBackToCloseApp(
        snackBar: const SnackBar(content: Text("再按一次退出")),
        child: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            SceneSchedulePage(),
            SlateRecord(),
            SlateLogTabs(),
            // const SlateLogList()
            if (kDebugMode) SceneSchedulePageTest(),
          ],
        ),
      ),
    );
  }
}
