import 'package:logger/logger.dart';
import 'package:web_socket_client/web_socket_client.dart';


class MRobotClient {
  WebSocket? _client;
  final _logger = Logger();

  open(String host, int port) {
    close();

    _logger.i("Connecting to websocket server on $host:$port");
    _client = WebSocket(Uri.parse("ws://$host:$port"),
        backoff: const ConstantBackoff(Duration(seconds: 1)));
    _client!.connection.listen(handleState);
    _client!.messages.listen(handleMessage);
  }

  close() {
    if (_client == null) {
      return;
    }

    _client!.close();
    _client = null;
  }

  handleState(ConnectionState state) {
    _logger.d('New WebSocket state: $state');
  }

  handleMessage(message) {
    _logger.d('Message received: $message');
  }

}