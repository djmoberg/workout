import 'dart:async';
import 'dart:io';
// import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:screen/screen.dart';

import 'package:workout/utils.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseUser;

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

enum PlayerState { stopped, playing, paused }

class _MyExercisePlayState extends State<MyExercisePlay> {
  final DocumentSnapshot _doc;

  _MyExercisePlayState(this._doc);

  AudioPlayer audioPlayer;
  // StreamSubscription _audioPlayerStateSubscription;
  PlayerState playerState = PlayerState.playing;

  // int _startTime = 0;
  int _endTime = 0;
  int _currentIndex = 0;
  int _currentTime;
  Timer _timer;
  bool _done = false;
  bool _paused = false;
  String _longBeepPath;
  String _beepPath;
  bool _tapStop = false;

  ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    Screen.keepOn(true);
    var timedList = Map<String, dynamic>.from(
        List.from(_doc.data['objects'])[_currentIndex]);
    _currentTime = timedList['time'];
    _loadFiles();
    _loadFiles2();
    initAudioPlayer();
    _start(timedList['time']);
  }

  @override
  void dispose() {
    // _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    Screen.keepOn(false);
    super.dispose();
  }

  Future<ByteData> loadAsset() async {
    return await rootBundle.load('sounds/beep_long.mp3');
  }

  Future _loadFiles() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    final file = new File('$tempPath/beep_long.mp3');
    await file.writeAsBytes((await loadAsset()).buffer.asUint8List());
    setState(() {
      _longBeepPath = file.path;
    });
  }

  Future<ByteData> loadAsset2() async {
    return await rootBundle.load('sounds/beep.mp3');
  }

  Future _loadFiles2() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    final file = new File('$tempPath/beep.mp3');
    await file.writeAsBytes((await loadAsset2()).buffer.asUint8List());
    setState(() {
      _beepPath = file.path;
    });
  }

  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();

    // _audioPlayerStateSubscription =
    //     audioPlayer.onPlayerStateChanged.listen((s) {
    //   if (s == AudioPlayerState.playing) {
    //     setState(() {
    //       playerState = PlayerState.playing;
    //     });
    //   }
    // }, onError: (msg) {
    //   setState(() {
    //     playerState = PlayerState.playing;
    //   });
    // });
  }

  Future _playLongBeep() async {
    // setState(() {
    //   playerState = PlayerState.playing;
    // });
    await audioPlayer.play(_longBeepPath, isLocal: true);
  }

  Future _playBeep() async {
    await audioPlayer.play(_beepPath, isLocal: true);
  }

  void _start(int time) {
    setState(() {
      _endTime = DateTime.now().millisecondsSinceEpoch + time;
    });
    _timer = Timer.periodic(Duration(milliseconds: 100), _updateTime);
  }

  void _updateTime(timer) {
    // if (_currentTime <= 5010 && _currentTime >= 4990) {
    if (_currentTime <= 100) {
      _playLongBeep();
    }
    if (_currentTime <= 3050 && _currentTime >= 2950 ||
        _currentTime <= 2050 && _currentTime >= 1950 ||
        _currentTime <= 1050 && _currentTime >= 950) {
      _playBeep();
    }
    if (_currentTime <= 100) {
      if (_currentIndex + 1 >= _doc.data['objects'].length) {
        _timer.cancel();
        setState(() {
          _done = true;
        });
        _updateStats();
      }

      var timedList = Map<String, dynamic>.from(
          List.from(_doc.data['objects'])[_currentIndex + 1]);

      setState(() {
        _currentIndex++;
      });
      setState(() {
        _endTime =
            DateTime.now().millisecondsSinceEpoch + timedList['time']; // + 1000
      });
      setState(() {
        _currentTime = timedList['time'];
      });

      _controller.animateTo((0.0),
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);

      if (timedList['time'] == 0) {
        _timer.cancel();
        setState(() {
          _tapStop = true;
        });
      }
    } else {
      print(_currentTime);
      // if (_currentTime < 3020 && _currentTime > 2980) {
      //   _playLongBeep();
      // }
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

  void _updateStats() {
    Firestore.instance.runTransaction((transaction) async {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      DocumentSnapshot freshSnap = await transaction
          .get(Firestore.instance.collection('users').document(user.uid));
      List<dynamic> newList = List.from(freshSnap['stats']);
      newList.add(DateTime.now().millisecondsSinceEpoch);
      await transaction.update(freshSnap.reference, {"stats": newList});
    });
  }

  @override
  Widget build(BuildContext context) {
    var timedList = Map<String, dynamic>.from(
        List.from(_doc.data['objects'])[_currentIndex]);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: Colors.red,
                child: ListTile(
                  onTap: () {
                    if (_tapStop) {
                      setState(() {
                        _paused = false;
                        _endTime = DateTime.now().millisecondsSinceEpoch +
                            _currentTime;
                      });
                      setState(() {
                        _tapStop = false;
                      });
                      _timer = Timer.periodic(
                          Duration(milliseconds: 100), _updateTime);
                    }
                  },
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
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              _tapStop
                                  ? "Tap To Continue"
                                  : formatTime(_currentTime),
                              style: _tapStop
                                  ? Theme.of(context).textTheme.display1
                                  : Theme.of(context).textTheme.display3,
                            ),
                            // Text(
                            //   _tapStop ? "Tap To Continue" : "",
                            //   style: Theme.of(context).textTheme.headline,
                            // )
                          ],
                        ),
                ),
              ),
            ),
            // Text(playerState.toString()),
            Expanded(
              child: ListView.builder(
                controller: _controller,
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
                          textAlign: TextAlign.center,
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: Row(
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
                    Timer.periodic(Duration(milliseconds: 100), _updateTime);
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
