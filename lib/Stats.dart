import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseUser;
import 'package:shared_preferences/shared_preferences.dart';

class Stats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyStats();
  }
}

class MyStats extends StatefulWidget {
  @override
  _MyStatsState createState() => _MyStatsState();
}

class _MyStatsState extends State<MyStats> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  int _wWeek = 0;
  int _wMonth = 0;
  int _wYear = 0;
  int _wAllTime = 0;
  int _eWeek = 0;
  int _eMonth = 0;
  int _eYear = 0;
  int _eAllTime = 0;

  Future _getStats() async {
    DateTime now = DateTime.now();
    int eWeek = 0;
    int eMonth = 0;
    int eYear = 0;
    int eAllTime = 0;
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot snap =
        await Firestore.instance.collection('users').document(user.uid).get();
    snap.data['stats'].forEach((stat) {
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(stat);
      if (stat < now.millisecondsSinceEpoch &&
          stat + Duration(days: 7).inMilliseconds >
              now.millisecondsSinceEpoch) {
        eWeek++;
      }
      if (dt.month == now.month && dt.year == now.year) {
        eMonth++;
      }
      if (dt.year == now.year) {
        eYear++;
      }
      eAllTime++;
    });
    _eWeek = eWeek;
    _eMonth = eMonth;
    _eYear = eYear;
    _eAllTime = eAllTime;

    final prefs = await _prefs;
    prefs.setInt("eWeek", eWeek);
    prefs.setInt("eMonth", eMonth);
    prefs.setInt("eYear", eYear);
    prefs.setInt("eAllTime", eAllTime);
  }

  void _initLocalStats() async {
    _eWeek = await _prefs.then((SharedPreferences prefs) {
      return (prefs.getInt('eWeek') ?? 0);
    });
    _eMonth = await _prefs.then((SharedPreferences prefs) {
      return (prefs.getInt('eMonth') ?? 0);
    });
    _eYear = await _prefs.then((SharedPreferences prefs) {
      return (prefs.getInt('eYear') ?? 0);
    });
    _eAllTime = await _prefs.then((SharedPreferences prefs) {
      return (prefs.getInt('eAllTime') ?? 0);
    });
  }

  @override
  void initState() {
    super.initState();
    _initLocalStats();
    _getStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 16.0,
          ),
          Card(
            child: ListTile(
              title: Text("Workouts this week:"),
              trailing: Text(
                _wWeek.toString(),
                style: Theme.of(context).textTheme.headline,
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: Text("Workouts this month:"),
              trailing: Text(
                _wMonth.toString(),
                style: Theme.of(context).textTheme.headline,
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: Text("Workouts this year:"),
              trailing: Text(
                _wYear.toString(),
                style: Theme.of(context).textTheme.headline,
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: Text("Workouts all time:"),
              trailing: Text(
                _wAllTime.toString(),
                style: Theme.of(context).textTheme.headline,
              ),
            ),
          ),
          SizedBox(
            height: 16.0,
          ),
          Card(
            child: ListTile(
              title: Text("Exercises this week:"),
              trailing: Text(
                _eWeek.toString(),
                style: Theme.of(context).textTheme.headline,
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: Text("Exercises this month:"),
              trailing: Text(
                _eMonth.toString(),
                style: Theme.of(context).textTheme.headline,
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: Text("Exercises this year:"),
              trailing: Text(
                _eYear.toString(),
                style: Theme.of(context).textTheme.headline,
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: Text("Exercises all time:"),
              trailing: Text(
                _eAllTime.toString(),
                style: Theme.of(context).textTheme.headline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
