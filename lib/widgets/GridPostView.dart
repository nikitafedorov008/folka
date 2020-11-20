import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:folka/models/Post.dart';
import 'package:folka/models/User.dart';
import 'package:folka/screens/CommentsScreen.dart';
import 'package:folka/screens/DetailsScreen.dart';
import 'package:folka/screens/ProfileScreen.dart';
import 'package:folka/services/DatabaseService.dart';

class GridPostView extends StatefulWidget {
  final String currentUserId;
  final Post post;
  final User author;

  GridPostView({this.currentUserId, this.post, this.author});

  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<GridPostView> {
  int _likeCount = 0;
  bool _isLiked = false;
  bool _heartAnim = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likeCount;
    _initPostLiked();
  }

  @override
  void didUpdateWidget(GridPostView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.likeCount != widget.post.likeCount) {
      _likeCount = widget.post.likeCount;
    }
  }

  _initPostLiked() async {
    bool isLiked = await DatabaseService.didLikePost(
      currentUserId: widget.currentUserId,
      post: widget.post,
    );
    if (mounted) {
      setState(() {
        _isLiked = isLiked;
      });
    }
  }

  _likePost() {
    if (_isLiked) {
      // Unlike Post
      DatabaseService.unlikePost(
          currentUserId: widget.currentUserId, post: widget.post);
      setState(() {
        _isLiked = false;
        _likeCount = _likeCount - 1;
      });
    } else {
      // Like Post
      DatabaseService.likePost(
          currentUserId: widget.currentUserId, post: widget.post);
      setState(() {
        _heartAnim = true;
        _isLiked = true;
        _likeCount = _likeCount + 1;
      });
      Timer(Duration(milliseconds: 350), () {
        setState(() {
          _heartAnim = false;
        });
      });
    }
  }

  pushToDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailsScreen(
          currentUserId: widget.currentUserId,
          post: widget.post,
          author: widget.author,
          authorScanBool: false,
          //likeCount: _likeCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: pushToDetails,
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 1,
        margin: EdgeInsets.all(3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Container(
          width: 320,
          height: 320,
          child: Column(
            children: <Widget>[
              GestureDetector(
                onDoubleTap: _likePost,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Container(
                      height: 124,
                      width: 224,
                      //height: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.0),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(widget.post.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                IconButton(
                                  icon: _isLiked
                                      ? Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                  )
                                      : Icon(Icons.star_border),
                                  iconSize: 25.0,
                                  color: Colors.greenAccent,
                                  onPressed: _likePost,
                                ),
                              ],
                            ),
                            Stack(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.mail_outline),
                                  iconSize: 25.0,
                                  color: Colors.greenAccent,
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CommentsScreen(
                                        post: widget.post,
                                        likeCount: _likeCount,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    _heartAnim
                        ? Animator(
                      duration: Duration(milliseconds: 300),
                      tween: Tween(begin: 0.5, end: 1.4),
                      curve: Curves.elasticOut,
                      builder: (anim) => Transform.scale(
                        scale: anim.value,
                        child: Icon(
                          Icons.stars,
                          size: 100.0,
                          color: Colors.yellow[400],
                        ),
                      ),
                    )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    /*Row(
                      children: <Widget>[
                        IconButton(
                          icon: _isLiked
                              ? Icon(
                            Icons.star,
                            color: Colors.yellow,
                          )
                              : Icon(Icons.star_border),
                          iconSize: 30.0,
                          onPressed: _likePost,
                        ),
                        IconButton(
                          icon: Icon(Icons.mail_outline),
                          iconSize: 30.0,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CommentsScreen(
                                post: widget.post,
                                likeCount: _likeCount,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          widget.post.name,
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'ProductSans'
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),*/
                    SizedBox(height: 2,),
                    Text(
                      widget.post.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        fontFamily: 'ProductSans',
                        //color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 2,),
                    Row(
                      children: <Widget>[
                        Icon(Icons.attach_money, color: Colors.green,),
                        Text(
                          widget.post.price + 'RUB',
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'ProductSans'
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(' per', style: TextStyle(fontFamily: 'ProductSans'),),
                        Icon(Icons.timer, color: Colors.blue,),
                        Text(
                          widget.post.time,
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'ProductSans'
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        widget.post.caption,
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'ProductSans'
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    /*Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        '${_likeCount.toString()} stars',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: 'ProductSans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),*/
                    //SizedBox(height: 4.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
