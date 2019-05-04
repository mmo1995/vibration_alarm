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

 FlutterBlue _flutterBlue = FlutterBlue.instance;
 StreamSubscription _scanSubscription;
  bool _isButtonDisabled = false;
 BluetoothDevice wearable;


  void _scan(){

      _scanSubscription = _flutterBlue
          .scan(
        timeout: const Duration(seconds: 5),
      )
          .listen((scanResult) {
            print(scanResult.device.name);
        if(scanResult.device.name == 'TECO Wearable 3'){
          wearable = scanResult.device;
        }
      }, onDone: _connect);


  }
  void _connect(){
    if(wearable == null){
      print('wearable not found');
    }
    else{
      _flutterBlue.connect(wearable).listen((s) async{
        if(BluetoothDeviceState.connected == s){
          print(wearable.name);
          print('connected');
          _isButtonDisabled = true;
        }
        else if(BluetoothDeviceState.disconnected == s){
          _disconnect();
        }
        else{
          print('could not connect');
        }
      });

    }
  }

  void _disconnect(){
    wearable = null;
    print('disconnected');
    _isButtonDisabled = false;
  }
  @override
  Widget build(BuildContext context) {

    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
      new RaisedButton(onPressed: _disconnect,
        child: new Text('Disconnect'),
        color: Colors.red,
        textColor: Colors.white,),
      new RaisedButton(onPressed: _isButtonDisabled ? null : _scan,
        child: new Text('Connect'),
        color: Colors.blue,
        textColor: Colors.white,),
    ],);
  }
}

class MySecondTabView extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return new Text('second tab');
  }

}