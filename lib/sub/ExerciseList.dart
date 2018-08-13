import 'package:flutter/material.dart';

import 'package:workout/sub/AddExercise.dart';
import 'package:workout/views/ExerciseView.dart';
import 'package:workout/utils.dart';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseUser;
import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseList extends StatelessWidget {
  final FirebaseUser _user;

  ExerciseList(this._user);

  @override
  Widget build(BuildContext context) {
    return MyExerciseList(_user);
  }
}

class MyExerciseList extends StatefulWidget {
  final FirebaseUser _user;

  MyExerciseList(this._user);

  @override
  _MyExerciseListState createState() => _MyExerciseListState(_user);
}

class _MyExerciseListState extends State<MyExerciseList>
    with WidgetsBindingObserver {
  final FirebaseUser _user;

  _MyExerciseListState(this._user);

  List<DocumentSnapshot> _docs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getWorkouts();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _getWorkouts();
  }

  void _getWorkouts() {
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
                _getWorkouts();
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
    _getWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add exercise to workout"),
      ),
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
                      onTap: () {
                        Navigator.pop(context, _docs[index].documentID);
                      },
                      title: name.length == 0 ? Text("no name") : Text(name),
                      subtitle:
                          Text(totalTimeString(_docs[index].data['objects'])),
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
