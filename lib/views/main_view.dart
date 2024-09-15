import 'package:flutter/material.dart';
import 'package:mrobot_remote/views/control_view.dart';
import 'package:mrobot_remote/views/service_search_view.dart';
import 'package:mrobot_remote/logics/mrobot_client.dart';
import 'package:mrobot_remote/widgets/connection_state_indicator.dart';

enum MainViewState {
  serviceSearch,
  serviceAvailable,
  serviceConnected
}

class MainView extends StatefulWidget {
  const MainView({super.key, required this.title});

  final String title;

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> implements MRobotClientConnectionHandler {

  var _state = MainViewState.serviceSearch;
  late final MRobotClient _mrobotClient;

  @override
  initState() {
    _mrobotClient = MRobotClient(handler: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: getCurrentView()
    );
  }

  Widget getCurrentView() {
    Widget result = const Text('Error');
    switch (_state) {
      case MainViewState.serviceSearch:
        result = ServiceSearchView(
            onServiceResolvedCallback: onServiceResolved,
            onServiceLostCallback: onClientDisconnect
        );
        break;
      case MainViewState.serviceAvailable:
        final connectionStateIndicator = ConnectionStateIndicator();
        connectionStateIndicator.setState(false);
        result = const Text('Connecting...');
        break;
      case MainViewState.serviceConnected:
        result = ControlView(mrobotClient: _mrobotClient);
      default:
        break;
    }

    return result;
  }

  onServiceResolved(String host, int port) {
    _state = MainViewState.serviceAvailable;
    _mrobotClient.open(host, port);
  }

  @override
  onClientConnect() {
    _state = MainViewState.serviceConnected;
    setState(() {});
  }

  @override
  onClientDisconnect() {
    _state = MainViewState.serviceSearch;
    setState(() {});
  }

}