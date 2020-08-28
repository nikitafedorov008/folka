import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:folka/models/Post.dart';
import 'package:folka/models/User.dart';
import 'package:folka/screens/ProfleSmbScreen.dart';
import 'package:folka/screens/QrScreen.dart';
import 'package:folka/services/ShareService.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:super_qr_reader/super_qr_reader.dart';
import 'package:url_launcher/url_launcher.dart';


class DetailsScreen extends StatefulWidget {

  final String currentUserId;
  final String userId;
  final bool authorScanBool;

  final Post post;
  final User author;
  Future<void> _launched;

  DetailsScreen({this.post, this.author, this.currentUserId, this.userId, this.authorScanBool});

  @override
  State<StatefulWidget> createState() {

    return _DetailsScreenState();
  }
}

class _DetailsScreenState extends State<DetailsScreen> {

  GoogleMapController mapController;
  String searchAddress;
  String result = '';

  @override
  void initState() {
    super.initState();
    print('current user: ${widget.currentUserId}');
    //searchAndNavigate();
  }



  _showQr() {
    if (widget.authorScanBool == true) {
      return Platform.isIOS ? _iosQr() : _androidQr();
    } else if (widget.authorScanBool == false) {
      return Platform.isIOS ? _iosQr() : _androidQr();
    }
  }

  _iosQr() {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: CupertinoColors.white,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: QrImage(
                data: widget.author.id + widget.post.name,
              ),
            ),
          );
        });
  }

  _androidQr() {
    return showDialog(context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            //backgroundColor: Colors.greenAccent,
            title: Text('Let scan this qr code', style: TextStyle(fontFamily: 'ProductSans'),),
            children: <Widget>[
              SimpleDialogOption(
                child: Container(
                  width: 100,
                  height: 240,
                  child: QrImage(
                    backgroundColor: Colors.white,
                    data: widget.post.name + widget.author.id,
                  ),
                ),
                //onPressed: ()=> _handleImage(ImageSource.camera),
              ),
              SimpleDialogOption(
                child: Row(
                  children: <Widget>[
                    Icon(OMIcons.cancel, color: Colors.red,),
                    SizedBox(width: 5.0,),
                    Text('Cancel', style: TextStyle(fontFamily: 'ProductSans', color: Colors.red),),
                  ],
                ),
                onPressed: ()=> Navigator.pop(context),
              ),
            ],
          );
        },);
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

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  makeCall() {
    _launchUrl('tel:${widget.author.phone}');
  }

  sendSms() {
    _launchUrl('sms:${widget.author.phone}?body=Hi%20there,%20its%20shelf%20app%20user');
  }

  sendEmail() {
    _launchUrl(
        'mailto:${widget.author.email}'
        '?subject=Shelf app - ${widget.post.name}'
            '&body=<body>, e.g. mailto:smith@example.org'
            '?subject=News&body=Hi%20there,%20its%20shelf%20app%20user');
  }

  makeRoute() {
    MapsLauncher.launchQuery( widget.post.location/*+ '' + widget.author.address*/);
  }

  // https://yandex.ru/dev/taxi/doc/dg/concepts/deeplinks-docpage/ ссылка на документацию
  takeTaxi() {
    _launchUrl('https://3.redirect.appmetrica.yandex.com/route?'
        //Широта точки назначения
        + 'end-lat=' + '${Geocoder.local.findAddressesFromQuery(widget.post.location)}'
        //Долгота точки назначения
        + '&end-lon=' + '${Geocoder.local.findAddressesFromQuery(widget.post.location)}'
        //Идентификатор источника
        + '&ref=' + 'shelf'
        //Идентификатор, который определяет логику редиректа
        + '&appmetrica_tracking_id=' + '25395763362139037'
    );
  }

  _iosRouteBottomSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text('Choose Route'),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text('Route'),
              onPressed: () => makeRoute(),
            ),
            CupertinoActionSheetAction(
              child: Text('Take Taxi'),
              onPressed: () => takeTaxi(),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        );
      },
    );
  }

  _androidRouteBottomSheet() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(6.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              //color: Colors.white,
              child: Container(
                //color: Colors.transparent,
                child: new Wrap(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0,),
                      child: new Text('Choose Route', style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 18.0),),
                    ),
                    new ListTile(
                        leading: new Icon(OMIcons.map),
                        title: new Text('Route', style: TextStyle(fontFamily: 'ProductSans'),),
                        onTap: () => makeRoute(),
                    ),
                    new ListTile(
                      leading: new Icon(OMIcons.localTaxi),
                      title: new Text('Take Taxi', style: TextStyle(fontFamily: 'ProductSans'),),
                      onTap: () => makeRoute(),
                    ),
                    new ListTile(
                      leading: new Icon(OMIcons.cancel, color: Colors.redAccent,),
                      title: new Text('Cancel', style: TextStyle(fontFamily: 'ProductSans', color: Colors.redAccent),),
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  _iosContactBottomSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text('Choose Action'),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text('Call'),
              onPressed: () => makeCall(),
            ),
            CupertinoActionSheetAction(
              child: Text('SMS'),
              onPressed: () => sendSms(),
            ),
            CupertinoActionSheetAction(
              child: Text('Email'),
              onPressed: () => sendEmail(),
            ),
            CupertinoActionSheetAction(
              child: Text('Dashboard message'),
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                    context: context,
                    builder: (BuildContext context) => CupertinoAlertDialog(
                      title: new Text('Dashboard message'),
                      content: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new Text(
                          '1. Choose picture of this product\n'
                          '2. Write your message on dashboard\n'
                          '3. Send it and wait for answer',
                        ),
                      ),
                      actions: <Widget>[
                        CupertinoDialogAction(
                          isDefaultAction: true,
                          child: Text('Lets Go'),
                          onPressed: ()=> pushToProfile(),
                        ),
                        CupertinoDialogAction(
                          child: Text('Cancel', style: TextStyle(color: CupertinoColors.destructiveRed),),
                          onPressed: ()=> Navigator.pop(context),
                        )
                      ],
                    )
                );
              }
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        );
      },
    );
  }

  _androidContactBottomSheet() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(6.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              //color: Colors.white,
              child: Container(
                height: 330,
                //color: Colors.transparent,
                child: new ListView(
                  physics: BouncingScrollPhysics(),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0,),
                      child: new Text('Choose Action', style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 18.0),),
                    ),
                    new ListTile(
                        leading: new Icon(OMIcons.phone),
                        title: new Text('Call', style: TextStyle(fontFamily: 'ProductSans'),),
                        onTap: () => makeCall(),
                    ),
                    new ListTile(
                      leading: new Icon(OMIcons.sms),
                      title: new Text('SMS', style: TextStyle(fontFamily: 'ProductSans'),),
                      onTap: () => sendSms(),
                    ),
                    new ListTile(
                      leading: new Icon(OMIcons.email),
                      title: new Text('Email', style: TextStyle(fontFamily: 'ProductSans'),),
                      onTap: () => sendEmail(),
                    ),
                    new ListTile(
                        leading: new Icon(OMIcons.dashboard),
                        title: new Text('Dashboard Message', style: TextStyle(fontFamily: 'ProductSans'),),
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  title: Text('Dashboard Message', style: TextStyle(fontFamily: 'ProductSans'),),
                                  content: Container(
                                    height: 290,
                                    width: 520,
                                    child: OrientationBuilder(
                                      builder: (context, orientation){
                                        if (orientation == Orientation.portrait) {
                                          return Column(
                                            children: <Widget>[
                                              Container(
                                                  child: Image(image: AssetImage('assets/images/messages.png'),)
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  '1. Choose picture of this product\n'
                                                      '2. Write your message on dashboard\n'
                                                      '3. Send it and wait for answer',
                                                  style: TextStyle(fontFamily: 'ProductSans'),
                                                ),
                                              ),
                                            ],
                                          );
                                        } else {
                                          return Row(
                                            children: <Widget>[
                                              Container(
                                                  child: Image(image: AssetImage('assets/images/messages.png'),)
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  '1. Choose picture of this product\n'
                                                      '2. Write your message on dashboard\n'
                                                      '3. Send it and wait for answer',
                                                  style: TextStyle(fontFamily: 'ProductSans'),
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16.0),
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(OMIcons.checkCircle),
                                          Text('Lets Go', style: TextStyle(fontFamily: 'ProductSans'),),
                                        ],
                                      ),
                                      onPressed: ()=> pushToProfile(),
                                    ),
                                    FlatButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16.0),
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(OMIcons.cancel, color: Colors.red,),
                                          Text('Cancel', style: TextStyle(fontFamily: 'ProductSans', color: Colors.red),),
                                        ],
                                      ),
                                      onPressed: ()=> Navigator.pop(context),
                                    ),
                                  ],
                                );
                              }
                          );
                        }
                    ),
                    new ListTile(
                      leading: new Icon(OMIcons.cancel, color: Colors.redAccent,),
                      title: new Text('Cancel', style: TextStyle(fontFamily: 'ProductSans', color: Colors.redAccent),),
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {

       BuildContext _scaffoldContext;

       pushToQr() async {
         if(widget.authorScanBool == true) {
           Navigator.push(
             context,
             MaterialPageRoute(
               builder: (_) => QrScreen(
                 userId: widget.author.id,
                 post: widget.post,
                 currentUserId: widget.currentUserId,
                 authorScanBool: widget.authorScanBool,
                 //author: widget.author,
                 //likeCount: _likeCount,
               ),
             ),
           );
         } else if (widget.authorScanBool == false) {
           String results = await Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (context) => ScanView(),
               ),
           ); if (results != null) {
             setState(() {
               result = results;
               print('qr code result = ' + result);
             });
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (context) => QrScreen(
                   userId: widget.author.id,
                   post: widget.post,
                   currentUserId: widget.currentUserId,
                   authorScanBool: widget.authorScanBool,
                 ),
               ),
             );
           }
         }
       }

       searchAndNavigate() {
         searchAddress = widget.author.address+ ' ' + widget.post.location;
         Geolocator().placemarkFromAddress(searchAddress).then((result) {
           mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
               target: LatLng(result[0].position.latitude, result[0].position.longitude),
               zoom: 15.0)));
         });
       }

       void onMapCreated(controller) {
         setState(() {
           searchAndNavigate();
           mapController = controller;
         });
       }

       _showSelectContactSheet() {
         return Platform.isIOS ? _iosContactBottomSheet() : _androidContactBottomSheet();
       }

       _showSelectRouteSheet() {
         return Platform.isIOS ? _iosRouteBottomSheet() : _androidRouteBottomSheet();
       }

       Widget mapSection = Container(
         height: 400,
         width: 400,
         child: GoogleMap(
             onMapCreated: onMapCreated,
             initialCameraPosition: CameraPosition(
                 target: LatLng(59.9617101, 30.3135917), zoom: 10.0
             )),
       );

       Widget addressSection = Container(
         //padding: const EdgeInsets.all(32),
         child: Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: <Widget>[
             Icon(
               OMIcons.place,
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
                     onPressed: _showSelectContactSheet,
                     child: Column(
                       mainAxisSize: MainAxisSize.min,
                       mainAxisAlignment: MainAxisAlignment.center,
                       children:[
                         Icon(OMIcons.message, /*color: Colors.black*/),
                         Container(
                           margin: const EdgeInsets.only(top:8),
                           child: Text(
                             'CONTACT',
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
                     onPressed: _showSelectRouteSheet,
                     child: Column(
                       mainAxisSize: MainAxisSize.min,
                       mainAxisAlignment: MainAxisAlignment.center,
                       children:[
                         Icon(OMIcons.nearMe, /*color: Colors.black*/),
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
                     onPressed: pushToQr,
                     child: Column(
                       mainAxisSize: MainAxisSize.min,
                       mainAxisAlignment: MainAxisAlignment.center,
                       children:[
                         Icon(OMIcons.description, /*color: Colors.black*/),
                         Container(
                           margin: const EdgeInsets.only(top:8),
                           child: Text(
                             'SCAN',
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
                     OMIcons.map,
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
                     OMIcons.star,
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
                           OMIcons.attachMoney,
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
                       Text(' per', style: TextStyle(fontFamily: 'ProductSans', fontSize: 18),),
                       Icon(
                         OMIcons.timer,
                         color: Colors.blue,
                         size: 32.0,
                       ),
                       Text(
                         widget.post.time,
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
               SliverOverlapAbsorber(
                 handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
               ),
               SliverAppBar(
                 backgroundColor: Colors.transparent,
                 elevation: 0,
                 expandedHeight: 350.0,
                 floating: false,
                 pinned: true,
                 actions: <Widget>[
                   IconButton(
                     icon: Icon(OMIcons.share),
                     tooltip: 'share',
                     onPressed: () {
                       share(
                         context,
                         '${widget.post.name} -\n'
                         '${widget.post.caption}\n\n'
                         'price = ${widget.post.price}RUB in ${widget.post.time}\n\n'
                         'location: ${widget.post.location +' '+ widget.author.address}\n\n'
                         'property owner: ${widget.author.name +' '+ widget.author.surname}\n\n'
                         'tel: ${widget.author.phone}\n'
                         'email: ${widget.author.email}\n\n'
                         'send from Shelf app\n\n'
                         'https://play.google.com/store/apps/details?id=nudle.shelf',
                       );
                     },
                   ),
                 ],
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
