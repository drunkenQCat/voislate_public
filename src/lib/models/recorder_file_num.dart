import 'dart:async';

class RecordFileNum {
  String customPrefix = "custom";
  String recorderType = "default";
  String get prefix {
    if (recorderType == "custom") {
      return customPrefix;
    }
    if (recorderType == "sound devices") return soundDevicesToday;
    // TODO: Date Changing
    return today;
  }

  String intervalSymbol;
  final _valueController = StreamController<int>();
  Stream<int> get value => _valueController.stream;

  int _number = 1;
  int get number => _number;

  void setValue(int newValue) {
    _number = newValue;
    _valueController.sink.add(_number);
  }

  int increment() {
    _number++;
    _valueController.sink.add(_number);
    return _number;
  }

  int decrement() {
    // if the number is already 1, don't decrement
    if (_number - 1 < 1) return _number;

    _number--;
    _valueController.sink.add(_number);
    return _number;
  }

  void dispose() {
    _valueController.close();
  }

  String fullName() {
    var numberPad = _number.toString().padLeft(3, '0');
    return '$prefix$intervalSymbol$numberPad';
  }

  String prevFileName() {
    if (_number == 1) return '';
    var numberPad = (_number - 1).toString().padLeft(3, '0');
    return '$prefix$intervalSymbol$numberPad';
  }

  int prevFileNum() => _number - 1;

  RecordFileNum({
    this.recorderType = "default",
    this.intervalSymbol = '-T',
  });

  // a function to get the date of today
  // to be used as the defualt prefix of the file name
  static String get today {
    var now = DateTime.now();
    var year = now.year.toString().substring(2);
    var month = now.month.toString().padLeft(2, '0');
    var day = now.day.toString().padLeft(2, '0');
    return '$year$month$day';
  }

  static String get soundDevicesToday {
    var now = DateTime.now();
    var year = now.year.toString().substring(2);
    var month = now.month.toString().padLeft(2, '0');
    var day = now.day.toString().padLeft(2, '0');
    return '${year}Y${month}M$day';
  }
}
