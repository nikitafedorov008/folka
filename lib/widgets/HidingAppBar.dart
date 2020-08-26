import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget HidingAppBar({bool forceElevated}) {
  if (Platform.isIOS) {
    return CupertinoSliverNavigationBar(
      largeTitle: Text('shelf'),
      backgroundColor: Colors.greenAccent,
    );
  } else if(Platform.isAndroid) {
    return new SliverAppBar(
      //bottomOpacity: 0.0,
      expandedHeight: 6,
      elevation: 0,
      //centerTitle: true,
      backgroundColor: Colors.transparent,
      title: Text(
        'shelf', style:  TextStyle(
        //color: Colors.black,
          fontFamily: 'ProductSans',
          fontSize: 24.0
      ),
      ),
      pinned: false,                       //<-- pinned to true
      floating: false,                     //<-- floating to true
      forceElevated: forceElevated,  //<-- forceElevated to innerBoxIsScrolled
    );
  }
}