import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:folka/models/UserData.dart';
import 'package:folka/screens/DetailsScreen.dart';
import 'package:folka/screens/FeedScreen.dart';
import 'package:folka/screens/HomeScreenIos.dart';
import 'package:folka/screens/LoginScreen.dart';
import 'package:folka/screens/SignUpScreen.dart';
import 'package:provider/provider.dart';
import 'screens/HomeScreenAndroid.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

/*
 ______   ______     __         __  __     ______
/\  == \ /\  __ \   /\ \       /\ \/ /    /\  __ \
\ \  _-/ \ \ \/\ \  \ \ \____  \ \  _"-.  \ \  __ \ ru
 \ \_\    \ \_____\  \ \_____\  \ \_\ \_\  \ \_\ \_\
  \/_/     \/_____/   \/_____/   \/_/\/_/   \/_/\/_/
                          \\||
                          ||\\
 ______     __  __     ______     __         ______
/\  ___\   /\ \_\ \   /\  ___\   /\ \       /\  ___\
\ \___  \  \ \  __ \  \ \  __\   \ \ \____  \ \  __\ en
 \/\_____\  \ \_\ \_\  \ \_____\  \ \_____\  \ \_\
  \/_____/   \/_/\/_/   \/_____/   \/_____/   \/_/

 */

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
        title: 'shelf',
        debugShowCheckedModeBanner: true,
        theme: ThemeData(
          brightness: Brightness.light,
          appBarTheme: Theme.of(context).appBarTheme.copyWith(
            color: Colors.white,
          ),
          primaryIconTheme: Theme.of(context).primaryIconTheme.copyWith(
            color: Colors.black,
          ),
          floatingActionButtonTheme: Theme.of(context).floatingActionButtonTheme.copyWith(
            foregroundColor: Colors.black45
          ),
          primaryColor: Colors.greenAccent,
          hintColor: Colors.black38,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryIconTheme: Theme.of(context).primaryIconTheme.copyWith(
            color: Colors.white,
          ),
          floatingActionButtonTheme: Theme.of(context).floatingActionButtonTheme.copyWith(
              foregroundColor: Colors.greenAccent[100]
          ),
          popupMenuTheme: Theme.of(context).popupMenuTheme.copyWith(
            color: CupertinoColors.darkBackgroundGray,
          ),
          hintColor: Colors.white38,
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
