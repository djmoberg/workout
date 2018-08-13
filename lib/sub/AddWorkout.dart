import 'dart:async';

import 'package:flutter/material.dart';

import 'package:workout/sub/ExerciseList.dart';
import 'package:workout/utils.dart';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseUser;
import 'package:cloud_firestore/cloud_firestore.dart';

class AddWorkout extends StatelessWidget {
  final FirebaseUser _user;

  AddWorkout(this._user);

  @override
  Widget build(BuildContext context) {
    return MyAddWorkout(_user);
  }
}

class MyAddWorkout extends StatefulWidget {
  final FirebaseUser _user;

  MyAddWorkout(this._user);

  @override
  _MyAddWorkoutState createState() => _MyAddWorkoutState(_user);
}

class _MyAddWorkoutState extends State<MyAddWorkout> {
  final FirebaseUser _user;

  _MyAddWorkoutState(this._user);

  String _name = "";
  String _docId = "";

  @override
  void initState() {
    super.initState();
    var docRef = Firestore.instance
        .collection('users')
        .document(_user.uid)
        .collection('workouts')
        .document();
    docRef.setData({"name": "", "exercises": []});
    _docId = docRef.documentID;
  }

  void _saveName() {
    Firestore.instance.runTransaction((transaction) async {
      DocumentSnapshot freshSnap = await transaction.get(Firestore.instance
          .collection('users')
          .document(_user.uid)
          .collection('workouts')
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
          .collection('workouts')
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
          title: Text("New Workout"),
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
                  .collection('workouts')
                  .document(_docId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Text("Loading...");
                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemExtent: 80.0,
                    itemCount: snapshot.data['exercises'].length,
                    itemBuilder: (context, index) {
                      var id = List.from(snapshot.data['exercises'])[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: FutureBuilder(
                          future: getExercise(id, _user.uid),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            return ListTile(
                              title: Text(snapshot.data['name']),
                              subtitle: Text(
                                  totalTimeString(snapshot.data['objects'])),
                              trailing: Icon(Icons.drag_handle),
                            );
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
          onPressed: () async {
            String id = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return ExerciseList(_user);
                },
              ),
            );
            if (id != null) {
              Firestore.instance.runTransaction((transaction) async {
                DocumentSnapshot freshSnap = await transaction.get(Firestore
                    .instance
                    .collection('users')
                    .document(_user.uid)
                    .collection('workouts')
                    .document(_docId));
                List<dynamic> newList = List.from(freshSnap['exercises']);
                newList.add(id);
                await transaction
                    .update(freshSnap.reference, {"exercises": newList});
              });
            }
          },
        ),
      ),
    );
  }
}
