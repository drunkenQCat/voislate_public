import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'slate_log_page.dart';
import 'package:voislate/providers/slate_log_notifier.dart';

class SlateLogTabs extends StatefulWidget {
  const SlateLogTabs({super.key});

  @override
  State<SlateLogTabs> createState() => _SlateLogTabsState();
}

class _SlateLogTabsState extends State<SlateLogTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<String> tabs;

  @override
  void initState() {
    super.initState();
    var logs = Provider.of<SlateLogNotifier>(context, listen: false);
    tabs = logs.dates;
    tabs = tabs.reversed.toList();
    _tabController =
        TabController(vsync: this, length: tabs.length, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (_tabController.index > 0) {
              _tabController.animateTo(_tabController.index - 1);
            } else {
              //
            }
          },
        ),
        Expanded(
          child: TabBar(
            isScrollable: true,
            controller: _tabController,
            labelStyle: const TextStyle(color: Colors.black),
            unselectedLabelColor: Colors.black,
            labelColor: Colors.blue,
            tabs: tabs
              .map((date) => Tab(
                    text: date,
                  ))
              .toList(),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            if (_tabController.index + 1 < _tabController.length) {
              _tabController.animateTo(_tabController.index + 1);
            } else {
              //
            }
          },
        )
      ]),
      body: TabBarView(
        controller: _tabController,
        children: tabs.map((date) => SlateLog(date)).toList(),
      ),
    );
  }
}
