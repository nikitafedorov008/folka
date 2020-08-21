import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:folka/models/UserData.dart';
import 'package:folka/screens/ActivityScreen.dart';
import 'package:folka/screens/CreatePostScreen.dart';
import 'package:folka/screens/FeedScreen.dart';
import 'package:folka/screens/ProfileScreen.dart';
import 'package:folka/screens/SearchScreen.dart';
import 'package:folka/services/AuthService.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';

class HomeScreenAndroid extends StatefulWidget {


  @override
  _HomeScreenAndroidState createState() => _HomeScreenAndroidState();
}

class _HomeScreenAndroidState extends State<HomeScreenAndroid> {
  int bottomSelectedIndex = 0;

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  final QuickActions _quickActions = QuickActions();

  @override
  Future<void> initState() {
    super.initState();
    //WidgetsBinding.instance.renderView.automaticSystemUiAdjustment=false;  //<--
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        //statusBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    //SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    FlutterStatusbarcolor.setNavigationBarColor(Colors.greenAccent);
    FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);
    //FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
    /*if (useWhiteForeground(Colors.greenAccent)) {
      FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
      FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);
    } else {
      FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
      FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);
    }*/

    _quickActions.initialize((String shortcut) {
      print(shortcut);
      if (shortcut != null) {
        if (shortcut == 'add') {
          pageChanged(2);
        } else if (shortcut == 'search') {
          pageChanged(1);
        } else if (shortcut == 'mail') {
          pageChanged(3);
        } else if (shortcut == 'account') {
          pageChanged(4);
        } else {
          debugPrint('No one shortcut selected');
        }
      }
    });

    _quickActions.setShortcutItems(
      <ShortcutItem>[
        const ShortcutItem(
          type: 'add',
          localizedTitle: 'Add',
          icon: 'add',
        ),
        const ShortcutItem(
          type: 'search',
          localizedTitle: 'Search',
          icon: 'searchs',
        ),
        const ShortcutItem(
          type: 'mail',
          localizedTitle: 'Mail',
          icon: 'mail',
        ),
        const ShortcutItem(
          type: 'account',
          localizedTitle: 'Account',
          icon: 'account',
        ),
      ],
    );
  }

  void pageChanged(int index) {
    setState(() {
      bottomSelectedIndex = index;
    });
  }

  void bottomTapped(int index) {
    setState(() {
      bottomSelectedIndex = index;
      pageController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  void _onItemTapped(index) {
    setState(() {
      pageController = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = Provider.of<UserData>(context).currentUserId;
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        /*shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30.0),
          ),
        ),*/
        bottomOpacity: 0.0,
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
        /*leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: new IconButton(
              icon: Image.asset('assets/images/bookcase.png'),
              onPressed: null
          ),
        ),*/
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app, /*color: Colors.black,*/),
            onPressed: AuthService.logout,
          )
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          pageChanged(index);
        },
        children: <Widget>[
          FeedScreen(currentUserId: currentUserId),
          SearchScreen(),
          CreatePostScreen(currentUserId: currentUserId, userId: currentUserId,),
          ActivityScreen(currentUserId: currentUserId),
          ProfileScreen(currentUserId: currentUserId, userId: currentUserId,),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6,
        clipBehavior: Clip.antiAlias,
        child: BottomNavigationBar(
          onTap: (index) {
            bottomTapped(index);
            _onItemTapped(index);
          },
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.greenAccent,
          items: [
            BottomNavigationBarItem(
              icon: Tooltip(message: 'Home', child: Icon(Icons.domain, color: Colors.black38,)),
              title: Text('Home'),
              activeIcon: Tooltip(message: 'Home', child: Icon(Icons.domain, color: Colors.black,)),
            ),
            BottomNavigationBarItem(
              icon: Tooltip(message: 'Search', child: Icon(Icons.search, color: Colors.black38,)),
              title: Text('Search'),
              activeIcon: Tooltip(message: 'Search', child: Icon(Icons.search, color: Colors.black,)),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline, color: Colors.transparent,),
              title: Text('Add'),
            ),
            BottomNavigationBarItem(
              icon: Tooltip(message: 'Activity', child: Icon(Icons.mail_outline, color: Colors.black38,)),
              title: Text('Activity'),
              activeIcon: Tooltip(message: 'Activity', child: Icon(Icons.mail_outline, color: Colors.black,)),
            ),
            BottomNavigationBarItem(
              icon: Tooltip(message: 'Profile', child: Icon(Icons.person_outline, color: Colors.black38,)),
              title: Text('Profile'),
              activeIcon: Tooltip(message: 'Profile', child: Icon(Icons.person_outline, color: Colors.black,)),
            ),
          ],
          selectedItemColor: Colors.black87,
          currentIndex: bottomSelectedIndex,
        ),
      ),
      floatingActionButton: Container(
        height: 60.0,
        width: 60.0,
        child: FittedBox(
          child: FloatingActionButton(
            tooltip: 'Add',
            backgroundColor: Colors.greenAccent[100],
            onPressed: () {
              setState(() {
                pageController.jumpToPage(2);
              });
            },
            child: Icon(
              OMIcons.add,
              color: Colors.black,
            ),
            // elevation: 5.0,
          ),
        ),
      ),
    );
  }
}