// change notifier model to change the numList value
import 'package:flutter/material.dart';

abstract class SlatePickerState with ChangeNotifier {
  final FixedExtentScrollController controller = FixedExtentScrollController();
  var _numList = <String>['1','2'];
  var _selectedIndex = 0;
  get selectedIndex => _selectedIndex;
  set selectedIndex(value) {
    _selectedIndex = value;
    notifyListeners();
  }
  get selected => numList[selectedIndex];
  get numList => _numList;
  set numList(value) {
    _numList = value;
    // 检测numlist里边有没有重复的元素
    var set = Set<String>.from(value);
    if (set.length != value.length) {
      throw Exception('numList has duplicate elements');
    }
    notifyListeners();
  }

  /// initiallize the list of column and selectedIndex.
  /// if no input, just jump the selectedIndex to 0.
  /// if inputlist is [], just use the default numList.
  void init([int initialIndex = 0, List<String>? inputList ]) {
    // controller = FixedExtentScrollController(initialItem: initialIndex);
    if(inputList != null) numList = inputList;
    controller.jumpToItem(initialIndex);
    _selectedIndex = initialIndex;
  }

  void scrollSelectedTo(String value) {
    var index = numList.indexOf(value);
    controller.animateToItem(index, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
    _selectedIndex = index;
    notifyListeners();
  }
  
  void scrollSelectedToIndex(int index) {
    controller.animateToItem(index, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
    _selectedIndex = index;
    notifyListeners();
  }
  void scrollToNext(bool isLink) {
    if(selected == numList.last) return;

    if (isLink && _selectedIndex + 1 < numList.length) {
      _selectedIndex++;
      scrollSelectedToIndex(_selectedIndex);
    }
  }

  void scrollToPrev(bool isLink){
    if (_selectedIndex == 0) return;

    _selectedIndex--;
    if (_selectedIndex< 0) {
      _selectedIndex = numList.length - 1;
    }
    if (isLink) scrollSelectedToIndex(_selectedIndex);
  }
}
class SlateColumnOne extends SlatePickerState {}
class SlateColumnTwo extends SlatePickerState {}
class SlateColumnThree extends SlatePickerState {}