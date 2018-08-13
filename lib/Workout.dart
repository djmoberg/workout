import 'package:flutter/material.dart';

import 'package:workout/sub/AddExercise.dart';
import 'package:workout/views/ExerciseView.dart';
import 'package:workout/utils.dart';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseUser;
import 'package:cloud_firestore/cloud_firestore.dart';

class Workout extends StatelessWidget {
  final FirebaseUser _user;

  Workout(this._user);

  @override
  Widget build(BuildContext context) {
    return MyWorkout(_user);
  }
}

class MyWorkout extends StatefulWidget {
  final FirebaseUser _user;

  MyWorkout(this._user);

  @override
  _MyWorkoutState createState() => _MyWorkoutState(_user);
}

class _MyWorkoutState extends State<MyWorkout> with WidgetsBindingObserver {
  final FirebaseUser _user;

  _MyWorkoutState(this._user);

  List<DocumentSnapshot> _docs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _test();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _test();
  }

  void _test() {
    Firestore.instance
        .collection('users')
        .document(_user.uid)
        .collection('exercises')
        .getDocuments()
        .then(
      (snapshot) {
        List<DocumentSnapshot> newList = List();
        snapshot.documents.forEach(
          (doc) {
            newList.add(doc);
          },
        );
        setState(() {
          _docs = newList;
        });
      },
    );
  }

  void _delete(docName) {
    showDialog<Null>(
      context: context,
      // barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Discard Workout?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('DISCARD'),
              onPressed: () async {
                Navigator.of(context).pop();
                await Firestore.instance
                    .collection('users')
                    .document(_user.uid)
                    .collection('exercises')
                    .document(docName)
                    .delete();
                _test();
              },
            ),
          ],
        );
      },
    );
  }

  _navigate(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddExercise(_user)),
    );
    _test();
  }

  @override
  Widget build(BuildContext context) {
    // _test();
    // if (_docs.length == 0) return Center(child: CircularProgressIndicator());
    return Scaffold(
      // body: StreamBuilder(
      //   stream: Firestore.instance
      //       .collection('users')
      //       .document(_user.uid)
      //       .snapshots(),
      //   builder: (context, snapshot) {
      //     if (!snapshot.hasData) return const Text("Loading...");
      //     return ListView.builder(
      //       itemExtent: 80.0,
      //       itemCount: snapshot.data['exercises'].length,
      //       itemBuilder: (context, index) {
      //         var list = Map<String, dynamic>.from(
      //             List.from(snapshot.data['exercises'])[index]);
      //         return ListTile(
      //           leading: Icon(Icons.sentiment_very_satisfied),
      //           title: Text(list['name']),
      //           trailing: Text("Total Time: 5:00"),
      //         );
      //       },
      //     );
      //   },
      // ),
      body: _docs == null
          ? Center(child: CircularProgressIndicator())
          : _docs.length == 0
              ? Center(child: Text("Welcome!"))
              : ListView.builder(
                  itemCount: _docs.length,
                  itemBuilder: (context, index) {
                    String name = _docs[index].data['name'];
                    return ListTile(
                      onLongPress: () => _delete(_docs[index].documentID),
                      onTap: () async {
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ExerciseView(_docs[index], _user);
                        }));
                        _test();
                      },
                      title: name.length == 0 ? Text("no name") : Text(name),
                      subtitle:
                          Text(totalTimeString(_docs[index].data['objects'])),
                      // trailing: Icon(Icons.drag_handle),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _navigate(context);
        },
      ),
    );
  }
}
