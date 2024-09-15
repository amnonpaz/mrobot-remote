import 'package:flutter/material.dart';
import 'package:mrobot_remote/logics/service_dicoverer.dart';
import 'package:mrobot_remote/widgets/connection_state_indicator.dart';

typedef OnServiceResolvedCallback = void Function(String host, int port);
typedef OnServiceLostCallback = void Function();

class ServiceSearchView extends StatefulWidget {
  const ServiceSearchView({super.key, required this.onServiceResolvedCallback, required this.onServiceLostCallback});

  final OnServiceResolvedCallback onServiceResolvedCallback;
  final OnServiceLostCallback onServiceLostCallback;

  @override
  State<ServiceSearchView> createState() => _ServiceSearchViewState();
}

class _ServiceSearchViewState extends State<ServiceSearchView> {
  final _serviceDiscoverer = ServiceDiscoverer();
  final _connectionStateIndicator = ConnectionStateIndicator();

  @override
  void initState() {
    super.initState();
    _serviceDiscoverer.discover(onServiceDiscoveryDone);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          _connectionStateIndicator.getWidget(),
          Text(getServiceDiscoveryStateText()),
          const Spacer(),
        ],
      ),
    );
  }

  onServiceDiscoveryDone() {
    bool resolved = _serviceDiscoverer.state() == ServiceDiscovererState.serviceResolved;
    _connectionStateIndicator.setState(resolved);
    if (resolved) {
      widget.onServiceResolvedCallback(_serviceDiscoverer.host(), _serviceDiscoverer.port());
    }

    setState(() {});
  }

  getServiceDiscoveryStateText() {
    var text = 'Discovery service invalid state';
    switch (_serviceDiscoverer.state()) {
      case ServiceDiscovererState.notStarted:
        text = 'Discovery service not started';
        break;
      case ServiceDiscovererState.ready:
        text = 'Discovery service ready';
        break;
      case ServiceDiscovererState.started:
        text = 'Discovery service started';
        break;
      case ServiceDiscovererState.serviceFound:
        text = 'Service ${_serviceDiscoverer.name()} found';
        break;
      case ServiceDiscovererState.serviceResolved:
        text = 'Service ${_serviceDiscoverer.name()} resolves on ${_serviceDiscoverer.host()}:${_serviceDiscoverer.port()}';
        break;
      case ServiceDiscovererState.serviceLost:
        text = 'Service lost';
        break;
      case ServiceDiscovererState.otherEvent:
        text = "Service something";
        break;
    }

    return text;
  }

}