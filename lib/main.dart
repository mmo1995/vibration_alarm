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

  @override
  Widget build(BuildContext context) {

    return new Text('first tab');
  }
}

class MySecondClass extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return new Text('second tab');
  }

}