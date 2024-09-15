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

    final u = Unpacker(message);
    var answer = u.unpackMap();
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

}