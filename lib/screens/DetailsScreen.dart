import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:folka/models/Post.dart';
import 'package:folka/models/User.dart';
import 'package:folka/screens/ProfleSmbScreen.dart';
import 'package:url_launcher/url_launcher.dart';


class DetailsScreen extends StatefulWidget {

  final Post post;
  final User author;
  Future<void> _launched;

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
        softWrap: true,
        textAlign: TextAlign.justify,
        style: TextStyle(fontFamily: 'ProductSans'),
      ),
    );

    //Color color = Theme.of(context).primaryColor;
    Color color = Colors.black;

    Widget buttonSection = Container(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        color: Colors.black12,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:[
              FlatButton(
                onPressed: makeCall,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    Icon(Icons.call, color: Colors.black),
                    Container(
                      margin: const EdgeInsets.only(top:8),
                      child: Text(
                        'CALL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w100,
                          color: color,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              FlatButton(
                //onPressed: makeCall,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    Icon(Icons.near_me, color: Colors.black),
                    Container(
                      margin: const EdgeInsets.only(top:8),
                      child: Text(
                        'ROUTE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w100,
                          color: color,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              FlatButton(
                //onPressed: makeCall,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    Icon(Icons.share, color: Colors.black),
                    Container(
                      margin: const EdgeInsets.only(top:8),
                      child: Text(
                        'SHARE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w100,
                          color: color,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              /*buildButtonColumn(color, Icons.call, "CALL",),
              buildButtonColumn(color, Icons.near_me, "ROUTE"),
              buildButtonColumn(color, Icons.share, "SHARE"),*/
            ],
          ),
        ),
      ),
    );

    Widget authorSection = Row(
      children: <Widget>[
        CircleAvatar(
          radius: 25.0,
          backgroundColor: Colors.grey,
          backgroundImage: widget.author.profileImageUrl.isEmpty
              ? AssetImage('assets/images/avatar.png')
              : CachedNetworkImageProvider(
              widget.author.profileImageUrl),
        ),
        SizedBox(width: 8.0),
        Text(
          widget.author.name,
          style: TextStyle(
            fontSize: 18.0,
            fontFamily: 'ProductSans',
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 4.0),
        Text(
          widget.author.surname,
          style: TextStyle(
            fontSize: 18.0,
            fontFamily: 'ProductSans',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    Widget titleSection = Container(
      padding: const EdgeInsets.all(33),
      child: Row(
        children:[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                /*Container(
                  padding: const EdgeInsets.only(bottom:8),
                  child: Text(
                    widget.post.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),*/
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.timer,
                      color: Colors.green,
                      size: 32.0,
                    ),
                    Text(
                      widget.post.price + 'RUB',
                      style: TextStyle(
                          color: Colors.green,
                          fontFamily: 'ProductSans',
                          fontSize: 22.0,
                      ),),
                    SizedBox(width: 10,),
                    Icon(
                      Icons.attach_money,
                      color: Colors.blue,
                      size: 32.0,
                    ),
                    Text(
                      widget.post.time + 'DAYS',
                      style: TextStyle(
                          color: Colors.blue,
                          fontFamily: 'ProductSans',
                          fontSize: 22.0,
                      ),),
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
              backgroundColor: Colors.transparent,
              elevation: 0,
              expandedHeight: 350.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: new Text(widget.post.name, style: TextStyle(fontFamily: 'ProductSans'),),
                background: Container(
                  height: 350,
                  width: 241,
                  //height: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    //borderRadius: BorderRadius.circular(12.0),
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
            buttonSection,
            titleSection,
            textSection,
            GestureDetector(
              onTap: pushToProfile,
                child: authorSection),
          ],
        ),
      ),
    );
  }

  pushToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileSMDScreen(
          userId: widget.author.id,
          //author: widget.author,
          //likeCount: _likeCount,
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

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  makeCall() {
    _makePhoneCall('tel:${widget.author.phone}');
  }

}
