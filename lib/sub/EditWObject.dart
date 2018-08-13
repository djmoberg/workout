import 'package:flutter/material.dart';

import 'package:numberpicker/numberpicker.dart';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseUser;
import 'package:cloud_firestore/cloud_firestore.dart';

class EditWObject extends StatelessWidget {
  final FirebaseUser _user;
  final Map<String, dynamic> _data;

  EditWObject(this._user, this._data);

  @override
  Widget build(BuildContext context) {
    return MyEditWObject(_user, _data);
  }
}

class MyEditWObject extends StatefulWidget {
  final FirebaseUser _user;
  final Map<String, dynamic> _data;

  MyEditWObject(this._user, this._data);

  @override
  _MyEditWObjectState createState() => _MyEditWObjectState(_user, _data);
}

class _MyEditWObjectState extends State<MyEditWObject> {
  final FirebaseUser _user;
  final Map<String, dynamic> _data;

  _MyEditWObjectState(this._user, this._data);

  String _name;
  TextEditingController _controller;
  bool _timed;
  int _minutes;
  int _seconds;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _data['name']);
    _name = _data['name'];
    _timed = _data['time'] != 0;
    _minutes = Duration(milliseconds: _data['time']).inMinutes;
    _seconds = ((_data['time'] / 1000) % 60).round();
  }

  Widget _timePicker() {
    if (!_timed)
      return SizedBox(
        height: 0.0,
      );
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text("Minutes"),
            Text("Seconds"),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            NumberPicker.integer(
                initialValue: _minutes,
                minValue: 0,
                maxValue: 59,
                onChanged: (value) {
                  setState(() {
                    _minutes = value;
                  });
                }),
            Text(
              ":",
              style: Theme.of(context).textTheme.display1,
            ),
            NumberPicker.integer(
                initialValue: _seconds,
                minValue: 0,
                maxValue: 59,
                onChanged: (value) {
                  setState(() {
                    _seconds = value;
                  });
                }),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _name == null
                ? null
                : () async {
                    Firestore.instance.runTransaction((transaction) async {
                      DocumentSnapshot freshSnap = await transaction.get(
                          Firestore.instance
                              .collection('users')
                              .document(_user.uid)
                              .collection('exercises')
                              .document(_data['id']));
                      List<dynamic> newList = List.from(freshSnap['objects']);
                      newList.removeAt(_data['index']);
                      newList.insert(_data['index'], {
                        "name": _name,
                        "time": Duration(minutes: _minutes, seconds: _seconds)
                            .inMilliseconds
                      });
                      await transaction
                          .update(freshSnap.reference, {"objects": newList});

                      Navigator.pop(context);
                    });
                  },
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          Center(
            child: RaisedButton(
              child: Text("Delete"),
              onPressed: () async {
                Firestore.instance.runTransaction((transaction) async {
                  DocumentSnapshot freshSnap = await transaction.get(Firestore
                      .instance
                      .collection('users')
                      .document(_user.uid)
                      .collection('exercises')
                      .document(_data['id']));
                  List<dynamic> newList = List.from(freshSnap['objects']);
                  newList.removeAt(_data['index']);

                  await transaction
                      .update(freshSnap.reference, {"objects": newList});

                  Navigator.pop(context);
                });
              },
            ),
          ),
          TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: "Name"),
            textCapitalization: TextCapitalization.sentences,
            onChanged: (value) {
              setState(() {
                _name = value.length == 0 ? null : value;
              });
            },
          ),
          SizedBox(
            height: 32.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text("Timed?"),
              Switch(
                onChanged: (value) {
                  setState(() {
                    _timed = value;
                    _seconds = 0;
                    _minutes = 0;
                  });
                },
                value: _timed,
              ),
            ],
          ),
          SizedBox(
            height: 32.0,
          ),
          _timePicker(),
        ],
      ),
    );
  }
}
