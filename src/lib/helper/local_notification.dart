import 'dart:async';
import 'package:flutter/material.dart';

class DateChecker extends StatefulWidget {
  const DateChecker({super.key});

  @override
  DateCheckerState createState() => DateCheckerState();
}

class DateCheckerState extends State<DateChecker> {
  late DateTime _lastDate;

  @override
  void initState() {
    super.initState();
    _lastDate = DateTime.now();
    Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_lastDate.day != DateTime.now().day) {
        // Do something here
        debugPrint('The date has changed!');
      }
      _lastDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
