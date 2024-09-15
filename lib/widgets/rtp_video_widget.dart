import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class RtpVideoWidget extends StatefulWidget {
  final String host;
  final int port;

  // Constructor takes host and port as parameters.
  RtpVideoWidget({required this.host, required this.port});

  @override
  _RtpVideoWidgetState createState() => _RtpVideoWidgetState();
}

class _RtpVideoWidgetState extends State<RtpVideoWidget> {
  late Player _player = Player();
  late VideoController _controller = VideoController(_player);

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    MediaKit.ensureInitialized();
    _player.open(Media('rtp://${widget.host}:${widget.port}'));
  }

  @override
  void dispose() {
    // Dispose the player and controller when no longer needed.
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 480*MediaQuery.of(context).size.width/640,
        child: Video(
          controller: _controller,
        ),
      )
    );
  }
}
