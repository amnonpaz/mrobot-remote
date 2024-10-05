import 'dart:typed_data';

import 'package:flutter/material.dart';

class VideoFrameWidget extends StatefulWidget {
  VideoFrameWidget({super.key, required this.imageStream, required this.defaultImage});

  final Stream<Uint8List> imageStream;
  final Image defaultImage;

  @override
  State<VideoFrameWidget> createState() => _VideoFrameWidgetState();
}

class _VideoFrameWidgetState extends State<VideoFrameWidget> {
  Uint8List? _lastImageData;

  @override
  void initState() {
    super.initState();

    // Subscribe to the image stream and update the image data on new frames
    widget.imageStream.listen((newImageData) {
      setState(() {
        _lastImageData = newImageData;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return (_lastImageData != null) ?
      Image.memory(
        _lastImageData!,
        gaplessPlayback: true,
      ) :
      widget.defaultImage;
  }

}