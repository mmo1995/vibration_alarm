import 'package:flutter/material.dart';

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
            new MyClass(),
            new MySecondClass()

          ]),
        ),
      ),
    );
  }
}

class MyClass extends StatelessWidget{

  void _connect(){
    print('connected');
  }
  void _disconnect(){
    print('disconnected');
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
      new RaisedButton(onPressed: _connect,
        child: new Text('Connect'),
        color: Colors.blue,
        textColor: Colors.white,),
    ],);
  }
}

class MySecondClass extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return new Text('second tab');
  }

}