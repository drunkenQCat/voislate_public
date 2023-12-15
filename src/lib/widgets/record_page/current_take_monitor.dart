import 'package:flutter/material.dart';

class CurrentTakeMonitor extends StatelessWidget {
  const CurrentTakeMonitor({
    super.key,
    required this.currentScn,
    required this.currentSht,
    required this.currentTk,
  });
  final String currentScn;
  final String currentSht;
  final String currentTk;
  final height = 90;
  final width = 277;
  final itemHeight = 40.0;
  final itemBackgroundColor = const Color(0xA07C6A0A);

  buildDigiCard(String digi, String unit) {
    return SizedBox(
      height: height + 10,
      width: width / 2.5,
      child: Column(
        children: [
          Expanded(
            child: Card(
                color: itemBackgroundColor,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                  child: SizedBox(
                      height: itemHeight,
                      child: Text(
                        digi,
                        style: const TextStyle(
                            fontSize: 40, color: Colors.black),
                      )),
                )),
          ),
          // SizedBox(height: 4),
          Text(unit,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF212121),
                fontWeight: FontWeight.w400,
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // const Icon(
          //   Icons.movie_creation_outlined,
          //   size: 19,
          //   color: Colors.green,
          // ),
          buildDigiCard(currentScn, "场"),
          buildDigiCard(currentSht, "镜"),
          buildDigiCard(currentTk, "次"),
        ],
      ),
    );
  }
}
