import 'dart:async';

import 'package:flutter/material.dart';
import 'package:voislate/data/my_ifly_key.dart';
import 'package:ifly_speech_recognition/ifly_speech_recognition.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

// ignore: must_be_immutable
class RecorderJoystick extends StatefulWidget {
  /// Height of the slider. Defaults to 70.
  final double height;

  /// Width of the slider. Defaults to 300.
  final double width;

  final double slideLength;

  final double initValue;

  /// The color of the background of the slider. Defaults to Colors.white.
  final Color backgroundColor;

  /// The color of the background of the slider when it has been slide to the end. By giving a value here, the background color
  /// will gradually change from backgroundColor to backgroundColorEnd when the user slides. Is not used by default.
  final Color? backgroundColorEnd;

  /// The color of the moving element of the slider. Defaults to Colors.blueAccent.
  final Color foregroundColor;

  /// The color of the icon on the moving element if icon is IconData. Defaults to Colors.white.
  final Color iconColor;

  /// The button widget used on the moving element of the slider. Defaults Icons.unfold_more,
  final Widget sliderButtonContent;

  /// The text showed below the foreground. Used to specify the functionality to the user. Defaults to "Slide to confirm".
  final String text;

  /// The style of the text. Defaults to TextStyle(color: Colors.black26, fontWeight: FontWeight.bold,).
  final TextStyle? textStyle;

  /// The callback when slider is completed. This is the only required field.
  final VoidCallback onRightEdge;

  /// the callback when slider is at left edge.
  final VoidCallback? onLeftEdge;

  /// The callback when slider is pressed.
  final VoidCallback? onTapDown;

  /// The textcontroller of the textfield on left side.
  final TextEditingController? leftTextController;

  /// The textcontroller of the textfield on right side.
  final TextEditingController? rightTextController;

  /// The callback when slider is release.
  final VoidCallback? onTapUp;

  /// The shape of the moving element of the slider. Defaults to a circular border radius
  final BorderRadius? foregroundShape;

  /// The shape of the background of the slider. Defaults to a circular border radius
  final BorderRadius? backgroundShape;

  /// Stick the slider to the end
  final bool stickToEnd;

  var isVisible = false;

  RecorderJoystick({
    Key? key,
    this.height = 70,
    this.width = 300,
    this.backgroundColor = Colors.white,
    this.backgroundColorEnd,
    this.foregroundColor = Colors.blueAccent,
    this.iconColor = Colors.white,
    this.sliderButtonContent = const Icon(
      Icons.unfold_more,
      color: Colors.white,
      size: 35,
    ),
    this.text = "Slide to confirm",
    this.textStyle,
    required this.onRightEdge,
    this.onLeftEdge,
    this.onTapDown,
    this.onTapUp,
    this.leftTextController,
    this.rightTextController,
    this.foregroundShape,
    this.backgroundShape,
    this.stickToEnd = false,
  })  : assert(height >= 25 && width >= 120),
        slideLength = width - height,
        initValue = (width - height) / 2,
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RecorderJoystickState();
  }
}

class RecorderJoystickState extends MountedState<RecorderJoystick> {
  // The Speech Recoginition Part
  final SpeechRecognitionService _recognitionService = recognitionService;
  bool _havePermission = false;
  //
  // String? _result;

  late double _position = widget.initValue;
  int _duration = 0;

  late Stream<String> resultStream;
  //
  // late bool _wsStatus;

  double getPosition() {
    if (_position < 0) {
      return 0;
    } else if (_position > widget.slideLength) {
      return widget.slideLength;
    } else {
      return _position;
    }
  }

  // The permission part
  Future<bool> _checkPermission() async {
    final status = await Permission.microphone.status;
    if (status.isDenied) {
      var requestStatus = await Permission.microphone.request();
      return requestStatus.isGranted;
    } else {
      return true;
    }
  }

  void _initRecorder() async {
    _havePermission = await _checkPermission();

    if (!_havePermission) {
      // 授权失败
      EasyLoading.showToast('请开启麦克风权限');
      return;
    }

    // 初始化语音识别服务
    await _recognitionService.initRecorder();

    // 录音停止
    // _recognitionService.onStopRecording().listen((isAutomatic) {
    //   if (isAutomatic) {
    //     // 录音时间到达最大值60s，自动停止
    //   } else {
    //     // 主动调用 stopRecord，停止录音
    //   }
    // });
  }

  @override
  void initState() {
    resultStream = _recognitionService.onRecordResult();
    super.initState();
    _checkPermission();
    _initRecorder();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: _duration),
      curve: Curves.easeInExpo,
      height: widget.height,
      width: widget.width,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: widget.backgroundShape ??
            BorderRadius.all(Radius.circular(widget.height)),
        color: widget.backgroundColorEnd != null
            ? calculateBackground()
            : widget.backgroundColor,
        // boxShadow: <BoxShadow>[shadow],
      ),
      child: Stack(
        children: <Widget>[
          Visibility(visible: !widget.isVisible, child: slideBackground()),
          confirmIcons(),
          sliderBall(),
        ],
      ),
    );
  }

  // recorder fuctions
  /// 开始录音
  void _startRecord() async {
    if (!_havePermission) {
      EasyLoading.showToast('请开启麦克风权限');
      return;
    }
    EasyLoading.show(status: '正在录音');
    final r = await _recognitionService.startRecord(AudioSource.microphone);
    debugPrint('开启录音: $r');
  }

  /// 结束录音
  void _stopRecord() async {
    final r = await _recognitionService.stopRecord();
    debugPrint('关闭录音: $r');
    // 识别语音
    EasyLoading.show(status: 'loading...');
    _recognitionService.speechRecognition();
    EasyLoading.dismiss();
  }

  // The slider fuctions
  void updatePosition(details) {
    if (details is DragEndDetails) {
      setState(() {
        _duration = 200;
        if (widget.stickToEnd && _position > widget.slideLength) {
          _position = widget.slideLength;
        } else {
          _position = widget.initValue;
        }
      });
    } else if (details is DragUpdateDetails) {
      setState(() {
        _duration = 0;
        _position = details.localPosition.dx + widget.initValue;
      });
    }
  }

  Future<void> sliderReleased(details) async {
    _stopRecord();
    if (_position > widget.slideLength && widget.rightTextController != null) {
      var message = resultStream.take(1);
      await for (var value in message) {
        EasyLoading.dismiss();
        widget.rightTextController!.text = value;
      }
      widget.onRightEdge();
    } else if (_position < 0 && widget.leftTextController != null) {
      var message = resultStream.take(1);
      await for (var value in message) {
        EasyLoading.dismiss();
        widget.leftTextController!.text = value;
      }
      widget.onLeftEdge!();
    }
    updatePosition(details);
    widget.isVisible = false;
  }

  Color calculateBackground() {
    if (widget.backgroundColorEnd != null) {
      double percent;
      if (_position > widget.slideLength) {
        percent = 1.0;
      } else if (_position / (widget.slideLength) > 0) {
        percent = _position / (widget.slideLength);
      } else {
        percent = 0.0;
      }
      int red = widget.backgroundColorEnd!.red;
      int green = widget.backgroundColorEnd!.green;
      int blue = widget.backgroundColorEnd!.blue;
      if (_position == widget.slideLength / 2) {
        return Colors.transparent;
      } else if (_position > widget.slideLength) {
        return Color.fromRGBO(red, green, blue, 1.0);
      } else if (_position == widget.slideLength / 2) {
        return widget.backgroundColor;
      } else {
        return Color.alphaBlend(
            Color.fromRGBO(red, green, blue, percent), widget.backgroundColor);
      }
    } else {
      return widget.backgroundColor;
    }
  }

  // The background widgets
  AnimatedPositioned sliderBall() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: _duration),
      curve: Curves.easeInExpo,
      left: getPosition(),
      top: 0,
      child: GestureDetector(
        onTapDown: (_) {
          widget.isVisible = true;
          widget.onTapDown != null ? widget.onTapDown!() : null;
          _startRecord();
        },
        onTapUp: (_) {
          EasyLoading.dismiss();
          widget.onTapUp != null ? widget.onTapUp!() : null;
          _stopRecord();
        },
        onPanUpdate: (details) {
          updatePosition(details);
        },
        onPanEnd: (details) {
          EasyLoading.dismiss();
          if (widget.onTapUp != null) widget.onTapUp!();
          sliderReleased(details);
        },
        child: Container(
          height: widget.height - 10,
          width: widget.height - 10,
          decoration: BoxDecoration(
            borderRadius: widget.foregroundShape ??
                BorderRadius.all(Radius.circular(widget.height / 2)),
            color: widget.foregroundColor,
          ),
          child: widget.sliderButtonContent,
        ),
      ),
    );
  }

  Center confirmIcons() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.arrow_right,
            size: 48,
            color: Colors.green[300],
          ),
          const SizedBox(
            height: 10,
          ),
          Icon(
            Icons.arrow_left,
            size: 48,
            color: Colors.red[300],
          ),
        ],
      ),
    );
  }

  Positioned slideBackground() {
    return Positioned(
      left: widget.height / 2,
      child: AnimatedContainer(
        height: widget.height - 10,
        width: getPosition(),
        duration: Duration(milliseconds: _duration),
        curve: Curves.ease,
        decoration: BoxDecoration(
          borderRadius: widget.backgroundShape ??
              BorderRadius.all(Radius.circular(widget.height)),
          color: widget.backgroundColorEnd != null
              ? calculateBackground()
              : widget.backgroundColor,
        ),
      ),
    );
  }
}

class MountedState<T extends StatefulWidget> extends State<T> {
  @override
  Widget build(BuildContext context) {
    return const Text('mounted');
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
