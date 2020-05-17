import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:folka/models/Post.dart';
import 'package:folka/models/User.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:super_qr_reader/super_qr_reader.dart';

class QrScreen extends StatefulWidget {

  final String currentUserId;
  final String userId;
  final bool authorScanBool;

  final Post post;
  final User author;
  Future<void> _launched;

  QrScreen({this.post, this.author, this.currentUserId, this.userId, this.authorScanBool});
  @override
  State<StatefulWidget> createState() {
    return _QrScreenState();
  }

}

class _QrScreenState extends State<QrScreen> {

  String result = '';

  var scanResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text('Qr Screen',
          style: TextStyle( fontFamily: 'ProductSans'),),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              Text('Scan it to get document'),
              Container(
                width: 332,
                height: 332,
                child: QrImage(
                  backgroundColor: Colors.white,
                  data: widget.post.authorId + widget.post.name,
                ),
              ),
              Container(
                width: 250.0,
                child: FlatButton(
                  onPressed: () async {
                    String results = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScanView(),
                        ));
                    if (results != null) {
                      setState(() {
                        result = results;
                      });
                    }
                  },
                  color: Colors.greenAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(28.0)),
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Next',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      //color: Colors.black,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}