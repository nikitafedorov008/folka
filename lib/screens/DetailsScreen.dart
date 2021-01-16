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
import 'package:photo_view/photo_view.dart';
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
  LatLng taxiLatLng;

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
        //+ 'end-lat=' + '${Geocoder.local.findAddressesFromQuery(widget.post.location)}'
        + 'end-lat=' + '${taxiLatLng.latitude}'
        //Долгота точки назначения
        //+ '&end-lon=' + '${Geocoder.local.findAddressesFromQuery(widget.post.location)}'
        + '&end-lon=' + '${taxiLatLng.longitude}'
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
                      onTap: () => takeTaxi(),
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
               target: taxiLatLng = LatLng(result[0].position.latitude, result[0].position.longitude),
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

       Widget _mapSection = Container(
         decoration: BoxDecoration(
           border: Border.all(
             color: Colors.black,
             width: 8,
           ),
           borderRadius: BorderRadius.circular(12),
         ),
         height: 220,
         width: 600,
         child: GoogleMap(
             onMapCreated: onMapCreated,
             initialCameraPosition: CameraPosition(
                 target: LatLng(59.9617101, 30.3135917), zoom: 10.0
             )),
       );

       Widget _addressSection = Container(
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

       Widget _textSection = Container(
         padding: const EdgeInsets.fromLTRB(22, 10, 22, 12,),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
               Icon(OMIcons.category, color: Colors.grey,),
               Text('Category: ' + widget.post.category, style: TextStyle(fontFamily: 'ProductSans', fontSize: 16, color: Colors.grey),),
             ],),
             SizedBox(height: 12,),
             Text(
               widget.post.caption,
               softWrap: true,
               textAlign: TextAlign.justify,
               style: TextStyle(fontFamily: 'ProductSans'),
             ),
           ],
         ),
       );

       //Color color = Theme.of(context).primaryColor;
       Color color = Colors.black;

       Widget _buttonSection = Container(
         child: Card(
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(34)),
           color: Colors.greenAccent,
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
                       Icon(OMIcons.message, color: Colors.black87),
                       Container(
                         margin: const EdgeInsets.only(top:8),
                         child: Text(
                           'CONTACT',
                           style: TextStyle(
                             fontSize: 12,
                             fontWeight: FontWeight.normal,
                             color: Colors.black87,
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
                       Icon(OMIcons.nearMe, color: Colors.black87,),
                       Container(
                         margin: const EdgeInsets.only(top:8),
                         child: Text(
                           'ROUTE',
                           style: TextStyle(
                             fontSize: 12,
                             fontWeight: FontWeight.normal,
                             color: Colors.black87,
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
                       Icon(OMIcons.description, color: Colors.black87,),
                       Container(
                         margin: const EdgeInsets.only(top:8),
                         child: Text(
                           'SCAN',
                           style: TextStyle(
                             fontSize: 12,
                             fontWeight: FontWeight.normal,
                             color: Colors.black87,
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
       );

       Widget _authorSection = Row(
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
                       Chip(
                         avatar: CircleAvatar(
                           backgroundColor: Colors.green,
                           child: Icon(OMIcons.attachMoney, color: Colors.black87, size: 24,),
                         ),
                         label: Text(widget.post.price + ' RUB', style: TextStyle(fontFamily: 'ProductSans', fontSize: 22, color: Colors.green),),
                       ),
                       Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 2.0),
                         child: Text(' per', style: TextStyle(fontFamily: 'ProductSans', fontSize: 18),),
                       ),
                       Chip(
                         avatar: CircleAvatar(
                           backgroundColor: Colors.blue,
                           child: Icon(OMIcons.timer, color: Colors.black87, size: 24,),
                         ),
                         label: Text(widget.post.time, style: TextStyle(fontFamily: 'ProductSans', fontSize: 22, color: Colors.blue),),
                       ),
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

       bodyView() {
         return ListView(
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
                 child: _authorSection),
             _buttonSection,
             _textSection,
             _mapSection,
             _addressSection,
           ],
         );
       }

       return Scaffold(
         body: OrientationBuilder(
           builder: (context, orientation){
         if (orientation == Orientation.portrait) {
           return Scaffold(
             body: Stack(
               children: <Widget>[
                 Container(
                   foregroundDecoration: BoxDecoration(
                       color: Colors.black26
                   ),
                   height: 360,
                   width: MediaQuery.of(context).size.width,
                   child: GestureDetector(
                           child: CachedNetworkImage(
                             imageUrl: widget.post.imageUrl,
                             placeholder: (context, url) => Center(
                               child: Container(
                                   child: CircularProgressIndicator()
                               ),
                             ),
                             errorWidget: (context, url, error) => Column(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   Text("Ошибка при загрузке картинки"),
                                   Icon(Icons.error)
                                 ]
                             ),
                             fit: BoxFit.cover,
                           ),
                           onTap: () => showDialog(
                             context: context,
                             child: SimpleDialog(
                               backgroundColor: Colors.transparent,
                               children: <Widget>[
                                 Container(
                                   decoration: BoxDecoration(
                                     color: Colors.black,
                                     borderRadius: BorderRadius.all(
                                         Radius.circular(30)
                                     ),
                                   ),
                                   width: MediaQuery.of(context).size.width,
                                   height: 400,
                                   child: Padding(
                                     padding: const EdgeInsets.all(10.0),
                                     child: PhotoView(
                                       backgroundDecoration: BoxDecoration(
                                         color: Colors.black,
                                         borderRadius: BorderRadius.all(
                                             Radius.circular(30)
                                         ),
                                       ),
                                       imageProvider: CachedNetworkImageProvider(
                                           widget.post.imageUrl
                                       ),
                                     ),
                                   ),
                                 ),
                               ],
                             ),
                           ),
                   ),
                 ),
                 SingleChildScrollView(
                   padding: const EdgeInsets.only(top: 16.0,bottom: 20.0),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: <Widget>[
                       const SizedBox(height: 250),
                       Padding(
                         padding: const EdgeInsets.symmetric(horizontal:16.0),
                         child: Text(
                           widget.post.name,
                           style: TextStyle(color: Colors.white, fontSize: 28.0, fontWeight: FontWeight.bold, fontFamily: 'ProductSans',),
                         ),
                       ),
                       Row(
                         children: <Widget>[
                           const SizedBox(width: 16.0),
                           Container(
                             padding: const EdgeInsets.symmetric(
                               vertical: 8.0,
                               horizontal: 16.0,
                             ),
                             decoration: BoxDecoration(
                                 color: Colors.grey,
                                 borderRadius: BorderRadius.circular(20.0)),
                             child: Text(
                               widget.post.category,
                               style: TextStyle(color: Colors.white, fontSize: 13.0, fontFamily: 'ProductSans',),
                             ),
                           ),
                           Spacer(),
                           IconButton(
                             icon: Icon(Icons.favorite_border,),
                             tooltip: 'like',
                             //onPressed: () { changePlaceLike(); },
                           ),
                         ],
                       ),
                       Container(
                         padding: const EdgeInsets.all(32.0),
                         //color: Colors.white,
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           mainAxisSize: MainAxisSize.min,
                           children: <Widget>[
                             Row(
                               children: <Widget>[
                                 Expanded(
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: <Widget>[
                                       Row(
                                         children: <Widget>[
                                           Icon(
                                             Icons.star,
                                             color: Colors.greenAccent,
                                           ),
                                           Icon(
                                             Icons.star,
                                             color: Colors.greenAccent,
                                           ),
                                           Icon(
                                             Icons.star,
                                             color: Colors.greenAccent,
                                           ),
                                           Icon(
                                             Icons.star,
                                             color: Colors.greenAccent,
                                           ),
                                           Icon(
                                             Icons.star_border,
                                             color: Colors.greenAccent,
                                           ),
                                         ],
                                       ),
                                       Text.rich(TextSpan(children: [
                                         WidgetSpan(
                                             child: Icon(OMIcons.locationOn, size: 16.0, color: Colors.grey,)
                                         ),
                                         TextSpan(
                                           text: widget.post.location,
                                         )
                                       ]), style: TextStyle(color: Colors.grey, fontSize: 12.0, fontFamily: 'ProductSans',),)
                                     ],
                                   ),
                                 ),
                                 Column(
                                   children: <Widget>[
                                     Text("\₽ ${widget.post.price}", style: TextStyle(
                                         color: Colors.greenAccent,
                                         fontWeight: FontWeight.bold,
                                         fontFamily: 'ProductSans',
                                         fontSize: 20.0
                                     ),),
                                     Text("/per ${widget.post.time}",style: TextStyle(
                                         fontFamily: 'ProductSans',
                                         fontSize: 12.0,
                                         color: Colors.grey
                                     ),)
                                   ],
                                 )
                               ],
                             ),
                             const SizedBox(height: 30.0),
                             _buttonSection,
                             /*SizedBox(
                               width: double.infinity,
                               child: RaisedButton(
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                                 color: Colors.orangeAccent,
                                 textColor: Colors.white,
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                     Icon(Icons.map),
                                     SizedBox(width: 2,),
                                     Text("Найти на карте", style: TextStyle(
                                       fontWeight: FontWeight.normal,
                                       fontFamily: 'ProductSans',
                                     ),),
                                   ],
                                 ),
                                 padding: const EdgeInsets.symmetric(
                                   vertical: 16.0,
                                   horizontal: 32.0,
                                 ),
                                 onPressed: () {MapsLauncher.launchQuery(widget.author.address + ' ' + widget.post.location,);},
                               ),
                             ),*/
                             const SizedBox(height: 30.0),
                             Text("DESCRIPTION".toUpperCase(), style: TextStyle(
                                 fontWeight: FontWeight.w600,
                                 fontFamily: 'ProductSans',
                                 fontSize: 14.0
                             ),),
                             const SizedBox(height: 10.0),
                             Text(
                               widget.post.caption, textAlign: TextAlign.justify, style: TextStyle(
                                 fontWeight: FontWeight.w300,
                                 fontFamily: 'ProductSans',
                                 fontSize: 14.0
                             ),),
                             const SizedBox(height: 10.0),
                             _mapSection,
                             const SizedBox(height: 10.0),
                             _authorSection,
                             Container(
                               //padding: const EdgeInsets.symmetric(horizontal: 8),
                               child: Wrap(
                                 alignment: WrapAlignment.spaceAround,
                                 children: [
                                   //Chip(label: Text('#'+widget.place.goals[0]),),
                                   //Chip(label: Text('#'+widget.place.goals[1]),),
                                   //Chip(label: Text('#'+widget.place.goals[2]),),
                                 ],
                               ),
                             ),
                           ],
                         ),
                       ),
                     ],
                   ),
                 ),
                 Positioned(
                   top: 0,
                   left: 0,
                   right: 0,
                   child: AppBar(
                     backgroundColor: Colors.transparent,
                     elevation: 0,
                     centerTitle: true,
                     /*title: Container(
                       decoration: BoxDecoration(
                         color: Colors.greenAccent,
                         border: Border.all(
                           color: Colors.greenAccent,
                           width: 4,
                         ),
                         borderRadius: BorderRadius.circular(12),
                       ),
                       child: new Text('DETAILS', style: TextStyle(fontFamily: 'ProductSans', fontSize:  16, color: Colors.black87),),
                     ),*/
                     actions: <Widget>[
                       Padding(
                           padding: EdgeInsets.only(right: 20.0),
                           child: GestureDetector(
                             onTap: ()=> share(
                               context,
                               '${widget.post.name} -\n'
                                   '${widget.post.caption}\n\n'
                                   'price = ${widget.post.price}RUB in ${widget.post.time}\n\n'
                                   'location: ${widget.post.location +' '+ widget.author.address}\n\n'
                                   'property owner: ${widget.author.name +' '+ widget.author.surname}\n\n'
                                   'tel: ${widget.author.phone}\n'
                                   'email: ${widget.author.email}\n\n'
                                   'send from Shelf app\n\n'
                                   'https://play.google.com/store/apps/details?id=nudle.shelf',),
                             child: Icon(
                               OMIcons.share,
                               size: 26.0,
                             ),
                           )
                       ),
                     ],
                   ),
                 ),
               ],
             ),
           );
         } else {
           return Row(
             children: [
               GestureDetector(
                 child: Container(
                   alignment: Alignment.topLeft,
                   child: Stack(
                     children: [
                       Stack(
                         children: [
                           Positioned(
                             bottom: 12,
                             left: 12,
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Padding(
                                   padding: const EdgeInsets.symmetric(horizontal:16.0),
                                   child: Text(
                                     widget.post.name,
                                     style: TextStyle(color: Colors.white, fontSize: 28.0, fontWeight: FontWeight.bold, fontFamily: 'ProductSans',),
                                   ),
                                 ),
                                 Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: <Widget>[
                                     const SizedBox(width: 16.0),
                                     Container(
                                       padding: const EdgeInsets.symmetric(
                                         vertical: 8.0,
                                         horizontal: 16.0,
                                       ),
                                       decoration: BoxDecoration(
                                           color: Colors.grey,
                                           borderRadius: BorderRadius.circular(20.0)),
                                       child: Text(
                                         widget.post.category,
                                         style: TextStyle(color: Colors.white, fontSize: 13.0, fontFamily: 'ProductSans',),
                                       ),
                                     ),
                                     //Spacer(),
                                     IconButton(
                                       icon: Icon(Icons.favorite_border,),
                                       tooltip: 'like',
                                       //onPressed: () { changePlaceLike(); },
                                     ),
                                   ],
                                 ),
                               ],
                             ),
                           ),
                         ],
                       ),
                       Padding(
                         padding: const EdgeInsets.fromLTRB(2, 26, 0, 0),
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Stack(children: [
                               IconButton(icon: Icon(OMIcons.arrowBack, size: 23,), onPressed: () { Navigator.pop(context); },),
                             ],),
                             Stack(children: [
                               Container(
                                 decoration: BoxDecoration(
                                   color: Colors.greenAccent,
                                   /*border: Border.all(
                                 color: Colors.orangeAccent,
                                 width: 2,
                               ),*/
                                   borderRadius: BorderRadius.circular(14),
                                 ),
                                 child: Padding(
                                   padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                   //child: new Text(widget.post.name, style: TextStyle(fontFamily: 'ProductSans', color: Colors.black87, fontSize: 23),),
                                 ),
                               ),
                             ],),
                             Stack(children: [
                               IconButton(icon: Icon(OMIcons.share, size: 23,), onPressed: () { share(
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
                               ); },),
                             ],),
                           ],
                         ),
                       ),
                     ],
                   ),
                   height: MediaQuery
                   .of(context)
                   .size
                   .height,
                   width: MediaQuery
                   .of(context)
                   .size
                   .width / 2.5,
                   //height: MediaQuery.of(context).size.width,
                   decoration: BoxDecoration(
                     //borderRadius: BorderRadius.circular(12.0),
                     image: DecorationImage(
                       image: CachedNetworkImageProvider(widget.post.imageUrl),
                       fit: BoxFit.cover,
                     ),
                   ),
                 ),
                 onTap: () => showDialog(
                   context: context,
                   child: SimpleDialog(
                     backgroundColor: Colors.transparent,
                     children: <Widget>[
                       Container(
                         decoration: BoxDecoration(
                           color: Colors.black,
                           borderRadius: BorderRadius.all(
                               Radius.circular(30)
                           ),
                         ),
                         width: MediaQuery.of(context).size.height,
                         height: 300,
                         child: Padding(
                           padding: const EdgeInsets.all(10.0),
                           child: PhotoView(
                             backgroundDecoration: BoxDecoration(
                               color: Colors.black,
                               borderRadius: BorderRadius.all(
                                   Radius.circular(30)
                               ),
                             ),
                             imageProvider: CachedNetworkImageProvider(widget.post.imageUrl,),
                           ),
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
               //bodyView
               Expanded(child: SingleChildScrollView(
                 padding: const EdgeInsets.only(top: 16.0,bottom: 20.0),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: <Widget>[
                     //const SizedBox(height: 250),
                     /*Padding(
                       padding: const EdgeInsets.symmetric(horizontal:16.0),
                       child: Text(
                         widget.post.name,
                         style: TextStyle(color: Colors.white, fontSize: 28.0, fontWeight: FontWeight.bold, fontFamily: 'ProductSans',),
                       ),
                     ),
                     Row(
                       children: <Widget>[
                         const SizedBox(width: 16.0),
                         Container(
                           padding: const EdgeInsets.symmetric(
                             vertical: 8.0,
                             horizontal: 16.0,
                           ),
                           decoration: BoxDecoration(
                               color: Colors.grey,
                               borderRadius: BorderRadius.circular(20.0)),
                           child: Text(
                             widget.post.category,
                             style: TextStyle(color: Colors.white, fontSize: 13.0, fontFamily: 'ProductSans',),
                           ),
                         ),
                         Spacer(),
                         IconButton(
                           icon: Icon(Icons.favorite_border,),
                           tooltip: 'like',
                           //onPressed: () { changePlaceLike(); },
                         ),
                       ],
                     ),*/
                     Container(
                       padding: const EdgeInsets.all(32.0),
                       //color: Colors.white,
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         mainAxisSize: MainAxisSize.min,
                         children: <Widget>[
                           Row(
                             children: <Widget>[
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: <Widget>[
                                     Row(
                                       children: <Widget>[
                                         Icon(
                                           Icons.star,
                                           color: Colors.greenAccent,
                                         ),
                                         Icon(
                                           Icons.star,
                                           color: Colors.greenAccent,
                                         ),
                                         Icon(
                                           Icons.star,
                                           color: Colors.greenAccent,
                                         ),
                                         Icon(
                                           Icons.star,
                                           color: Colors.greenAccent,
                                         ),
                                         Icon(
                                           Icons.star_border,
                                           color: Colors.greenAccent,
                                         ),
                                       ],
                                     ),
                                     Text.rich(TextSpan(children: [
                                       WidgetSpan(
                                           child: Icon(OMIcons.locationOn, size: 16.0, color: Colors.grey,)
                                       ),
                                       TextSpan(
                                         text: widget.post.location,
                                       )
                                     ]), style: TextStyle(color: Colors.grey, fontSize: 12.0, fontFamily: 'ProductSans',),)
                                   ],
                                 ),
                               ),
                               Column(
                                 children: <Widget>[
                                   Text("\₽ ${widget.post.price}", style: TextStyle(
                                       color: Colors.greenAccent,
                                       fontWeight: FontWeight.bold,
                                       fontFamily: 'ProductSans',
                                       fontSize: 20.0
                                   ),),
                                   Text("/per ${widget.post.time}",style: TextStyle(
                                       fontFamily: 'ProductSans',
                                       fontSize: 12.0,
                                       color: Colors.grey
                                   ),)
                                 ],
                               )
                             ],
                           ),
                           const SizedBox(height: 30.0),
                           _buttonSection,
                           /*SizedBox(
                               width: double.infinity,
                               child: RaisedButton(
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                                 color: Colors.orangeAccent,
                                 textColor: Colors.white,
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                     Icon(Icons.map),
                                     SizedBox(width: 2,),
                                     Text("Найти на карте", style: TextStyle(
                                       fontWeight: FontWeight.normal,
                                       fontFamily: 'ProductSans',
                                     ),),
                                   ],
                                 ),
                                 padding: const EdgeInsets.symmetric(
                                   vertical: 16.0,
                                   horizontal: 32.0,
                                 ),
                                 onPressed: () {MapsLauncher.launchQuery(widget.author.address + ' ' + widget.post.location,);},
                               ),
                             ),*/
                           const SizedBox(height: 30.0),
                           Text("DESCRIPTION".toUpperCase(), style: TextStyle(
                               fontWeight: FontWeight.w600,
                               fontFamily: 'ProductSans',
                               fontSize: 14.0
                           ),),
                           const SizedBox(height: 10.0),
                           Text(
                             widget.post.caption, textAlign: TextAlign.justify, style: TextStyle(
                               fontWeight: FontWeight.w300,
                               fontFamily: 'ProductSans',
                               fontSize: 14.0
                           ),),
                           const SizedBox(height: 10.0),
                           _mapSection,
                           const SizedBox(height: 10.0),
                           _authorSection,
                           Container(
                             //padding: const EdgeInsets.symmetric(horizontal: 8),
                             child: Wrap(
                               alignment: WrapAlignment.spaceAround,
                               children: [
                                 //Chip(label: Text('#'+widget.place.goals[0]),),
                                 //Chip(label: Text('#'+widget.place.goals[1]),),
                                 //Chip(label: Text('#'+widget.place.goals[2]),),
                               ],
                             ),
                           ),
                         ],
                       ),
                     ),
                   ],
                 ),
               ),
               ),
             ],
           );
         }
           }
         ),
       );
     }
}
