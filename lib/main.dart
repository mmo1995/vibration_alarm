import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:math' as math;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibration Alarm',
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('My Vibration Alarm'),
            bottom: TabBar(tabs: <Widget>[
              new Tab(text: 'Wearable Connection',),
              new Tab(text: 'Timer')

            ]),
          ),
          body: TabBarView(children: [
            new WearableConnectionView(),
            new TimerView()

          ]),
        ),
      ),
    );
  }
}

class WearableConnectionView extends StatefulWidget{
  @override
  _WearableConnectionViewState createState() => new _WearableConnectionViewState();
}

class _WearableConnectionViewState extends State with AutomaticKeepAliveClientMixin{
  bool connected = false;

  void _connect(){
    setState(() {
      connected = true;
    });
    print('connected');
    print(connected);
  }

  void _disconnect(){
    setState(() {
      connected = false;
    });
    print('disconnected');
    print(connected);
  }
  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          connected ?  new Icon(Icons.bluetooth_connected, color: Colors.blue, size: 50.0)
              : const Icon(Icons.bluetooth_disabled, color: Colors.grey, size: 50.0),
        ],
          
        ),
        new Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
            <Widget>[
              new Text(connected? 'Connected': 'Not Connected',
                style: TextStyle(fontSize: 30,
                    color: connected? Colors.blue : Colors.grey),)]),
        new Row(
          children:
          <Widget>[
            new Container(padding: EdgeInsets.all(20.0))],),
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
          new RaisedButton(onPressed: connected ? _disconnect : null,
            child: new Text('Disconnect'),
            color: Colors.red,
            textColor: Colors.white,),
          new RaisedButton(onPressed: connected ? null : _connect,
            child: new Text('Connect'),
            color: Colors.blue,
            textColor: Colors.white,),
        ],),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class TimerView extends StatefulWidget{
  @override
  _TimerViewState createState() => new _TimerViewState();
}

class _TimerViewState extends State with TickerProviderStateMixin {

  final controller = new TextEditingController();
  Timer _timer;
  bool timerStarted = false;
  var input = 0;
  void saveInput(string){
    if(timerStarted == true){
      print('Timer Already Started!');
    }
    else {
      print(string);
      input = int.tryParse(string);
      print('input  $input');
      print("field submitted");
      setState(() {
        controller.text = '';
      });
      startTimer();
    }
  }
  void startTimer() {
    setState(() {
      timerStarted = true;
    });
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
        oneSec,
            (Timer timer) => setState(() {
          if (input < 1) {
            timer.cancel();
            timerStarted = false;
          } else {
            input = input - 1;
          }
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[

            new Flexible(
              child: new TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                      labelText: "Please Set Timer!",
                      hintText: "In Seconds",
                      labelStyle: TextStyle(fontSize: 25),
                      icon: Icon(Icons.access_time)),
                      onFieldSubmitted: saveInput,

              ),
            ),
          ],
        ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>
          [
            new Text('$input', style: TextStyle(fontSize: 50.0),)
          ],),
        new Row(children: <Widget>[],)
      ],
    );
  }


}