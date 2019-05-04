import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

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

class TimerView extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return new Text('second tab');
  }

}