import 'package:flutter/material.dart';
import 'package:validate/validate.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Register extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Register"),
        ),
        body: MyCustomForm());
  }
}

class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();
  String _username = "";
  String _password = "";
  String _password2 = "";
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Form(
            key: _formKey,
            child: Center(
              child: ListView(
                // crossAxisAlignment: CrossAxisAlignment.start,
                shrinkWrap: true,
                padding: EdgeInsets.only(left: 24.0, right: 24.0),
                children: <Widget>[
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      } else {
                        try {
                          Validate.isEmail(value);
                        } catch (e) {
                          return 'The E-mail Address must be a valid email address.';
                        }
                      }
                    },
                    decoration: InputDecoration(labelText: "Email"),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (String value) {
                      setState(() {
                        _username = value;
                      });
                    },
                  ),
                  SizedBox(height: 8.0),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                    },
                    decoration: InputDecoration(labelText: "Passord"),
                    obscureText: true,
                    onSaved: (String value) {
                      setState(() {
                        _password = value;
                      });
                    },
                  ),
                  SizedBox(height: 8.0),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      } else if (_password != value) {
                        return 'Password does not match';
                      }
                    },
                    decoration: InputDecoration(labelText: "Confirm Passord"),
                    obscureText: true,
                    onSaved: (String value) {
                      setState(() {
                        _password2 = value;
                      });
                    },
                  ),
                  SizedBox(height: 24.0),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: RaisedButton(
                        color: Colors.red,
                        onPressed: () async {
                          _formKey.currentState.save();
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              _loading = true;
                            });
                            Scaffold.of(context).showSnackBar(
                                SnackBar(content: Text('Registering...')));

                            try {
                              final firebaseUser = await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                      email: _username, password: _password);
                              await Firestore.instance
                                  .collection('users')
                                  .document(firebaseUser.uid)
                                  .setData({"stats": []});
                              // await Firestore.instance
                              //     .collection('users')
                              //     .document(firebaseUser.uid)
                              //     .setData({"workouts": []});
                              Navigator.pop(context);
                            } catch (e) {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text('Something went wrong')));
                            }
                            setState(() {
                              _loading = false;
                            });
                          }
                        },
                        child: Text('Register'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
