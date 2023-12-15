import 'package:flutter/material.dart';
import 'package:voislate/models/recorder_file_num.dart';

class CurrentFileMonitor extends StatelessWidget {
  const CurrentFileMonitor({super.key, required this.fileNum});
  final RecordFileNum fileNum;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.radio_button_checked,
              size: 19,
              color: Colors.red,
            ),
            const SizedBox(width: 13),
            Text(
              "${fileNum.prefix}${fileNum.intervalSymbol}${fileNum.prevFileNum().toString().padLeft(3, '0')}",
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
