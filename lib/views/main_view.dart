import 'package:flutter/material.dart';
import 'package:mrobot_remote/logics/mrobot_client.dart';
import 'package:mrobot_remote/views/service_search_view.dart';

enum MainViewState {
  ServiceSearch,
  ServiceAvailable
}

class MainView extends StatefulWidget {
  const MainView({super.key, required this.title});

  final String title;

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final _mrobotClient = MRobotClient();

  var _state = MainViewState.ServiceSearch;

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
      case MainViewState.ServiceSearch:
        result = ServiceSearchView(onServiceResolvedCallback: onServiceResolved);
        break;
      case MainViewState.ServiceAvailable:
        result = const Text('Not implemented yet');
        break;
      default:
        break;
    }

    return result;
  }

  onServiceResolved(String host, int port) {
    _state = MainViewState.ServiceAvailable;
    setState(() {});
  }

  onServiceLost() {
    _state = MainViewState.ServiceSearch;
    setState(() {});
  }

}