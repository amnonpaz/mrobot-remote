import 'package:flutter/material.dart';
import 'package:mrobot_remote/views/main_view.dart';

void main() {
  runApp(const MRobotRemoteApplication());
}

class MRobotRemoteApplication extends StatelessWidget {
  const MRobotRemoteApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mRobot remote',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
      ),
      home: const MainView(title: 'mRobot remote controller'),
    );
  }
}