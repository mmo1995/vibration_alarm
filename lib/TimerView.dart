import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration_alarm/main.dart';

/*
* TimerView class creates the state for the timer tab
* */
class TimerView extends StatefulWidget{
  @override
  _TimerViewState createState() => new _TimerViewState();
}

/*
* The State of the timer tab view
* */
class _TimerViewState extends State with TickerProviderStateMixin, AutomaticKeepAliveClientMixin{

  final controller = new TextEditingController(); //controller for the text form field
  Timer _timer; //timer
  bool timerStarted = false;

  /*This method saves the input ,string' from the user
  * Then it calls startTimer()
  * */
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

  /*
  * starts the timer
  * */
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

  /*
  changes the intensity of the vibration when user does
  * */
  void changeIntensity(value){
    setState(() {

      intensity = value;
    });
    print(intensity);
  }

  /*
  * build the main view of the timer
  * */
  @override
  Widget build(BuildContext context) {
    return Column(
      //mainAxisAlignment: MainAxisAlignment.spaceAround,
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
        new Row(children: <Widget>[Padding(padding: EdgeInsets.all(30.0))],),
        new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text('Vibration Intinsity:',
              style: TextStyle(fontSize: 20, color: Colors.blue),)],),
        new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new ButtonBar(
              children: <Widget>[
                new Text('low'),
                new Radio(value: 0, groupValue: intensity, onChanged: changeIntensity,activeColor: Colors.blue),
                new Text('medium'),
                new Radio(value: 1, groupValue: intensity, onChanged: changeIntensity, activeColor: Colors.blue),
                new Text('high'),
                new Radio(value: 2, groupValue: intensity, onChanged: changeIntensity, activeColor: Colors.blue)
              ],)
          ],
        ),
        new Row(children: <Widget>[Padding(padding: EdgeInsets.all(10.0))],),
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

  /*
  * keep state of the tab alive when changing between tabs
  * */
  @override
  bool get wantKeepAlive => true;


}