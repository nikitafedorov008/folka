import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:folka/models/UserData.dart';
import 'package:folka/screens/FeedScreen.dart';
import 'package:folka/screens/HomeScreenIos.dart';
import 'package:folka/screens/LoginScreen.dart';
import 'package:folka/screens/SignUpScreen.dart';
import 'package:provider/provider.dart';
import 'screens/HomeScreenAndroid.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Widget _getScreenId() {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          Provider.of<UserData>(context).currentUserId = snapshot.data.uid;
          return Platform.isIOS ? HomeScreenIos() : HomeScreenAndroid();
        } else {
          return LoginScreen();
        }
      },
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserData(),
      child: MaterialApp(
        title: 'polka',
        debugShowCheckedModeBanner: true,
        theme: ThemeData(
          primaryIconTheme: Theme.of(context).primaryIconTheme.copyWith(
            color: Colors.greenAccent,
          ),
          primaryColor: Colors.greenAccent,
        ),
        home: _getScreenId(),
        routes: {
          LoginScreen.id: (context) => LoginScreen(),
          SignupScreen.id: (context) => SignupScreen(),
          FeedScreen.id: (context) => FeedScreen(),
        },
      ),
    );
  }
}
