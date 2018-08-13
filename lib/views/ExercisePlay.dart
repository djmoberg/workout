import 'dart:async';

import 'package:flutter/material.dart';

import 'package:workout/utils.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class ExercisePlay extends StatelessWidget {
  final DocumentSnapshot _doc;

  ExercisePlay(this._doc);

  @override
  Widget build(BuildContext context) {
    return MyExercisePlay(_doc);
  }
}

class MyExercisePlay extends StatefulWidget {
  final DocumentSnapshot _doc;

  MyExercisePlay(this._doc);

  @override
  _MyExercisePlayState createState() => _MyExercisePlayState(_doc);
}

class _MyExercisePlayState extends State<MyExercisePlay> {
  final DocumentSnapshot _doc;

  _MyExercisePlayState(this._doc);

  // int _startTime = 0;
  int _endTime = 0;
  int _currentIndex = 0;
  int _currentTime;
  Timer _timer;
  bool _done = false;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    var timedList = Map<String, dynamic>.from(
        List.from(_doc.data['objects'])[_currentIndex]);
    _currentTime = timedList['time'];
    _start(timedList['time']);
  }

  void _start(int time) {
    setState(() {
      _endTime = DateTime.now().millisecondsSinceEpoch + time;
    });
    _timer = Timer.periodic(Duration(milliseconds: 10), _updateTime);
  }

  void _updateTime(timer) {
    if (_currentTime <= 0) {
      if (_currentIndex + 1 >= _doc.data['objects'].length) {
        _timer.cancel();
        setState(() {
          _done = true;
        });
      }
      var timedList = Map<String, dynamic>.from(
          List.from(_doc.data['objects'])[_currentIndex + 1]);
      setState(() {
        _currentIndex++;
      });
      setState(() {
        _endTime =
            DateTime.now().millisecondsSinceEpoch + timedList['time'] + 1000;
        _currentTime = timedList['time'];
      });
    } else {
      setState(() {
        _currentTime = _endTime - DateTime.now().millisecondsSinceEpoch;
      });
    }
  }

  Widget _backButton() {
    if (_done || _paused) {
      return RaisedButton(
        child: Text("Back"),
        onPressed: () {
          Navigator.pop(context);
        },
      );
    } else {
      return SizedBox(
        height: 0.0,
      );
    }
  }

  // Widget _resetButton() {
  //   if (_paused) {
  //     return RaisedButton(
  //       child: Text("Reset"),
  //       onPressed: () {},
  //     );
  //   } else {
  //     return SizedBox(
  //       height: 0.0,
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var timedList = Map<String, dynamic>.from(
        List.from(_doc.data['objects'])[_currentIndex]);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: Column(
          children: <Widget>[
            Card(
              color: Colors.red,
              child: ListTile(
                title: _done
                    ? Column(
                        children: <Widget>[
                          Text(
                            "Done",
                            style: Theme.of(context).textTheme.display2,
                          ),
                          Text(
                            "00:00",
                            style: Theme.of(context).textTheme.display3,
                          ),
                        ],
                      )
                    : Column(
                        children: <Widget>[
                          Text(
                            timedList['name'],
                            style: Theme.of(context).textTheme.display2,
                          ),
                          Text(
                            formatTime(_currentTime),
                            style: Theme.of(context).textTheme.display3,
                          )
                        ],
                      ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _doc.data['objects'].length,
              itemBuilder: (context, index) {
                var list = Map<String, dynamic>.from(
                    List.from(_doc.data['objects'])[index]);
                if (index <= _currentIndex)
                  return SizedBox(
                    height: 0.0,
                  );
                return ListTile(
                  title: Column(
                    children: <Widget>[
                      Text(
                        list['name'],
                        style: Theme.of(context).textTheme.display2,
                      ),
                      Text(
                        formatTime(list['time']),
                        style: Theme.of(context).textTheme.display3,
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomSheet: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _backButton(),
          // _resetButton(),
        ],
      ),
      floatingActionButton: _paused
          ? FloatingActionButton(
              child: Icon(Icons.play_arrow),
              onPressed: () {
                setState(() {
                  _paused = false;
                  _endTime =
                      DateTime.now().millisecondsSinceEpoch + _currentTime;
                });
                _timer =
                    Timer.periodic(Duration(milliseconds: 10), _updateTime);
              },
            )
          : FloatingActionButton(
              child: Icon(Icons.pause),
              onPressed: () {
                setState(() {
                  _currentTime =
                      _endTime - DateTime.now().millisecondsSinceEpoch;
                  _paused = true;
                });
                _timer.cancel();
              },
            ),
    );
  }
}
