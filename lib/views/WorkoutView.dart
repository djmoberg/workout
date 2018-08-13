import 'dart:async';

import 'package:flutter/material.dart';

import 'package:workout/views/ExercisePlaySound.dart';
import 'package:workout/utils.dart';
// import 'package:workout/sub/AddWObject.dart';
// import 'package:workout/sub/EditExercise.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseUser;
import 'package:flutter_list_drag_and_drop/drag_and_drop_list.dart';
// import 'package:flutter_list_drag_and_drop/my_draggable.dart';

class WorkoutView extends StatelessWidget {
  final DocumentSnapshot _doc;
  final FirebaseUser _user;

  WorkoutView(this._doc, this._user);

  @override
  Widget build(BuildContext context) {
    return MyWorkoutView(_doc, _user);
  }
}

class MyWorkoutView extends StatefulWidget {
  final DocumentSnapshot _doc;
  final FirebaseUser _user;

  MyWorkoutView(this._doc, this._user);

  @override
  _MyWorkoutViewState createState() => _MyWorkoutViewState(_doc, _user);
}

class _MyWorkoutViewState extends State<MyWorkoutView> {
  DocumentSnapshot _doc;
  final FirebaseUser _user;

  _MyWorkoutViewState(this._doc, this._user);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('users')
          .document(_user.uid)
          .collection('workouts')
          .document(_doc.documentID)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        return Scaffold(
          appBar: AppBar(
            title: Text(snapshot.data['name']),
          ),
          body: DragAndDropList(
            snapshot.data['exercises'],
            itemBuilder: (context, item) {
              return FutureBuilder(
                future: getExercise(item, _user.uid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      child: Card(
                        child: ListTile(
                          subtitle: Text(totalTimeString(
                              List.from(snapshot.data['objects']))),
                          title: Text(snapshot.data['name']),
                          trailing: Icon(Icons.drag_handle),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            onDragFinish: (before, after) {
              var list = List.from(snapshot.data['exercises']);
              var data = list[before];
              list.removeAt(before);
              list.insert(after, data);
              Firestore.instance.runTransaction((transaction) async {
                DocumentSnapshot freshSnap = await transaction.get(Firestore
                    .instance
                    .collection('users')
                    .document(_user.uid)
                    .collection('workouts')
                    .document(_doc.documentID));

                await transaction
                    .update(freshSnap.reference, {"exercises": list});
              });
            },
            canBeDraggedTo: (oldIndex, newIndex) => true,
            dragElevation: 8.0,
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.play_arrow),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ExercisePlay(snapshot.data);
              }));
            },
          ),
        );
      },
    );
  }
}
