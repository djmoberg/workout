import 'dart:async';

import 'package:flutter/material.dart';

import 'package:workout/Home.dart';
import 'package:workout/users/Login.dart';

import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseUser;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isAuthenticated = false;
  FirebaseUser _user;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<bool> _darkThemeEnabled;

  @override
  void initState() {
    super.initState();
    _darkThemeEnabled = _prefs.then((SharedPreferences prefs) {
      return (prefs.getBool('darkThemeEnabled') ?? false);
    });
  }

  void _listener() {
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _isAuthenticated = user != null;
        _user = user != null ? user : null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _listener();

    return FutureBuilder<bool>(
      future: _darkThemeEnabled,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const CircularProgressIndicator();
          default:
            if (snapshot.hasError)
              return Text('Error: ${snapshot.error}');
            else
              return MaterialApp(
                title: 'Workout',
                theme: snapshot.data ? ThemeData.dark() : ThemeData.light(),
                home: _isAuthenticated
                    ? Home(_user, () {
                        setState(() {
                          _darkThemeEnabled =
                              _prefs.then((SharedPreferences prefs) {
                            return (prefs.getBool('darkThemeEnabled') ?? false);
                          });
                        });
                      })
                    : Login(),
              );
        }
      },
    );

    // return MaterialApp(
    //   title: 'Flutter Demo',
    //   theme: ThemeData(
    //     primarySwatch: Colors.red,
    //   ),
    //   home: _isAuthenticated ? Home(_user) : Login(),
    // );
  }
}
