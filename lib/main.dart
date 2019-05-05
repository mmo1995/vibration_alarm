import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            bottom: TabBar(
                tabs: <Widget>[

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

  FlutterBlue _flutterBlue = FlutterBlue.instance;
  List<BluetoothService> services;
  var deviceConnection;
  BluetoothDevice wearable;
  BluetoothDeviceState deviceState;
  var _scanSubscription;
  void _scan(){
    _scanSubscription = _flutterBlue
        .scan(
      timeout: const Duration(seconds: 5)
    )
        .listen((scanResult) {
      if(scanResult.device.name == 'TECO Wearable 3'){
        wearable = scanResult.device;
      }


    }, onDone: _connect);


  }
  void _connect() async{
    _scanSubscription?.cancel();
    _scanSubscription = null;
    if(wearable != null){
      deviceConnection = _flutterBlue
          .connect(wearable, timeout: const Duration(seconds: 15))
          .listen(
        null,
      );

      wearable.state.then((s) {
        setState(() {
          deviceState = s;
        });

        print(wearable.state.toString());
      });
      wearable.onStateChanged().listen((s){
        setState(() {
          deviceState =s;
        });


        if(s == BluetoothDeviceState.disconnected){
          _disconnect();
        }
      });
    }
    else{
      showDialog(context: context, builder: (BuildContext context) {
        return AlertDialog(
          title: new Text('Wearable not found'),
          content: new Text('Please Try connecting again!'),
          actions: <Widget>[
            new FlatButton(onPressed: () {
              Navigator.of(context).pop();
            }, child: new Text('Close'))
          ],
        );
      });
      print('wearable not found!');
    }
  }

  void _disconnect(){
    deviceConnection?.cancel();
    wearable.state.then((s) {
      setState(() {
        deviceState = s;
        print('deviceState: '+deviceState.toString());
      });
      setState(() {
        wearable = null;
      });
      print('disconnected');
    });
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          (deviceState == BluetoothDeviceState.connected) ?  new Icon(Icons.bluetooth_connected, color: Colors.blue, size: 50.0)
              : const Icon(Icons.bluetooth_disabled, color: Colors.grey, size: 50.0),
        ],
          
        ),
        new Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
            <Widget>[
              new Text((deviceState == BluetoothDeviceState.connected)? 'Connected': 'Not Connected',
                style: TextStyle(fontSize: 30,
                    color: (deviceState == BluetoothDeviceState.connected)? Colors.blue : Colors.grey),)]),
        new Row(
          children:
          <Widget>[
            new Container(padding: EdgeInsets.all(20.0))],),
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
          new RaisedButton(onPressed: (deviceState == BluetoothDeviceState.connected) ? _disconnect : null,
            child: new Text('Disconnect'),
            color: Colors.red,
            textColor: Colors.white,),
          new RaisedButton(onPressed: (deviceState == BluetoothDeviceState.connected) ? null : _scan,
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

class _TimerViewState extends State with TickerProviderStateMixin, AutomaticKeepAliveClientMixin{

  final controller = new TextEditingController();
  Timer _timer;
  bool timerStarted = false;
 var input = 0;
  void saveInput(string){
    if(timerStarted == true){
      setState(() {
        controller.text = '';
      });
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
                      labelText: timerStarted? "Timer is Running!" : "Please Set Timer!",
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

  @override
  bool get wantKeepAlive => true;


}