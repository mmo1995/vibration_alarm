import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibration_alarm/WearableConnectionView.dart';
import 'package:vibration_alarm/TimerView.dart';

/*global variables used in both tab views*/
var input = ValueNotifier(0);
var intensity = 0;

/* main method for the app*/
void main() => runApp(MyApp());

/*Main Class*/
class MyApp extends StatelessWidget {

  /*
  * build the main Widget of the app ,MaterialApp'
  * */
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibration Alarm',
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Vibration Timer'),
            bottom: TabBar(
                tabs: <Widget>[
              new Tab(text: 'Wearable Connection'),
              new Tab(text: 'Timer'),

            ]),
          ),
          body: TabBarView(
              children: [
            new WearableConnectionView(),
            new TimerView()

          ]),
        ),
      ),
    );
  }
}





