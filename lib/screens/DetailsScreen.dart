import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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


class DetailsScreen extends StatefulWidget {

  final Post post;
  final User author;

  DetailsScreen({this.post, this.author});

  @override
  State<StatefulWidget> createState() {

    return _DetailsScreenState();
  }
}

class _DetailsScreenState extends State<DetailsScreen> {

  @override
  Widget build(BuildContext context) {

    Widget textSection = Container(
      padding: const EdgeInsets.all(32),
      child: Text(
        widget.post.caption,
        //"Word 'Japanism' means the comunity that explore and collect japanise culture and tranditinals",
        softWrap: true,
        textAlign: TextAlign.justify,
        style: TextStyle(fontFamily: 'ProductSans'),
      ),
    );

    //Color color = Theme.of(context).primaryColor;
    Color color = Colors.green;

    Widget buttonSection = Container(
      //color: Colors.black12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:[
          buildButtonColumn(color, Icons.call, "CALL",),
          buildButtonColumn(color, Icons.near_me, "ROUTE"),
          buildButtonColumn(color, Icons.share, "SHARE"),
        ],
      ),
    );

    Widget titleSection = Container(
      padding: const EdgeInsets.all(33),
      child: Row(
        children:[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Container(
                  padding: const EdgeInsets.only(bottom:8),
                  child: Text(
                    //"Japanism",
                    widget.post.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      //"Kyoto",
                      widget.post.price + 'RUB',
                      style: TextStyle(color: Colors.green, fontFamily: 'ProductSans'),
                    ),
                    SizedBox(width: 10,),
                    Text(
                      //"Kyoto",
                      widget.post.time + 'DAYS',
                      style: TextStyle(color: Colors.indigo, fontFamily: 'ProductSans'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.star,
            color: Colors.red,
          ),
          Text(widget.post.likeCount.toString())
        ],
      ),
    );

    return new Scaffold(
      /*appBar: new AppBar(
        bottomOpacity: 0.0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: new Text("Details", style: TextStyle(fontFamily: 'ProductSans'),),
      ),*/
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
          return<Widget>[
            SliverAppBar(
              expandedHeight: 350.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: new Text("Details", style: TextStyle(fontFamily: 'ProductSans'),),
                background: Container(
                  height: 350,
                  width: 241,
                  //height: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(widget.post.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: ListView(
          children: <Widget>[
            /*Image.asset(
              "images/japanism.jpg",
              width: 600,
              height: 241,
              fit: BoxFit.cover,
            ),*/
            /*Container(
              height: 350,
              width: 241,
              //height: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(widget.post.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),*/
            titleSection,
            buttonSection,
            textSection,
          ],
        ),
      ),
    );
  }


  Column buildButtonColumn(Color color, IconData icon, String lable){
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children:[
        Icon(icon, color: color),
        Container(
          margin: const EdgeInsets.only(top:8),
          child: Text(
            lable,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w100,
              color: color,
            ),
          ),
        )
      ],
    );
  }

}
