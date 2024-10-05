import 'package:flutter/material.dart';
import 'package:mrobot_remote/logics/mrobot_client.dart';

class ControlView extends StatefulWidget {
  const ControlView({super.key, required this.mrobotClient});

  final MRobotClient mrobotClient;

  @override
  State<ControlView> createState() => _ControlViewState();
}


class _ControlViewState extends State<ControlView> implements MRobotClientEventsHandler {
  bool _videoEnabled = false;
  final Image _blankImage = Image.asset('assets/images/blank_frame.png');
  late Image _lastImage = _blankImage;

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
            child: _videoEnabled ? _lastImage : _blankImage
          ),
          const Spacer(),
          Row(
            children: [
              const Text('Enable video'),
              Switch(
                value: _videoEnabled,
                activeColor: Colors.red,
                onChanged: onEnableVideoChange
              )
            ],
          )
        ],
      )
    );
  }

  onEnableVideoChange(bool value) {
    widget.mrobotClient.setVideoState(value);
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
    try {
      _lastImage = Image.memory(frame);
      setState(() {});
    } catch (e) {
    }
  }
}