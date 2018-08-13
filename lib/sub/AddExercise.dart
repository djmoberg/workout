import 'dart:async';

import 'package:flutter/material.dart';

import 'package:workout/sub/AddWObject.dart';
import 'package:workout/utils.dart';
import 'package:workout/sub/EditWObject.dart';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseUser;
import 'package:cloud_firestore/cloud_firestore.dart';

class AddExercise extends StatelessWidget {
  final FirebaseUser _user;

  AddExercise(this._user);

  @override
  Widget build(BuildContext context) {
    return MyAddExercise(_user);
  }
}

class MyAddExercise extends StatefulWidget {
  final FirebaseUser _user;

  MyAddExercise(this._user);

  @override
  _MyAddExerciseState createState() => _MyAddExerciseState(_user);
}

class _MyAddExerciseState extends State<MyAddExercise> {
  final FirebaseUser _user;

  _MyAddExerciseState(this._user);

  String _name = "";
  String _docId = "";

  @override
  void initState() {
    super.initState();
    var docRef = Firestore.instance
        .collection('users')
        .document(_user.uid)
        .collection('exercises')
        .document();
    docRef.setData({"name": "", "objects": []});
    _docId = docRef.documentID;
  }

  void _saveName() {
    Firestore.instance.runTransaction((transaction) async {
      DocumentSnapshot freshSnap = await transaction.get(Firestore.instance
          .collection('users')
          .document(_user.uid)
          .collection('exercises')
          .document(_docId));

      await transaction.update(freshSnap.reference, {"name": _name});
      Navigator.pop(context);
    });
  }

  Future<bool> _onBackPressed() async {
    await Firestore.instance.runTransaction((transaction) async {
      DocumentSnapshot freshSnap = await transaction.get(Firestore.instance
          .collection('users')
          .document(_user.uid)
          .collection('exercises')
          .document(_docId));

      await transaction.update(freshSnap.reference, {"name": _name});
    });
    return true;
  }

  void _addPause(int seconds) {
    Firestore.instance.runTransaction((transaction) async {
      DocumentSnapshot freshSnap = await transaction.get(Firestore.instance
          .collection('users')
          .document(_user.uid)
          .collection('exercises')
          .document(_docId));
      List<dynamic> newList = List.from(freshSnap['objects']);
      newList.add({
        "name": "Pause",
        "time": Duration(minutes: 0, seconds: seconds).inMilliseconds
      });
      await transaction.update(freshSnap.reference, {"objects": newList});
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text("New Exercise"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: _name == null
                  ? null
                  : () {
                      _saveName();
                    },
            )
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                child: Text("Pause (5)"),
                onPressed: () => _addPause(5),
              ),
              RaisedButton(
                child: Text("Pause (10)"),
                onPressed: () => _addPause(10),
              ),
              RaisedButton(
                child: Text("Pause (15)"),
                onPressed: () => _addPause(15),
              ),
            ],
          ),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: TextField(
                decoration: InputDecoration(labelText: "Name"),
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                },
              ),
            ),
            StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .document(_user.uid)
                  .collection('exercises')
                  .document(_docId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Text("Loading...");
                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemExtent: 80.0,
                    itemCount: snapshot.data['objects'].length,
                    itemBuilder: (context, index) {
                      var list = Map<String, dynamic>.from(
                          List.from(snapshot.data['objects'])[index]);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ListTile(
                          // leading: Icon(Icons.sentiment_very_satisfied),
                          title: Text(list['name']),
                          trailing: Text(covertTime(list['time'])),
                          onTap: () {
                            Map<String, dynamic> data = list;
                            data.putIfAbsent("index", () => index);
                            data.putIfAbsent("id", () => _docId);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return EditWObject(_user, data);
                            }));
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return AddWObject(_user, _docId);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
