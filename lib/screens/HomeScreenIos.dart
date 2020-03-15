import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:folka/models/UserData.dart';
import 'package:folka/screens/ActivityScreen.dart';
import 'package:folka/screens/CreatePostScreen.dart';
import 'package:folka/screens/FeedScreen.dart';
import 'package:folka/screens/ProfileScreen.dart';
import 'package:folka/screens/SearchScreen.dart';
import 'package:folka/services/AuthService.dart';
import 'package:provider/provider.dart';

class HomeScreenIos extends StatefulWidget {
  @override
  _HomeScreenIosState createState() => _HomeScreenIosState();
}

class _HomeScreenIosState extends State<HomeScreenIos> {
  int _currentTab = 0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = Provider.of<UserData>(context).currentUserId;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('shelf'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.black,),
            onPressed: AuthService.logout,
          )
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          FeedScreen(currentUserId: currentUserId),
          SearchScreen(),
          CreatePostScreen(currentUserId: currentUserId, userId: currentUserId,),
          ActivityScreen(currentUserId: currentUserId),
          ProfileScreen(
            currentUserId: currentUserId,
            userId: currentUserId,
          ),
        ],
        onPageChanged: (int index) {
          setState(() {
            _currentTab = index;
          });
        },
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _currentTab,
        onTap: (int index) {
          setState(() {
            _currentTab = index;
          });
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );
        },
        activeColor: Colors.greenAccent,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.receipt,
              size: 32.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              size: 32.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_circle,
              size: 32.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.mail,
              size: 32.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle,
              size: 32.0,
            ),
          ),
        ],
      ),
    );
  }
}
