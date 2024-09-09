import 'package:flutter/material.dart';
import 'package:mrobot_remote/logics/service_dicoverer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mRobot remote',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'mRobot remote controller'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _serviceDiscoverer = ServiceDiscoverer();

  @override
  void initState() {
    super.initState();
    _serviceDiscoverer.discover(onServiceDiscoveryDone);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(getServiceDiscoveryStateText())
          ],
        ),
      ),
    );
  }

  onServiceDiscoveryDone() {
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
      case ServiceDiscovererState.serviceNotFound:
        text = 'Service not found';
        break;
      case ServiceDiscovererState.serviceFound:
        text = 'Service found on ${_serviceDiscoverer.host()}:${_serviceDiscoverer.port()}';
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
