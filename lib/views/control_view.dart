import 'package:flutter/material.dart';
import 'package:mrobot_remote/logics/mrobot_client.dart';
import 'package:mrobot_remote/widgets/rtp_video_widget.dart';

class ControlView extends StatelessWidget {
  ControlView({super.key, required MRobotClient mrobotClient}) :
    _mrobotClient = mrobotClient;

  final MRobotClient _mrobotClient;
  bool _videoEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _videoEnabled ?
          RtpVideoWidget(host: _mrobotClient.host(), port: _mrobotClient.videoPort()) :
          Container(),
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
    );
  }

  onEnableVideoChange(bool value) {

  }
}