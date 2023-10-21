import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'slate_picker_notifier.dart';

// the button to increment the counter for every column， add and scroll different columns
// especiallly for volume key control
class ScrollValueController<T extends SlatePickerState> {
  final TextEditingController textCon;
  BuildContext context;
  VoidCallback? inc;
  VoidCallback? dec;
  final T col;

  ScrollValueController({
    required this.context,
    required this.textCon,
    this.inc,
    this.dec,
    required this.col,
  });

  String getPrevTk() {
    var pickerHistory = Hive.box('picker_history');
    if (pickerHistory.isEmpty) return "";
    var prevTake = pickerHistory.getAt(pickerHistory.length - 1);
    List<String> prevTakeList = prevTake.cast<String>();
    return prevTakeList[2];
  }

  void valueInc(bool isLinked) {
    inc?.call();
    textCon.clear();
    col.scrollToNext(isLinked);
  }

  void valueDec(bool isLinked) {
    if (getPrevTk() != "OK") {
      col.scrollToPrev(isLinked);
    }
    dec?.call();
  }
}
