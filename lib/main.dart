import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localauth/cubit/rebuild_fixer.dart';
import 'package:localauth/presentation/root.dart';
import 'package:localauth/presentation/screens/home/home.dart';
import 'package:localauth/todo/calculator.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/passcode_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return BlocProvider(
        create: (context) => RebuildFixer(true),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SimpleCalculator(),
        ));
  }
}

class LocalAuth extends StatefulWidget {
  // final Future<FirebaseApp> _firebaseInstance = Firebase.initializeApp();
  @override
  _LocalAuthState createState() => _LocalAuthState();
}

class _LocalAuthState extends State<LocalAuth> {
  final CollectionReference _passCode =
      FirebaseFirestore.instance.collection('requiredPass');
  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();

  bool isAuthenticated = false;
  bool isAuth = false;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        print(snapshot.connectionState);
        if (snapshot.hasError) {
          return Container(
            color: Colors.white,
            child: Center(
              child: Text('Error'),
            ),
          );
        }
        return isAuth
            ? AccountManagerApp()
            : Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _defaultLockScreenButton(context),
                  ],
                )),
              );

        // //FOr loading
        // return Container(
        //   color: Colors.white,
        //   child: Center(
        //     child: CircularProgressIndicator(),
        //   ),
        // );
      },
    );
  }

  _defaultLockScreenButton(BuildContext context) => InkWell(
        child: Container(
          height: 60,
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent, width: 2.5)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.keyboard,
                color: Colors.blueAccent,
              ),
              Text(
                "Open Default keyboard",
                style: TextStyle(color: Colors.blueAccent),
              )
            ],
          ),
        ),
        onTap: () {
          //TODO _showLockScreen
          _showLockScreen(context);
          // Navigator.of(context)
          //     .push(MaterialPageRoute(builder: (context) => Home()));
        },
      );

  _showLockScreen(BuildContext context,
      {bool opaque,
      CircleUIConfig circleUIConfig,
      KeyboardUIConfig keyboardUIConfig,
      Widget cancelButton,
      List<String> digits}) {
    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: opaque,
          pageBuilder: (context, animation, secondaryAnimation) =>
              PasscodeScreen(
            title: Text(
              'Enter App Passcode',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 28),
            ),
            circleUIConfig: circleUIConfig,
            keyboardUIConfig: keyboardUIConfig,
            isValidCallback: () {},
            passwordEnteredCallback: _onPasscodeEntered,
            cancelButton: cancelButton,
            deleteButton: Text(
              'Delete',
              style: const TextStyle(fontSize: 16, color: Colors.white),
              semanticsLabel: 'Delete',
            ),
            shouldTriggerVerification: _verificationNotifier.stream,
            backgroundColor: Colors.black.withOpacity(0.8),
            cancelCallback: _onPasscodeCancelled,
            digits: digits,
          ),
        ));
  }

  _onPasscodeEntered(String enteredPasscode) async {
    DocumentSnapshot pass = await _passCode.doc('YZczjFOkxzcvq9ggpWof').get();
    final passes = await pass.data()['pass'];
    bool isValid = passes == enteredPasscode;
    _verificationNotifier.add(isValid);
    print(passes.runtimeType);
    print(enteredPasscode.runtimeType);
    if (isValid) {
      print(isValid);
      setState(() {
        this.isAuth = isValid;
      });
    }
  }

  _onPasscodeCancelled() async {
    Navigator.maybePop(context);
  }

  @override
  void dispose() {
    _verificationNotifier.close();
    super.dispose();
  }
}
