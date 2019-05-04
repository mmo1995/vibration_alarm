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
              new Tab(text: 'first tab',),
              new Tab(text: 'second tab')

            ]),
          ),
          body: TabBarView(children: [
            new MyFirstTabView(),
            new MySecondTabView()

          ]),
        ),
      ),
    );
  }
}

class MyFirstTabView extends StatefulWidget{
  @override
  _MyFirstTabViewState createState() => new _MyFirstTabViewState();
}

class _MyFirstTabViewState extends State{
  bool connected;

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
          connected ?  new Icon(Icons.bluetooth_connected)
              : const Icon(Icons.bluetooth_disabled),
        ],
        ),
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
}

class MySecondTabView extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return new Text('second tab');
  }

}