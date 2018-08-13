import 'package:flutter/material.dart';

import 'package:numberpicker/numberpicker.dart';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseUser;
import 'package:cloud_firestore/cloud_firestore.dart';

class AddWObject extends StatelessWidget {
  final FirebaseUser _user;
  final String _docId;

  AddWObject(this._user, this._docId);

  @override
  Widget build(BuildContext context) {
    return MyAddWObject(_user, _docId);
  }
}

class MyAddWObject extends StatefulWidget {
  final FirebaseUser _user;
  final String _docId;

  MyAddWObject(this._user, this._docId);

  @override
  _MyAddWObjectState createState() => _MyAddWObjectState(_user, _docId);
}

class _MyAddWObjectState extends State<MyAddWObject> {
  final FirebaseUser _user;
  final String _docId;

  _MyAddWObjectState(this._user, this._docId);

  String _name;
  bool _timed = true;
  int _minutes = 0;
  int _seconds = 0;

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
                initialValue: 0,
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
                initialValue: 0,
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
        title: Text("Add"),
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
                              .document(_docId));
                      List<dynamic> newList = List.from(freshSnap['objects']);
                      newList.add({
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
              child: Text("Saved"),
              onPressed: () {},
            ),
          ),
          TextField(
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
