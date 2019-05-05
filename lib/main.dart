import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
var input = ValueNotifier(0);
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

              new Tab(text: 'Wearable Connection'),
              new Tab(text: 'Timer')

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

class WearableConnectionView extends StatefulWidget{
  @override
  _WearableConnectionViewState createState() => new _WearableConnectionViewState();
}

class _WearableConnectionViewState extends State with AutomaticKeepAliveClientMixin{

  bool blueOn;
  FlutterBlue _flutterBlue = FlutterBlue.instance;
  List<BluetoothService> services;
  List<BluetoothCharacteristic> characteristics;
  var deviceConnection;
  BluetoothDevice wearable;
  BluetoothDeviceState deviceState;
  BluetoothService vibrationService;
  BluetoothCharacteristic vibrationCharacteristic;
  var _scanSubscription;
  void _scan() async{
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
      showDialog(context: context, builder: (BuildContext context) {
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


        if(s == BluetoothDeviceState.disconnected){
          _disconnect();
          input.removeListener(vibrate);
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
      await wearable.writeCharacteristic(vibrationCharacteristic, [0xFF,0xFF,0xFF,0xFF]);
      showDialog(context: context, builder: (BuildContext context) {
        return AlertDialog(
          title: new Text('VIBRATING'),
          content: new Text('VIBRATING'),
          actions: <Widget>[
            new FlatButton(onPressed: stopVibrating, child: new Text('Close'))
          ],
        );
      });
    }


  }

  void stopVibrating(){
    Navigator.of(context).pop();
    wearable.writeCharacteristic(vibrationCharacteristic, [0x00, 0x00, 0x00, 0x00]);
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
  void saveInput(string){
    if(timerStarted == true){
      setState(() {
        controller.text = '';
      });
      print('Timer Already Started!');
    }
    else {
      print(string);
      input.value = int.tryParse(string);
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
          if (input.value < 1) {
            timer.cancel();
            timerStarted = false;
          } else {
            input.value = input.value - 1;
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
            new Text(input.value.toString(), style: TextStyle(fontSize: 50.0),)
          ],),
        new Row(children: <Widget>[],)
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;


}