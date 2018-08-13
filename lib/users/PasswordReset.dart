import 'package:flutter/material.dart';
import 'package:validate/validate.dart';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

class PasswordReset extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reset Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: MyPasswordReset(),
      ),
    );
  }
}

class MyPasswordReset extends StatefulWidget {
  @override
  MyPasswordResetState createState() {
    return MyPasswordResetState();
  }
}

class MyPasswordResetState extends State<MyPasswordReset> {
  String _email;
  String _errorText;

  void _sendMail() {
    try {
      Validate.isEmail(_email);
      FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorText = "The E-mail Address must be a valid email address.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          decoration: InputDecoration(
              labelText: "Email",
              errorText: _errorText,
              border: OutlineInputBorder()),
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          onChanged: (String value) {
            setState(() {
              _email = value;
              _errorText = null;
            });
          },
        ),
        // Text("$_newBalance"),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(""),
              ),
              RaisedButton(
                  child: Text("Send"),
                  color: Colors.green,
                  onPressed: _sendMail)
            ],
          ),
        ),
      ],
    );
  }
}