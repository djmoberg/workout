import 'dart:async';

import 'package:flutter/material.dart';

import 'package:workout/CompleteWorkout.dart';
import 'package:workout/Workout.dart';
import 'package:workout/Stats.dart';
import 'package:workout/Settings.dart';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseUser;
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatelessWidget {
  final FirebaseUser _user;
  final VoidCallback onSharedPrefsChanged;

  Home(this._user, this.onSharedPrefsChanged);

  @override
  Widget build(BuildContext context) {
    return MyHome(_user, onSharedPrefsChanged);
  }
}

class MyHome extends StatefulWidget {
  final FirebaseUser _user;
  final VoidCallback onSharedPrefsChanged;

  MyHome(this._user, this.onSharedPrefsChanged);

  @override
  _MyHomeState createState() => _MyHomeState(_user, onSharedPrefsChanged);
}

class _MyHomeState extends State<MyHome> {
  final FirebaseUser _user;
  final VoidCallback onSharedPrefsChanged;

  _MyHomeState(this._user, this.onSharedPrefsChanged);

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  int _index = 0;

  @override
  void initState() {
    super.initState();
    _initIndex();
  }

  void _initIndex() async {
    _index = await _prefs.then((SharedPreferences prefs) {
      return (prefs.getInt('_defaultScreen') ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _views = [
      CompleteWorkout(_user),
      Workout(_user),
      Stats(),
      Settings(onSharedPrefsChanged),
    ];

    return Scaffold(
      body: _views[_index],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: _index,
        onTap: (index) {
          setState(() {
            _index = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.red,
            ),
            title: Text(
              'Workout',
              style: TextStyle(color: Colors.red),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.group_work,
              color: Colors.red,
            ),
            title: Text(
              'Exercise',
              style: TextStyle(color: Colors.red),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.insert_chart,
              color: Colors.red,
            ),
            title: Text(
              'Stats',
              style: TextStyle(color: Colors.red),
            ),
          ),
          BottomNavigationBarItem(
            title: Text(
              'Settings',
              style: TextStyle(color: Colors.red),
            ),
            icon: Icon(
              Icons.settings,
              color: Colors.red,
            ),
          )
        ],
      ),
    );
  }
}
