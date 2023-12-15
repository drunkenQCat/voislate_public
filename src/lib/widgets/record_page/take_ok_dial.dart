import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:voislate/providers/slate_status_notifier.dart';
import 'package:voislate/models/tk_pending.dart';
import '../../models/slate_log_item.dart';

// ignore: must_be_immutable
class TakeOkDial extends StatefulWidget {
  TkPending pending = TkPending();

  TakeOkDial({super.key, required this.context, required this.pending});

  final BuildContext context;

  @override
  State<TakeOkDial> createState() => _TakeOkDialState();
}

class _TakeOkDialState extends State<TakeOkDial> {
  Widget _buildTkStatusIcon() {
    switch (widget.pending.tk) {
      case TkStatus.notChecked:
        return const Icon(
          Icons.headphones,
        );
      case TkStatus.ok:
        return const Icon(
          Icons.gpp_good,
        );
      case TkStatus.bad:
        return const Icon(
          Icons.hearing_disabled,
        );
    }
  }

  Color _getTkStatusColor(TkStatus status) {
    switch (status) {
      case TkStatus.notChecked: // changed enum name to TkStatus.notChecked
        return const Color(0xFFF2F5DE);
      case TkStatus.ok: // changed enum name to TkStatus.ok
        return Colors.green;
      case TkStatus.bad: // changed enum name to TkStatus.nice
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    var enumProvider = Provider.of<SlateStatusNotifier>(context, listen: false);
    return SpeedDial(
      key: widget.key,
      heroTag: 'pending',
      direction: SpeedDialDirection.up,
      activeIcon: Icons.close,
      backgroundColor: _getTkStatusColor(widget.pending.tk),
      children: <SpeedDialChild>[
        SpeedDialChild(
          backgroundColor: Colors.red,
          onTap: () {
            setState(() {
              widget.pending.tk = TkStatus.bad;
              enumProvider.setOkStatus(currentTk: widget.pending.tk);
            });
          },
          label: '声音弃',
          child: const Icon(Icons.hearing_disabled),
        ),
        SpeedDialChild(
          backgroundColor: Colors.green,
          onTap: () {
            setState(() {
              widget.pending.tk = TkStatus.ok;
              enumProvider.setOkStatus(currentTk: widget.pending.tk);
            });
          },
          label: '声音可',
          child: const Icon(Icons.gpp_good),
        ),
      ],
      child: _buildTkStatusIcon(),
    );
  }
}
