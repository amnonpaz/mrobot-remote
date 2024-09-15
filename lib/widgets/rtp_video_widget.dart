import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';


class RtpVideoWidget extends StatefulWidget {
  const RtpVideoWidget({super.key, required String host, required int port}) :
    _host = host,
    _port = port;

  final String _host;
  final int _port;

  @override
  _RtpVideoWidgetState createState() => _RtpVideoWidgetState();
}

class _RtpVideoWidgetState extends State<RtpVideoWidget> {

  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse('rtp://${widget._host}:${widget._port}'))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
              : Container(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}