import 'package:bonsoir/bonsoir.dart';
import 'package:logger/logger.dart';

enum ServiceDiscovererState {
  notStarted,
  ready,
  started,
  serviceFound,
  serviceResolved,
  serviceLost,
  otherEvent
}

class ServiceDiscoverer {
  static const String _name = '_mrobot-server';

  final _discovery = BonsoirDiscovery(type: '_websocket._tcp.');
  final _logger = Logger();

  state() => _state;
  host() => _host;
  port() => _port;
  name() => _name;

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
        handleServiceFound(event.service!);
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
        handleServiceResolved(event.service!);
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
        handleServiceLost(event.service!);
      } else {
        _logger.i('State: ${event.type}');
        _state = ServiceDiscovererState.otherEvent;
      }

      _logger.d('Done handling discovery event');
      onDiscoveryStateChange();
    });

    _logger.d('Starting discovery service');
    await _discovery.start();

    _logger.d('Discovery service done');
  }

  Future<void> stop() async {
    await _discovery.stop();
  }

  handleServiceFound(BonsoirService service) {
    _logger.i('Service found : ${service.toJson()}');

    final foundServiceName = service.name;
    if (foundServiceName == _name) {
      service.resolve(_discovery.serviceResolver);
      _state = ServiceDiscovererState.serviceFound;
    }
  }

  handleServiceResolved(BonsoirService service) {
    _logger.i('Service resolved : ${service.toJson()}');

    _host = "";
    _port = 0;

    service.toJson().forEach((k, v) {
      if (k == 'service.host') {
        _host = v;
        _port = service.port;
        _state = ServiceDiscovererState.serviceResolved;
      }    _state = ServiceDiscovererState.serviceResolved;

    });
  }

  handleServiceLost(BonsoirService service) {
    _logger.i('Service lost : ${service.toJson()}');

    _port = 0;
    _host = "";

    _state = ServiceDiscovererState.serviceLost;
  }
}