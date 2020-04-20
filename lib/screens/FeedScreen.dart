import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:folka/models/Post.dart';
import 'package:folka/models/User.dart';
import 'package:folka/screens/ProfileScreen.dart';
import 'package:folka/services/DatabaseService.dart';
import 'package:folka/widgets/GridPostView.dart';
import 'package:folka/widgets/PostView.dart';

class FeedScreen extends StatefulWidget {
  static final String id = 'feed_screen';
  final String currentUserId;

  FeedScreen({this.currentUserId});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _setupFeed();
  }

  _setupFeed() async {
    //List<Post> posts = await DatabaseService.getFeedPosts(widget.currentUserId);
    List<Post> posts = await DatabaseService.getAllUserPosts();
    setState(() {
      _posts = posts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _setupFeed(),
        child: OrientationBuilder(
          builder: (context, orentation) {
            return GridView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: orentation == Orientation.portrait ? 2 : 4,),
                itemCount: _posts.length,
                itemBuilder: (BuildContext context, int index) {
                  Post post = _posts[index];
                  return FutureBuilder(
                      future: DatabaseService.getUserWithId(post.authorId),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          return SizedBox.shrink();
                        }
                        User author = snapshot.data;
                        return GridPostView(
                          //currentUserId: widget.currentUserId,
                          post: post,
                          author: author,
                        );
                      }
                  );
                }
            );}
        ),
        /*child: ListView.builder(
          itemCount: _posts.length,
          itemBuilder: (BuildContext context, int index) {
            Post post = _posts[index];
            return FutureBuilder(
              future: DatabaseService.getUserWithId(post.authorId),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox.shrink();
                }
                User author = snapshot.data;
                return PostView(
                  currentUserId: widget.currentUserId,
                  post: post,
                  author: author,
                );
              },
            );
          },
        ),*/
      ),
    );
  }
}
