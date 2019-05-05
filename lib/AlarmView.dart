import 'package:flutter/material.dart';
import 'main.dart';


class AlarmView extends StatefulWidget{
  @override
  _AlarmViewState createState() => new _AlarmViewState();
}


class _AlarmViewState extends State with AutomaticKeepAliveClientMixin{

  @override
  Widget build(BuildContext context) {

    return new Text('alarm');
  }
  @override
  bool get wantKeepAlive => true;

}