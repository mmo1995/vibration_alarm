import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'main.dart';

/*
* WearableConnectionView class creates the state for the wearable connection tab
* */
class WearableConnectionView extends StatefulWidget{
  @override
  _WearableConnectionViewState createState() => new _WearableConnectionViewState();
}

/*
* The State of the wearable connection tab view
* */
class _WearableConnectionViewState extends State with AutomaticKeepAliveClientMixin{

  bool blueOn;
  bool connecting = false;
  FlutterBlue _flutterBlue = FlutterBlue.instance;
  List<BluetoothService> services;
  List<BluetoothCharacteristic> characteristics;
  var deviceConnection;
  BluetoothDevice wearable;
  BluetoothDeviceState deviceState;
  BluetoothService vibrationService;
  BluetoothCharacteristic vibrationCharacteristic;
  var _scanSubscription;

  /*
  * scans for the wearable
  * if adapter On -> start connecting
  * else -> show dialog with hint to the user
  * */
  void _scan() async{
    setState(() {
      connecting = true;
    });

    blueOn = await _flutterBlue.isOn;
    if(blueOn){
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
    else{
      setState(() {
        connecting = false;
      });
      showDialog(barrierDismissible: false, context: context, builder: (BuildContext context) {
        return AlertDialog(
          title: new Text('Bluetooth Adapter is off'),
          content: new Text('Please Turn it on and connect again!'),
          actions: <Widget>[
            new FlatButton(onPressed: () {
              Navigator.of(context).pop();
            }, child: new Text('Close'))
          ],
        );
      });
      print('Bluetooth Off!');

    }


  }
  /*
  * connecting the wearable
  * if found -> start connecting
  * else -> show dialog with hint to the user (wearable not found)
  * */
  void _connect() async{

    _scanSubscription?.cancel();
    _scanSubscription = null;
    if(wearable != null){
      deviceConnection = _flutterBlue
          .connect(wearable, timeout: const Duration(seconds: 15))
          .listen(
        null,
      );

      input.addListener(vibrate);

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

        if(s == BluetoothDeviceState.connected){
          setState(() {
            connecting = false;
          });
        }
        if(s == BluetoothDeviceState.disconnected){
          _disconnect();
          input.removeListener(vibrate);
        }
      });
    }
    else{
      showDialog(barrierDismissible: false, context: context, builder: (BuildContext context) {
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
      setState(() {
        connecting = false;
      });
    }
  }

  /*
  * disconnect connection of the wearable
  * */
  void _disconnect(){
    deviceConnection?.cancel();
    input.removeListener(vibrate);
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

  /*
  * start vibrating the wearable
  * */
  void vibrate() async{

    if(input.value == 0){
      services = await wearable.discoverServices();
      services.forEach((service) {
        if(service.uuid == new Guid('713d0000-503e-4c75-ba94-3148f18d941e')){
          vibrationService = service;
        }
      });

      characteristics = vibrationService.characteristics;
      for(BluetoothCharacteristic c in characteristics){
        if(c.uuid == new Guid('713D0003-503E-4C75-BA94-3148F18D941E')){
          vibrationCharacteristic = c;
        }
      }
      switch (intensity){
        case 0:
          await wearable.writeCharacteristic(vibrationCharacteristic, [0x77,0x00,0x77,0x00]);
          break;
        case 1:
          await wearable.writeCharacteristic(vibrationCharacteristic, [0x00,0xCC,0x00,0xCC]);
          break;
        case 2:
          await wearable.writeCharacteristic(vibrationCharacteristic, [0xFF,0xFF,0xFF,0xFF]);
          break;
        default:
          await wearable.writeCharacteristic(vibrationCharacteristic, [0x77,0x00,0x77,0x00]);
          break;
      }

      showDialog(barrierDismissible: false, context: context, builder: (BuildContext context) {
        return AlertDialog(
          title: new Text('Alarm'),
          content: new Text('Vibrating!'),
          actions: <Widget>[
            new FlatButton(onPressed: stopVibrating, child: new Text('Stop'))
          ],
        );
      });
    }
  }

  /*
  * stop vibrating of the wearable
  * */
  void stopVibrating(){
    Navigator.of(context).pop();
    wearable.writeCharacteristic(vibrationCharacteristic, [0x00, 0x00, 0x00, 0x00]);
  }

  /*
  * build the main view of the wearable connection
  * */
  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(connecting? 'Connecting...' : '',
              style: TextStyle(fontSize: 25.0, color: Colors.grey),)],),
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

  /*
  * keep state of the tab alive when changing between tabs
  * */
  @override
  bool get wantKeepAlive => true;
}