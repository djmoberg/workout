import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatelessWidget {
  final VoidCallback onSharedPrefsChanged;

  Settings(this.onSharedPrefsChanged);

  @override
  Widget build(BuildContext context) {
    return MySettings(onSharedPrefsChanged);
  }
}

class MySettings extends StatefulWidget {
  final VoidCallback onSharedPrefsChanged;

  MySettings(this.onSharedPrefsChanged);

  @override
  _MySettingsState createState() => _MySettingsState(onSharedPrefsChanged);
}

class _MySettingsState extends State<MySettings> {
  final VoidCallback onSharedPrefsChanged;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<bool> _darkThemeEnabled;
  int _defaultScreen;

  _MySettingsState(this.onSharedPrefsChanged);

  @override
  void initState() {
    super.initState();
    _darkThemeEnabled = _prefs.then((SharedPreferences prefs) {
      return (prefs.getBool('darkThemeEnabled') ?? false);
    });
    _initDefaultScreen();
  }

  void _initDefaultScreen() async {
    _defaultScreen = await _prefs.then((SharedPreferences prefs) {
      return (prefs.getInt('_defaultScreen') ?? 0);
    });
  }

  // Future<Null> _changeTheme() async {
  //   final SharedPreferences prefs = await _prefs;
  //   final bool darkThemeEnabled = (prefs.getBool('darkThemeEnabled') ?? false);
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _darkThemeEnabled,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const CircularProgressIndicator();
          default:
            if (snapshot.hasError)
              return Text('Error: ${snapshot.error}');
            else
              return Scaffold(
                body: ListView(
                  children: <Widget>[
                    ListTile(
                      title: Text("Dark Theme"),
                      trailing: Switch(
                        onChanged: (value) async {
                          final SharedPreferences prefs = await _prefs;
                          setState(() {
                            _darkThemeEnabled = prefs
                                .setBool("darkThemeEnabled", value)
                                .then((success) {
                              return value;
                            });
                          });
                          onSharedPrefsChanged();
                        },
                        value: snapshot.data,
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text("Default Screen"),
                      trailing: DropdownButton(
                        value: _defaultScreen,
                        items: <DropdownMenuItem>[
                          DropdownMenuItem(
                            value: 0,
                            child: Text("Workout"),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Text("Exercise"),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text("Stats"),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Text("Settings"),
                          ),
                        ],
                        onChanged: (value) async {
                          final SharedPreferences prefs = await _prefs;
                          var newValue = await prefs
                              .setInt("_defaultScreen", value)
                              .then((success) {
                            return value;
                          });
                          setState(() {
                            _defaultScreen = newValue;
                          });
                        },
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: RaisedButton(
                        child: Text("Sign Out"),
                        onPressed: () async {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return Scaffold(
                              body: Center(child: CircularProgressIndicator()),
                            );
                          }));
                          await FirebaseAuth.instance.signOut();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              );
        }
      },
    );
  }
}
