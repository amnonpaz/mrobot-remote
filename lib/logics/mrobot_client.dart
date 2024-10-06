import 'dart:convert';
import 'dart:typed_data';
import 'package:logger/logger.dart';
import 'package:messagepack/messagepack.dart';
import 'package:web_socket_client/web_socket_client.dart';

abstract class MRobotClientConnectionHandler {
  void onClientConnect();
  void onClientDisconnect();
}

abstract class MRobotClientEventsHandler {
  Future<void> onVideoStarted();
  Future<void> onVideoStopped();
  Future<void> onVideoFrame(Uint8List frame);
}

class MRobotClient {
  MRobotClient({required MRobotClientConnectionHandler handler}) :
    _connectionHandler = handler;

  WebSocket? _client;
  final _logger = Logger();

  final MRobotClientConnectionHandler _connectionHandler;
  MRobotClientEventsHandler? _eventsHandler;

  String _host = "";
  int _port = 0;
  static const int _videoPort = 5687;

  eventsHandler(var eventsHandler) => _eventsHandler = eventsHandler;
  String host() => _host;
  int port() => _port;
  int videoPort() => _videoPort;

  open(String host, int port) {
    close();

    _logger.i("Connecting to websocket server on $host:$port");
    _client = WebSocket(Uri.parse("ws://$host:$port"),
        backoff: const ConstantBackoff(Duration(seconds: 1)));
    _client!.connection.listen(handleState);
    _client!.messages.listen(handleMessage);

    _host = host;
    _port = port;
  }

  close() {
    if (_client == null) {
      return;
    }

    _client!.close();
    _client = null;
  }

  handleState(ConnectionState state) {
    if (state is Connected || state is Reconnected) {
      _logger.d('WebSocket client connected/reconnected');
      _connectionHandler.onClientConnect();
    } else if (state is Disconnected) {
      _logger.d('WebSocket client disconnected');
      _connectionHandler.onClientDisconnect();
    } else {
      _logger.d('Unhandled state: $state');
    }
  }

  handleMessage(message) {
    if (_eventsHandler == null) {
      _logger.d('No one to answer the message');
      return;
    }

    final unpacker = Unpacker(message);
    var unpackedMessage = unpacker.unpackMap();
    if (unpackedMessage.containsKey('command')) {
      _logger.d('Got command');
      handleAnswer(unpackedMessage);
    } else if (unpackedMessage.containsKey('event')) {
      _logger.d('Got event');
      handleEvent(unpackedMessage);
    }
  }

  handleAnswer(answer) {
    if (answer['success'] == false) {
      _logger.w('Command ${answer['command']} has failed: ${answer['response']}');
      return;
    }

    _logger.d('Command ${answer['command']} succeeded: ${answer['response']}');

    if (answer['command'] == 'video_start') {
      _eventsHandler!.onVideoStarted();
    } else if (answer['command'] == 'video_stop') {
      _eventsHandler!.onVideoStopped();
    }
  }

  handleEvent(event) {
    if (!event.containsKey('event')) {
      _logger.w('Event does not have \'event\' field');
      return;
    }

    if (!event.containsKey('payload')) {
      _logger.w('Video frame event does not contain payload');
      return;
    }

    _logger.d('Event: ${event['event']} ; Payload side: ${event['payload'].length}');
    Uint8List rawData = base64Decode(event['payload']);
    _eventsHandler!.onVideoFrame(rawData);
  }

  setVideoState(bool state) {
    if (_client == null) {
      _logger.w('Trying to use null client');
      return;
    }

    final p = Packer()
    ..packMapLength(2)
      ..packString('command')
        ..packString(state ? 'video_start' : 'video_stop')
      ..packString('parameters')
        ..packMapLength(2)
          ..packString('host')
            ..packString(_host)
          ..packString('port')
            ..packInt(_videoPort);

    _client!.send(p.takeBytes());
  }

  setFrontLightsState(bool state) {
    if (_client == null) {
      _logger.w('Trying to use null client');
      return;
    }

    final p = Packer()
      ..packMapLength(2)
      ..packString('command')
        ..packString('front_lights')
      ..packString('parameters')
        ..packMapLength(1)
        ..packString('state')
        ..packBool(state);

    _client!.send(p.takeBytes());
  }

  setMovement(double x, double y) {
    final p = Packer()
      ..packMapLength(2)
        ..packString('command')
          ..packString('move')
        ..packString('parameters')
          ..packMapLength(2)
            ..packString('x')
              ..packDouble(x)
            ..packString('y')
              ..packDouble(y);

    _client!.send(p.takeBytes());
  }

}