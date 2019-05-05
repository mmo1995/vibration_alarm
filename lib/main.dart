import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibration_alarm/WearableConnectionView.dart';
import 'package:vibration_alarm/TimerView.dart';
import 'package:vibration_alarm/AlarmView.dart';

var input = ValueNotifier(0);
var intensity = 0;
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibration Alarm',
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text('My Vibration Alarm'),
            bottom: TabBar(
                tabs: <Widget>[

              new Tab(text: 'Wearable Connection'),
              new Tab(text: 'Alarm'),
              new Tab(text: 'Timer'),

            ]),
          ),
          body: TabBarView(
              children: [
            new WearableConnectionView(),
            new AlarmView(),
            new TimerView()

          ]),
        ),
      ),
    );
  }
}





