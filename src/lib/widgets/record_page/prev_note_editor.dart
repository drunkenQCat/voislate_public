import 'package:flutter/material.dart';
import 'package:voislate/models/recorder_file_num.dart';

class PrevTakeEditor extends StatelessWidget {
  /// This is the Description Editor for the previous record file.
  const PrevTakeEditor({
    Key? key,
    required this.num,
    required this.descEditingController,
  }) : super(key: key);

  final TextEditingController descEditingController;
  final RecordFileNum num;

  @override
  Widget build(BuildContext context) {
    var prevTakeInputField = SizedBox(
      // width: screenWidth * 0.3,
      child: TextField(
        // bind the input to the note variable
        maxLines: 3,
        controller: descEditingController,
        onChanged: (text) {},
        decoration: InputDecoration(
          // contentPadding: EdgeInsets.symmetric(vertical: 20),
          border: const OutlineInputBorder(),
          hintText: '${num.prevFileName()}\n 录音标注...',
        ),
      ),
    );
    var prevTakeTitle = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Icon(
          Icons.radio_button_checked,
          size: 19,
          color: Colors.red,
        ),
        Text('正在录制:T${num.prevFileNum().toString().padLeft(3, '0')}'),
      ],
    );
    return Flexible(
      child: ListTileTheme(
        minLeadingWidth: 5,
        child: ListTile(
          title: prevTakeTitle,
          subtitle: prevTakeInputField,
        ),
      ),
    );
  }
}

class PrevShotNote extends StatelessWidget {
  const PrevShotNote({
    Key? key,
    required this.currentScn,
    required this.currentSht,
    required this.currentTk,
    required this.controller,
  }) : super(key: key);

  final String currentScn;
  final String currentSht;
  final String currentTk;
  final TextEditingController controller;

  @override
  build(BuildContext context) {
    var takeLogTitle = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "S$currentScn Sh$currentSht Tk",
        ),
        Text(
          currentTk,
          style: TextStyle(
            backgroundColor: currentTk == 'OK'
                ? const Color.fromARGB(139, 167, 199, 130)
                : Colors.white,
          ),
        ),
        const Icon(
          Icons.movie_creation_outlined,
          size: 19,
          color: Colors.green,
        ),
      ],
    );
    return Flexible(
      child: ListTileTheme(
        minLeadingWidth: 5,
        child: ListTile(
          title: takeLogTitle,
          subtitle: SizedBox(
            // width: screenWidth * 0.3,
            child: TextField(
              // bind the input to the note variable
              maxLines: 3,
              controller: controller,
              onChanged: (text) {},
              decoration: const InputDecoration(
                // contentPadding: EdgeInsets.symmetric(vertical: 20),
                border: OutlineInputBorder(),
                hintText: 'Shot Note',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
