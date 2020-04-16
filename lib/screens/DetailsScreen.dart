import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:folka/models/Post.dart';
import 'package:folka/models/User.dart';
import 'package:folka/screens/ProfleSmbScreen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
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

  GoogleMapController mapController;
  String searchAddress;

  @override
  void initState() {
    super.initState();
    //searchAndNavigate();
  }

  @override
  Widget build(BuildContext context) {

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
    
    searchAndNavigate() {
      searchAddress = widget.author.address+ ' ' + widget.post.location;
      Geolocator().placemarkFromAddress(searchAddress).then((result) {
        mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target:
            LatLng(result[0].position.latitude, result[0].position.longitude),
            zoom: 15.0)));
      });
    }

    void onMapCreated(controller) {
      setState(() {
        searchAndNavigate();
        mapController = controller;
      });
    }

    Widget mapSection = Container(
      height: 400,
      width: 400,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: GoogleMap(
          onMapCreated: onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(40.7128, -74.0060), zoom: 10.0
          )),
      ),
    );

    Widget addressSection = Container(
      //padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.location_on,
            size: 16.0,
            color: Colors.yellow,
          ),
          Text(
            widget.post.location + '-' + widget.author.address,
            softWrap: true,
            textAlign: TextAlign.justify,
            style: TextStyle(fontFamily: 'ProductSans',
            color: Colors.yellow
            ),
          ),
        ],
      ),
    );

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
      child: Padding(
        padding: const EdgeInsets.all(6.0),
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
                      Icon(Icons.call, /*color: Colors.black*/),
                      Container(
                        margin: const EdgeInsets.only(top:8),
                        child: Text(
                          'CALL',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w100,
                            //color: color,
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
                      Icon(Icons.near_me, /*color: Colors.black*/),
                      Container(
                        margin: const EdgeInsets.only(top:8),
                        child: Text(
                          'ROUTE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w100,
                            //color: color,
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
                      Icon(Icons.share, /*color: Colors.black*/),
                      Container(
                        margin: const EdgeInsets.only(top:8),
                        child: Text(
                          'SHARE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w100,
                            //color: color,
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
      ),
    );

    Widget authorSection = Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: CircleAvatar(
            radius: 30.0,
            backgroundColor: Colors.grey,
            backgroundImage: widget.author.profileImageUrl.isEmpty
                ? AssetImage('assets/images/avatar.png')
                : CachedNetworkImageProvider(
                widget.author.profileImageUrl),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                //SizedBox(width: 8.0),
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
                SizedBox(width: 8.0),
                Icon(
                  Icons.map,
                  color: Colors.yellow,
                ),
                Text(
                  widget.author.address,
                  style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 14.0,
                    fontFamily: 'ProductSans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text(
                  widget.author.email,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16.0,
                    fontFamily: 'ProductSans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 5.0,),
                Icon(
                  Icons.star,
                  color: Colors.red,
                ),
                Text(widget.post.likeCount.toString()),
              ],
            ),
          ],
        ),
      ],
    );

    Widget titleSection = Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Row(
        children:[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 2.0),
                      child: Icon(
                        Icons.timer,
                        color: Colors.green,
                        size: 32.0,
                      ),
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
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Divider(
                    thickness: 3.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

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
            titleSection,
            GestureDetector(
                onTap: pushToProfile,
                child: authorSection),
            buttonSection,
            textSection,
            mapSection,
            addressSection,
          ],
        ),
      ),
    );
  }
}
