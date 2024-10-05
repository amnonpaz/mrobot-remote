import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:mrobot_remote/logics/mrobot_client.dart';
import 'package:mrobot_remote/widgets/video_frame_widget.dart';

class ControlView extends StatefulWidget {
  const ControlView({super.key, required this.mrobotClient});

  final MRobotClient mrobotClient;

  @override
  State<ControlView> createState() => _ControlViewState();
}


class _ControlViewState extends State<ControlView> implements MRobotClientEventsHandler {
  bool _videoEnabled = false;
  final _blankImage = Image.asset('assets/images/blank_frame.png');
  Uint8List? _lastImageData;

  @override
  initState() {
    widget.mrobotClient.eventsHandler(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            child: _videoEnabled ?
              VideoFrameWidget(
                imageStream: getImageStream(),
                defaultImage: _blankImage
              ) :
              _blankImage
          ),
          Row(
            children: [
              const Text('Enable video'),
              Switch(
                value: _videoEnabled,
                activeColor: Colors.red,
                onChanged: onEnableVideoChange
              )
            ],
          ),
          const Spacer(),
          Joystick(listener: onJoystickMovement),
          const Spacer(),
        ],
      )
    );
  }

  onEnableVideoChange(bool value) {
    widget.mrobotClient.setVideoState(value);
  }

  onJoystickMovement(details) {
    widget.mrobotClient.setMovement(details.x, (-1.0)*details.y);
  }

  @override
  Future<void> onVideoStarted() async {
    _videoEnabled = true;
    setState(() { });
  }

  @override
  Future<void> onVideoStopped() async {
    _videoEnabled = false;
    setState(() { });
  }

  @override
  Future<void> onVideoFrame(frame) async {
    _lastImageData = frame;
  }

  Stream<Uint8List> getImageStream() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (_lastImageData != null) {
        yield _lastImageData!;
      }
    }
  }

}