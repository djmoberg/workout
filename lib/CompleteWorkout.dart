import 'package:flutter/material.dart';

import 'package:workout/sub/AddWorkout.dart';
import 'package:workout/views/WorkoutView.dart';
import 'package:workout/utils.dart';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseUser;
import 'package:cloud_firestore/cloud_firestore.dart';

class CompleteWorkout extends StatelessWidget {
  final FirebaseUser _user;

  CompleteWorkout(this._user);

  @override
  Widget build(BuildContext context) {
    return MyCompleteWorkout(_user);
  }
}

class MyCompleteWorkout extends StatefulWidget {
  final FirebaseUser _user;

  MyCompleteWorkout(this._user);

  @override
  _MyCompleteWorkoutState createState() => _MyCompleteWorkoutState(_user);
}

class _MyCompleteWorkoutState extends State<MyCompleteWorkout>
    with WidgetsBindingObserver {
  final FirebaseUser _user;

  _MyCompleteWorkoutState(this._user);

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
        .collection('workouts')
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
                    .collection('workouts')
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
      MaterialPageRoute(builder: (context) => AddWorkout(_user)),
    );
    _test();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          return WorkoutView(_docs[index], _user);
                        }));
                        _test();
                      },
                      title: name.length == 0 ? Text("no name") : Text(name),
                      // subtitle: FutureBuilder(
                      //   future: workoutTimeString(
                      //       _docs[index].data['exercises'], _user.uid),
                      //   builder: (context, snapshot) {
                      //     return Text(snapshot.data);
                      //   },
                      // ),
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
