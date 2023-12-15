import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:voislate/models/tk_pending.dart';
import 'package:voislate/providers/slate_status_notifier.dart';

import '../../models/slate_log_item.dart';

// ignore: must_be_immutable
class ShotOkDial extends StatefulWidget {
  var pending = TkPending();

  ShotOkDial({super.key, required this.context, required this.pending});

  final BuildContext context;

  @override
  State<ShotOkDial> createState() => _ShotOkDialState();
}

class _ShotOkDialState extends State<ShotOkDial> {
  Widget _buildShtStatusIcon() {
    switch (widget.pending.sht) {
      case ShtStatus.notChecked:
        return const Icon(Icons.videocam);
      case ShtStatus.ok:
        return const Icon(Icons.movie_filter);
      case ShtStatus.nice:
        return const Icon(Icons.thumb_up);
    }
  }

  Color _getShtStatusColor(ShtStatus status) {
    switch (status) {
      case ShtStatus.notChecked: // changed enum name to TkStatus.notChecked
        return const Color(0xFFF2F5DE);
      case ShtStatus.ok: // changed enum name to TkStatus.ok
        return Colors.blue;
      case ShtStatus.nice: // changed enum name to TkStatus.nice
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    var enumProvider = Provider.of<SlateStatusNotifier>(context, listen: false);
    return SpeedDial(
      key: widget.key,
      backgroundColor: _getShtStatusColor(widget.pending.sht),
      children: <SpeedDialChild>[
        SpeedDialChild(
          onTap: () {
            setState(() {
              widget.pending.sht = ShtStatus.ok;
              enumProvider.setOkStatus(currentSht: widget.pending.sht);
            });
          },
          backgroundColor: Colors.blue,
          label: '画面保',
          child: const Icon(Icons.movie_filter),
        ),
        SpeedDialChild(
          onTap: () {
            setState(() {
              widget.pending.sht = ShtStatus.nice;
              enumProvider.setOkStatus(currentSht: widget.pending.sht);
            });
          },
          backgroundColor: Colors.green,
          label: '画面过',
          child: const Icon(Icons.thumb_up),
        ),
      ],
      child: _buildShtStatusIcon(),
    );
  }
}
