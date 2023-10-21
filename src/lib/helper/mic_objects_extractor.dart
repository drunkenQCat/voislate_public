import 'package:voislate/models/slate_log_item.dart';
import 'package:tuple/tuple.dart';

class MicObjectsExtractor {
  /// An extracting function to get [shtNote] and [trackList].
  ///
  /// In returned `Tuple2`, `item1` is [shtNote], `item2` is [trackList].
  Tuple2<String, List<String>> extract(SlateLogItem item) {
    var shtNotePreParse = item.shtNote.split('<');
    var shtNote = shtNotePreParse[0];
    List<String> trackList = [];
    if (shtNotePreParse.length > 1) {
      shtNotePreParse.removeAt(0);
      for (var element in shtNotePreParse) {
        // iterate through the remaining elements
        trackList.add(
            element.replaceAll('/>', '')); // strip "/>" and add to trackList
      }
    }
    return Tuple2(shtNote, trackList);
  }
}
