import 'package:flutter/material.dart';

import 'package:workout/views/ExercisePlaySound.dart';
import 'package:workout/utils.dart';
// import 'package:workout/sub/AddWObject.dart';
import 'package:workout/sub/EditExercise.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseUser;
import 'package:flutter_list_drag_and_drop/drag_and_drop_list.dart';
// import 'package:flutter_list_drag_and_drop/my_draggable.dart';

class ExerciseView extends StatelessWidget {
  final DocumentSnapshot _doc;
  final FirebaseUser _user;

  ExerciseView(this._doc, this._user);

  @override
  Widget build(BuildContext context) {
    return MyExerciseView(_doc, _user);
  }
}

class MyExerciseView extends StatefulWidget {
  final DocumentSnapshot _doc;
  final FirebaseUser _user;

  MyExerciseView(this._doc, this._user);

  @override
  _MyExerciseViewState createState() => _MyExerciseViewState(_doc, _user);
}

class _MyExerciseViewState extends State<MyExerciseView> {
  DocumentSnapshot _doc;
  final FirebaseUser _user;

  _MyExerciseViewState(this._doc, this._user);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('users')
          .document(_user.uid)
          .collection('exercises')
          .document(_doc.documentID)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        return Scaffold(
          appBar: AppBar(
            title: Text(snapshot.data['name'] +
                " (" +
                totalTimeString(List.from(snapshot.data['objects'])) +
                ")"),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                    return EditExercise(_user, snapshot.data);
                  }));
                  Navigator.pop(context); //fjerne
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    //fjerne
                    return ExerciseView(snapshot.data, _user); //fjerne
                  })); //fjerne
                },
              ),
            ],
          ),
          body: DragAndDropList(
            snapshot.data['objects'],
            itemBuilder: (context, item) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  child: Card(
                    child: ListTile(
                      subtitle: Text(covertTime(item['time'])),
                      title: Text(item['name']),
                      trailing: Icon(Icons.drag_handle),
                      // onTap: () async {
                      //   await showDialog(
                      //       context: context,
                      //       builder: (context) {
                      //         return SimpleDialog(
                      //           title: Text("Options"),
                      //           children: <Widget>[
                      //             SimpleDialogOption(
                      //               child: Text("Insert Before"),
                      //               onPressed: () async {
                      //                 var list = List.from(_doc.data['objects']);
                      //                 Navigator.pop(context);
                      //                 await Navigator.push(context,
                      //                     MaterialPageRoute(builder: (context) {
                      //                   return AddWObject(_user, _doc.documentID);
                      //                 }));
                      //               },
                      //             ),
                      //             SimpleDialogOption(
                      //               child: Text("Insert After"),
                      //               onPressed: () {},
                      //             ),
                      //             SimpleDialogOption(
                      //               child: Text("Edit"),
                      //               onPressed: () {},
                      //             ),
                      //             SimpleDialogOption(
                      //               child: Text("Delete"),
                      //               onPressed: () {},
                      //             ),
                      //           ],
                      //         );
                      //       });
                      // },
                    ),
                  ),
                ),
              );
            },
            onDragFinish: (before, after) {
              var list = List.from(snapshot.data['objects']);
              var data = list[before];
              list.removeAt(before);
              list.insert(after, data);
              Firestore.instance.runTransaction((transaction) async {
                DocumentSnapshot freshSnap = await transaction.get(Firestore
                    .instance
                    .collection('users')
                    .document(_user.uid)
                    .collection('exercises')
                    .document(_doc.documentID));

                await transaction
                    .update(freshSnap.reference, {"objects": list});
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
