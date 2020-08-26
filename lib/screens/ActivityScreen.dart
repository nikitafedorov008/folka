import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:folka/models/Activity.dart';
import 'package:folka/models/Post.dart';
import 'package:folka/models/UserData.dart';
import 'package:folka/models/User.dart';
import 'package:folka/screens/CommentsScreen.dart';
import 'package:folka/services/DatabaseService.dart';
import 'package:folka/widgets/HidingAppBar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ActivityScreen extends StatefulWidget {
  final String currentUserId;

  ActivityScreen({this.currentUserId});

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<Activity> _activities = [];

  @override
  void initState() {
    super.initState();
    _setupActivities();
  }

  _setupActivities() async {
    List<Activity> activities =
    await DatabaseService.getActivities(widget.currentUserId);
    if (mounted) {
      setState(() {
        _activities = activities;
      });
    }
  }

  _buildActivity(Activity activity) {
    return FutureBuilder(
      future: DatabaseService.getUserWithId(activity.fromUserId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }
        User user = snapshot.data;
        return ListTile(
          leading: CircleAvatar(
            radius: 20.0,
            backgroundColor: Colors.grey,
            backgroundImage: user.profileImageUrl.isEmpty
                ? AssetImage('assets/images/avatar.png')
                : CachedNetworkImageProvider(user.profileImageUrl),
          ),
          title: activity.comment != null
              ? Text('${user.name} send you messege: "${activity.comment}"',
            style: TextStyle(fontFamily: 'ProductSans'),)
              : Text('${user.name} liked your post',
            style: TextStyle(fontFamily: 'ProductSans'),),
          subtitle: Text(
            DateFormat.yMd().add_jm().format(activity.timestamp.toDate(),),
            style: TextStyle(fontFamily: 'ProductSans'),
          ),
          trailing: CachedNetworkImage(
            imageUrl: activity.postImageUrl,
            height: 40.0,
            width: 40.0,
            fit: BoxFit.cover,
          ),
          onTap: () async {
            String currentUserId = Provider.of<UserData>(context).currentUserId;
            Post post = await DatabaseService.getUserPost(
              currentUserId,
              activity.postId,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CommentsScreen(
                  post: post,
                  likeCount: post.likeCount,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            HidingAppBar(forceElevated: innerBoxIsScrolled),
          ];
        },
        body: RefreshIndicator(
          onRefresh: () => _setupActivities(),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: _activities.length,
            itemBuilder: (BuildContext context, int index) {
              Activity activity = _activities[index];
              return _buildActivity(activity);
            },
          ),
        ),
      ),
    );
  }
}
