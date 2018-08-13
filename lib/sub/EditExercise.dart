import 'dart:async';

import 'package:flutter/material.dart';

import 'package:workout/sub/AddWObject.dart';
import 'package:workout/sub/EditWObject.dart';
import 'package:workout/utils.dart';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseUser;
import 'package:cloud_firestore/cloud_firestore.dart';

class EditExercise extends StatelessWidget {
  final FirebaseUser _user;
  final DocumentSnapshot _doc;

  EditExercise(this._user, this._doc);

  @override
  Widget build(BuildContext context) {
    return MyEditExercise(_user, _doc);
  }
}

class MyEditExercise extends StatefulWidget {
  final FirebaseUser _user;
  final DocumentSnapshot _doc;

  MyEditExercise(this._user, this._doc);

  @override
  _MyEditExerciseState createState() => _MyEditExerciseState(_user, _doc);
}

class _MyEditExerciseState extends State<MyEditExercise> {
  final FirebaseUser _user;
  final DocumentSnapshot _doc;

  _MyEditExerciseState(this._user, this._doc);

  String _name = "";
  String _docId = "";
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _docId = _doc.documentID;
    _controller = TextEditingController(text: _doc.data['name']);
    _name = _doc.data['name'];
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Edit Exercise"),
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
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: "Name"),
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
                    // itemExtent: 80.0,
                    itemCount: snapshot.data['objects'].length,
                    itemBuilder: (context, index) {
                      var list = Map<String, dynamic>.from(
                          List.from(snapshot.data['objects'])[index]);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ListTile(
                          // leading: Icon(Icons.sentiment_very_satisfied),
                          title: Text(list['name']),
                          // subtitle: Text(covertTime(list['time'])),
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
