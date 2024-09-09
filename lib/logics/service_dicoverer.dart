import 'package:bonsoir/bonsoir.dart';
import 'package:logger/logger.dart';

enum ServiceDiscovererState {
  notStarted,
  ready,
  started,
  serviceFound,
  serviceNotFound,
  serviceLost,
  otherEvent
}

class ServiceDiscoverer {
  static const String _name = 'mrobot-server._websocket._tcp.local.';

  final _discovery = BonsoirDiscovery(type: '_websocket._tcp.');
  final _logger = Logger();

  state() => _state;
  host() => _host;
  port() => _port;

  ServiceDiscovererState _state = ServiceDiscovererState.notStarted;
  var _host = "";
  var _port = 0;

  Future<void> discover(Function onDiscoveryStateChange) async {
    _logger.d('Starting discovery');

    await _discovery.ready;
    _logger.d('Discovery service ready');
    _state = ServiceDiscovererState.ready;
    onDiscoveryStateChange();

    _discovery.eventStream!.listen((event) {
      _logger.d('Handling discovery event');

      if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
        _logger.i('Service found : ${event.service!.toJson()}');
        //event.service!.resolve(discovery.serviceResolver); // Should be called when the user wants to connect to this service.
        _state = ServiceDiscovererState.serviceFound;
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
        _logger.i('Service resolved : ${event.service!.toJson()}');
        _state = ServiceDiscovererState.serviceFound;
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
        _logger.i('Service lost : ${event.service!.toJson()}');
        _state = ServiceDiscovererState.serviceFound;
      } else {
        _logger.i('State: ${event.type}');
        _state = ServiceDiscovererState.otherEvent;
      }

      _logger.d('Done handling discovery event');
      onDiscoveryStateChange();
    });

// Start the discovery **after** listening to discovery events :
    _logger.d('Starting discovery service');
    await _discovery.start();

    _logger.d('Discovery service done');
  }

  Future<void> stop() async {
    await _discovery.stop();
  }
}