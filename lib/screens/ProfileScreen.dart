import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:folka/models/Post.dart';
import 'package:folka/models/UserData.dart';
import 'package:folka/models/User.dart';
import 'package:folka/screens/EditProfileScreen.dart';
import 'package:folka/services/AuthService.dart';
import 'package:folka/services/DatabaseService.dart';
import 'package:folka/utilities/Constants.dart';
import 'package:folka/widgets/PostView.dart';
import 'package:provider/provider.dart';
import 'CommentsScreen.dart';

class ProfileScreen extends StatefulWidget {
  final String currentUserId;
  final String userId;

  ProfileScreen({this.currentUserId, this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isFollowing = false;
  int _followerCount = 0;
  int _followingCount = 0;
  List<Post> _posts = [];
  int _displayPosts = 0; // 0 - grid, 1 - column
  User _profileUser;

  @override
  void initState() {
    super.initState();
    _setupIsFollowing();
    _setupFollowers();
    _setupFollowing();
    _setupPosts();
    _setupProfileUser();
  }

  _setupIsFollowing() async {
    bool isFollowingUser = await DatabaseService.isFollowingUser(
      currentUserId: widget.currentUserId,
      userId: widget.userId,
    );
    setState(() {
      _isFollowing = isFollowingUser;
    });
  }

  _setupFollowers() async {
    int userFollowerCount = await DatabaseService.numFollowers(widget.userId);
    setState(() {
      _followerCount = userFollowerCount;
    });
  }

  _setupFollowing() async {
    int userFollowingCount = await DatabaseService.numFollowing(widget.userId);
    setState(() {
      _followingCount = userFollowingCount;
    });
  }

  _setupPosts() async {
    List<Post> posts = await DatabaseService.getUserPosts(widget.userId);
    setState(() {
      _posts = posts;
    });
  }

  _setupProfileUser() async {
    User profileUser = await DatabaseService.getUserWithId(widget.userId);
    setState(() {
      _profileUser = profileUser;
    });
  }

  _followOrUnfollow() {
    if (_isFollowing) {
      _unFollowUser();
    } else {
      _followUser();
    }
  }

  _unFollowUser() {
    DatabaseService.unFollowUser(
      currentUserId: widget.currentUserId,
      userId: widget.userId,
    );
    setState(() {
      _isFollowing = false;
      _followerCount--;
    });
  }

  _followUser() {
    DatabaseService.followUser(
      currentUserId: widget.currentUserId,
      userId: widget.userId,
    );
    setState(() {
      _isFollowing = true;
      _followerCount++;
    });
  }


  _displayButton(User user) {
    return user.id == Provider.of<UserData>(context).currentUserId ? IconButton(
      icon: new Icon(Icons.settings),
      //color: Colors.black,
      onPressed: () => Navigator.push(context,
        MaterialPageRoute(
          builder: (_) => EditProfileScreen(
            user: user,
          ),
        ),
      ),
    ): IconButton(
      icon: new Icon(
        _isFollowing ? Icons.check_circle_outline : Icons.radio_button_unchecked,
        color: _isFollowing ? Colors.green : Colors.black,
      ),
      //color: Colors.black,
      onPressed: _followOrUnfollow,
    );
  }

  _buildToggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.grid_on),
          iconSize: 30.0,
          color: _displayPosts == 0
              ? Colors.greenAccent //Theme.of(context).primaryColor
              : Colors.grey[300],
          onPressed: () => setState(() {
            _displayPosts = 0;
          }),
        ),
        IconButton(
          icon: Icon(Icons.list),
          iconSize: 30.0,
          color: _displayPosts == 1
              ? Colors.greenAccent//Theme.of(context).primaryColor
              : Colors.grey[300],
          onPressed: () => setState(() {
            _displayPosts = 1;
          }),
        ),
      ],
    );
  }

  _buildTilePost(Post post) {
    return GridTile(
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommentsScreen(
              post: post,
              likeCount: post.likeCount,
            ),
          ),
        ),
        child: Image(
          image: CachedNetworkImageProvider(post.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  _buildDisplayPosts() {
    if (_displayPosts == 0) {
      // Grid
      List<GridTile> tiles = [];
      _posts.forEach(
            (post) => tiles.add(_buildTilePost(post)),
      );
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 2.0,
        crossAxisSpacing: 2.0,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: tiles,
      );
    } else {
      // Column
      List<PostView> postViews = [];
      _posts.forEach((post) {
        postViews.add(
          PostView(
            currentUserId: widget.currentUserId,
            post: post,
            author: _profileUser,
          ),
        );
      });
      return Column(children: postViews);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: usersRef.document(widget.userId).get(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          User user = User.fromDoc(snapshot.data);
          return ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 8.0,),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircleAvatar(
                            radius: 35.0,
                            backgroundColor: Colors.grey,
                            backgroundImage: user.profileImageUrl.isEmpty
                                ? AssetImage('assets/images/avatar.png')
                                : CachedNetworkImageProvider(user.profileImageUrl),
                          ),
                          Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      Text(user.name, style: TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: 'ProductSans',
                                        fontWeight: FontWeight.w600,
                                      ),),
                                      /*Text(
                                              'name',
                                              style: TextStyle(color: Colors.black54),
                                            ),*/
                                    ],
                                  ),
                                  SizedBox(width: 5,),
                                  Column(
                                    children: <Widget>[
                                      Text(user.surname, style: TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: 'ProductSans',
                                        fontWeight: FontWeight.w600,
                                      ),
                                      ),
                                      /*Text(
                                              'surname',
                                              style: TextStyle(color: Colors.black54),
                                            ),*/
                                    ],
                                  ),
                                  _displayButton(user),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text(user.email,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontFamily: 'ProductSans',
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 0,),
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Icon(
                            Icons.shopping_basket,
                            color: Colors.green,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: <Widget>[
                              Text(_posts.length.toString(), style: TextStyle(
                                fontSize: 16.0,
                                fontFamily: 'ProductSans',
                                fontWeight: FontWeight.w600,),),
                              Text('products', style: TextStyle(
                                fontSize: 12.0,
                                fontFamily: 'ProductSans',
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,),),
                            ],),
                          ),
                          SizedBox(width: 15.0,),
                          Icon(
                            Icons.work,
                            color: Colors.blue,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: <Widget>[
                              Text('123', style: TextStyle(
                                fontSize: 16.0,
                                fontFamily: 'ProductSans',
                                fontWeight: FontWeight.w600,),),
                              Text('sales', style: TextStyle(
                                fontSize: 12.0,
                                fontFamily: 'ProductSans',
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,),),
                            ],),
                          ),
                          SizedBox(width: 15.0,),
                          Icon(
                            Icons.star,
                            color: Colors.orange,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: <Widget>[
                              Text('D', style: TextStyle(
                                fontSize: 16.0,
                                fontFamily: 'ProductSans',
                                fontWeight: FontWeight.w600,),),
                              Text('raiting', style: TextStyle(
                                fontSize: 12.0,
                                fontFamily: 'ProductSans',
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,),),
                            ],),
                          ),
                          SizedBox(width: 15.0,),
                          Icon(
                            Icons.group,
                            color: Colors.purple,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: <Widget>[
                              Text(_followerCount.toString(), style: TextStyle(
                                fontSize: 16.0,
                                fontFamily: 'ProductSans',
                                fontWeight: FontWeight.w600,),),
                              Text('followers', style: TextStyle(
                                fontSize: 12.0,
                                fontFamily: 'ProductSans',
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,),),
                            ],),
                          ),
                        ],),
                    ],
                  ),
                ),
              ),
              _buildToggleButtons(),
              Divider(),
              _buildDisplayPosts(),
            ],
          );
        },
      ),
    );
  }
}
