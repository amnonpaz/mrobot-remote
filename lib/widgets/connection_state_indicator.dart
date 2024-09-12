import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


class ConnectionStateIndicator {
  var _connected = false;

  setState(bool connected) => _connected = connected;

  Widget getWidget() {
    return _connected ? connectedWidget() : disconnectedWidget();
  }

  connectedWidget() {
    return const Icon(IconData(0xe159, fontFamily: 'MaterialIcons'), color: Colors.green, size: 100);
  }

  disconnectedWidget() {
    return Column(
        children: [
          LoadingAnimationWidget.twistingDots(
            leftDotColor: Colors.lightGreen,
            rightDotColor: Colors.deepOrange,
            size: 50,
          ),
          const Text('Searching for service...', style: TextStyle(fontSize: 20))
        ]
    );
  }

}