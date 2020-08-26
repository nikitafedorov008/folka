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
  Widget build(BuildContext context) {
    final String currentUserId = Provider.of<UserData>(context).currentUserId;
    return CupertinoPageScaffold(
      child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
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
            backgroundColor: Colors.transparent,
            activeColor: Colors.greenAccent,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  CupertinoIcons.news,
                  //Icons.receipt,
                  size: 32.0,
                ),
                title: Text('Feed'),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  CupertinoIcons.search,
                  size: 32.0,
                ),
                title: Text('Search'),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  CupertinoIcons.add_circled,
                  size: 32.0,
                ),
                title: Text('Add'),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  CupertinoIcons.mail,
                  size: 32.0,
                ),
                title: Text('Activity'),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  CupertinoIcons.person,
                  size: 32.0,
                ),
                title: Text('Profile'),
              ),
            ],
          ),
        tabBuilder: (context, index) {
          switch (index) {
            case 0:
              return FeedScreen(currentUserId: currentUserId);
              break;
            case 1:
              return SearchScreen();
              break;
            case 2:
              return CreatePostScreen(currentUserId: currentUserId, userId: currentUserId,);
              break;
            case 3:
              return ActivityScreen(currentUserId: currentUserId);
              break;
            case 4:
              return ProfileScreen(
                currentUserId: currentUserId,
                userId: currentUserId,
              );
              break;
            default:
              return FeedScreen(currentUserId: currentUserId);
              break;
          }
        }),
    );
  }
}