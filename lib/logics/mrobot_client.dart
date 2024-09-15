import 'package:logger/logger.dart';
import 'package:web_socket_client/web_socket_client.dart';

abstract class MRobotClientConnectionHandler {
  void onClientConnect();
  void onClientDisconnect();
}
class MRobotClient {
  MRobotClient({required MRobotClientConnectionHandler handler}) :
    _handler = handler;

  WebSocket? _client;
  final _logger = Logger();

  final MRobotClientConnectionHandler _handler;

  String _host = "";
  int _port = 0;
  static const int _videoPort = 8877;

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
      _handler.onClientConnect();
    } else if (state is Disconnected) {
      _logger.d('WebSocket client disconnected');
      _handler.onClientDisconnect();
    } else {
      _logger.d('Unhandled state: $state');
    }
  }

  handleMessage(message) {
    _logger.d('Message received: $message');
  }

  setVideoState(bool state) {

  }

}