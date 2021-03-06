import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:folka/models/Post.dart';
import 'package:folka/models/UserData.dart';
import 'package:folka/models/User.dart';
import 'package:folka/screens/DetailsScreen.dart';
import 'package:folka/screens/ProfileScreen.dart';
import 'package:folka/services/DatabaseService.dart';
import 'package:folka/widgets/GridPostView.dart';
import 'package:folka/widgets/PostView.dart';
import 'package:folka/widgets/SearchPostView.dart';
import 'package:provider/provider.dart';
import 'ProfleSmbScreen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  Future<QuerySnapshot> _users;
  Future<QuerySnapshot> _posts;

  /*_buildUserTile(User user) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20.0,
        backgroundImage: user.profileImageUrl.isEmpty
            ? AssetImage('assets/images/avatar.png')
            : CachedNetworkImageProvider(user.profileImageUrl),
      ),
      title: Text(user.name),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileSMDScreen(
            currentUserId: Provider.of<UserData>(context).currentUserId,
            userId: user.id,
          ),
        ),
      ),
    );
  }*/

  _buildPostTile(Post post) {
    return PostView(
      post: post,
    );
  }

  _clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _searchController.clear());
    setState(() {
      //_users = null;
      _posts = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        bottomOpacity: 0.0,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 15.0),
            border: InputBorder.none,
            hintText: 'Search',
            hintStyle: TextStyle(fontFamily: 'ProductSans'),
            prefixIcon: Icon(
              Icons.search,
              //color: Colors.grey,
              size: 30.0,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
                //color: Colors.grey,
              ),
              onPressed: _clearSearch,
            ),
            filled: true,
          ),
          onSubmitted: (input) {
            if (input.isNotEmpty) {
              setState(() {
                //_users = DatabaseService.searchUsers(input);
                _posts = DatabaseService.searchPosts(input);
              });
            }
          },
        ),
      ),
      //body: _users == null
        body: _posts == null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: OrientationBuilder(
            builder: (context, orentation) {
              return Container(
                height: 520,
                width: orentation == Orientation.portrait ? 350 : 220,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        child: Image.asset('assets/images/search.png')),
                    Text('Search for something or somebody',
                      style: TextStyle(fontFamily: 'ProductSans'),),
                  ],
                ),
              );
            },
          ),
        ),
      )
          : FutureBuilder(
        //future: _users,
          future: _posts,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data.documents.length == 0) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: OrientationBuilder(
                  builder: (context, orentation) {
                    return Container(
                      height: 320,
                      width: orentation == Orientation.portrait ? 420 : 220,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset('assets/images/notfound.png'),
                          Text('Nothing found, try again later',
                            style: TextStyle(fontFamily: 'ProductSans'),),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          }
          //User author = snapshot.data;
          return OrientationBuilder(
          builder: (context, orentation) {
            return GridView.builder(
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: orentation == Orientation.portrait ? 1 : 2,),
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) {
                Post post = Post.fromDoc(snapshot.data.documents[index]);
                //User author;
                return FutureBuilder(
                    future: DatabaseService.getUserWithId(post.authorId),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) {
                        return SizedBox.shrink();
                      }
                      User author = snapshot.data;
                      return SearchPostView(
                        //currentUserId: widget.currentUserId,
                        post: post,
                        author: author,
                      );
                    }
                );
              },
            );
          },);
          /*return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (BuildContext context, int index) {
              User user = User.fromDoc(snapshot.data.documents[index]);
              return _buildUserTile(user);
            },
          );*/
        },
      ),
    );
  }
}
