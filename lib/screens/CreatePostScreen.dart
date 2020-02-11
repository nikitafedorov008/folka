import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:folka/models/Post.dart';
import 'package:folka/models/UserData.dart';
import 'package:folka/services/DatabaseService.dart';
import 'package:folka/services/StorageService.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  File _image;
  TextEditingController _captionController = TextEditingController();
  String _caption = '';
  String _name = '';
  String _price = '';
  String _time = '';
  String _category = '';
  bool _isLoading = false;

  _showSelectImageDialog() {
    return Platform.isIOS ? _iosBottomSheet() : _androidBottomSheet();
  }

  _showSelectChooseDialog() {
    return Platform.isIOS ? _iosChooseBottomSheet() : _androidChooseDialog();
  }

  _iosBottomSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text('Add Photo'),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text('Take Photo'),
              onPressed: () => _handleImage(ImageSource.camera),
            ),
            CupertinoActionSheetAction(
              child: Text('Choose From Gallery'),
              onPressed: () => _handleImage(ImageSource.gallery),
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

  _iosChooseBottomSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text('Choose category'),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text('Videogame Asset'),
                onPressed: () {
                  _category = 'Gadgets';
                  setState(() {});
                  Navigator.pop(context);
                }
            ),
            CupertinoActionSheetAction(
              child: Text('Gadgets'),
                onPressed: () {
                  _category = 'Gadgets';
                  setState(() {});
                  Navigator.pop(context);
                }
            ),
            CupertinoActionSheetAction(
                child: Text('Electonics'),
                onPressed: () {
                  _category = 'Electonics';
                  setState(() {});
                  Navigator.pop(context);
                }
            ),
            CupertinoActionSheetAction(
                child: Text('Childrens things'),
                onPressed: () {
                  _category = 'Childrens things';
                  setState(() {});
                  Navigator.pop(context);
                }
            ),

          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text('Cancel'),
              onPressed: ()=> Navigator.pop(context),
          ),
        );
      },
    );
  }

  _androidBottomSheet() {
    showBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Card(
            color: Colors.transparent,
            child: Container(
              color: Colors.greenAccent,
              child: new Wrap(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new Text('Add photo', style: TextStyle(fontFamily: 'ProductSans'),),
                  ),
                  new ListTile(
                      leading: new Icon(Icons.camera),
                      title: new Text('Take Photo', style: TextStyle(fontFamily: 'ProductSans'),),
                      onTap: () => {
                        _handleImage(ImageSource.camera),
                      }
                  ),
                  new ListTile(
                    leading: new Icon(Icons.photo),
                    title: new Text('Choose from Gallery', style: TextStyle(fontFamily: 'ProductSans'),),
                    onTap: () => {
                      _handleImage(ImageSource.gallery),
                    },
                  ),
                  new ListTile(
                    leading: new Icon(Icons.cancel),
                    title: new Text('Cancel', style: TextStyle(fontFamily: 'ProductSans'),),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  _androidDialog() {
    showDialog(context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            //backgroundColor: Colors.greenAccent,
            title: Text('Add Photo', style: TextStyle(fontFamily: 'ProductSans'),),
            children: <Widget>[
              SimpleDialogOption(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.camera),
                    SizedBox(width: 5.0,),
                    Text('Take Photo', style: TextStyle(fontFamily: 'ProductSans'),),
                  ],
                ),
                onPressed: ()=> _handleImage(ImageSource.camera),
              ),
              SimpleDialogOption(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.photo),
                    SizedBox(width: 5.0,),
                    Text('Choose from Gallery', style: TextStyle(fontFamily: 'ProductSans'),),
                  ],
                ),
                onPressed: ()=> _handleImage(ImageSource.gallery),
              ),
              SimpleDialogOption(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.cancel, color: Colors.red,),
                    SizedBox(width: 5.0,),
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
  _androidChooseDialog() {
    showDialog(context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            //backgroundColor: Colors.greenAccent,
            title: Text('Choose category', style: TextStyle(fontFamily: 'ProductSans'),),
            children: <Widget>[
              SimpleDialogOption(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.videogame_asset),
                    SizedBox(width: 5.0,),
                    Text('Videogame Asset', style: TextStyle(fontFamily: 'ProductSans'),),
                  ],
                ),
                  onPressed: () {
                    _category = 'Videogame Asset';
                    setState(() {});
                    Navigator.pop(context);
                  }
              ),
              SimpleDialogOption(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.devices_other),
                    SizedBox(width: 5.0,),
                    Text('Gadgets', style: TextStyle(fontFamily: 'ProductSans'),),
                  ],
                ),
                  onPressed: () {
                    _category = 'Gadgets';
                    setState(() {});
                    Navigator.pop(context);
                  }
              ),
              SimpleDialogOption(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.radio),
                    SizedBox(width: 5.0,),
                    Text('Electronics', style: TextStyle(fontFamily: 'ProductSans'),),
                  ],
                ),
                  onPressed: () {
                    _category = 'Electronics';
                    setState(() {});
                    Navigator.pop(context);
                  }
              ),
              SimpleDialogOption(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.child_friendly),
                    SizedBox(width: 5.0,),
                    Text('Childrens things', style: TextStyle(fontFamily: 'ProductSans'),),
                  ],
                ),
                onPressed: () {
                  _category = 'Childrens things';
                  setState(() {});
                  Navigator.pop(context);
                }
              ),
              SimpleDialogOption(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.cancel, color: Colors.red,),
                    SizedBox(width: 5.0,),
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

  _handleImage(ImageSource source) async {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(source: source);
    if (imageFile != null) {
      imageFile = await _cropImage(imageFile);
      setState(() {
        _image = imageFile;
      });
    }
  }

  _cropImage(File imageFile) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
    );
    return croppedImage;
  }

  _submit() async {
    if (!_isLoading && _image != null && _caption.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      // Create post
      String imageUrl = await StorageService.uploadPost(_image);
      Post post = Post(
        imageUrl: imageUrl,
        caption: _caption,
        name: _name,
        price: _price,
        time: _time,
        category: _category,
        likeCount: 0,
        authorId: Provider.of<UserData>(context).currentUserId,
        timestamp: Timestamp.fromDate(DateTime.now()),
      );
      DatabaseService.createPost(post);

      // Reset data
      _captionController.clear();

      setState(() {
        _caption = '';
        _image = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            height: height,
            child: Column(
              children: <Widget>[
                _isLoading
                    ? Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.greenAccent,
                    valueColor: AlwaysStoppedAnimation(Colors.green),
                  ),
                )
                    : SizedBox.shrink(),
                GestureDetector(
                  onTap: _showSelectImageDialog,
                  child: Container(
                    height: width,
                    width: width,
                    color: Colors.white,
                    child: _image == null
                        ? Image(image: AssetImage('assets/images/images.png'),)
                        : Image(
                      image: FileImage(_image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: TextFormField(
                    controller: _captionController,
                    style: TextStyle(fontSize: 18.0, fontFamily: 'productSans'),
                    decoration: InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        borderSide: new BorderSide(color: Colors.greenAccent),
                      ),
                      labelText: 'Name',
                    ),
                    onChanged: (input) => _name = input,
                  ),
                ),
                SizedBox(height: 10.0,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: TextFormField(
                    controller: _captionController,
                    style: TextStyle(fontSize: 18.0, fontFamily: 'productSans'),
                    decoration: InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        borderSide: new BorderSide(color: Colors.greenAccent),
                      ),
                      labelText: 'Price',
                    ),
                    onChanged: (input) => _price = input,
                  ),
                ),
                SizedBox(height: 10.0,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: TextFormField(
                    controller: _captionController,
                    style: TextStyle(fontSize: 18.0, fontFamily: 'productSans'),
                    decoration: InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        borderSide: new BorderSide(color: Colors.greenAccent),
                      ),
                      labelText: 'Time',
                    ),
                    onChanged: (input) => _time = input,
                  ),
                ),
                SizedBox(height: 10.0,),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 5.0,
                  ),
                  child: GestureDetector(
                    //onTap: ()=> selectDate(context, DateTime.now(),),
                    onTap: () async {_showSelectChooseDialog();},
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(18.0)),
                        border: Border.all(color: Colors.grey),
                      ),
                      padding: EdgeInsets.fromLTRB(10,20,20,20,),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Category ",
                            style: TextStyle(fontSize: 16, fontFamily: 'ProductSans', color: Colors.grey[600]),),
                          Text("$_category",
                            style: TextStyle(fontFamily: 'ProductSans'),)
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: TextFormField(
                    controller: _captionController,
                    style: TextStyle(fontSize: 18.0, fontFamily: 'productSans'),
                    decoration: InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        borderSide: new BorderSide(color: Colors.greenAccent),
                      ),
                      labelText: 'Caption',
                    ),
                    onChanged: (input) => _caption = input,
                  ),
                ),
                SizedBox(height: 10.0,),
                FlatButton (
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(18.0),
                  ),
                  child: Text('add product',
                    style: TextStyle(fontFamily: 'ProductSans'),),
                  color: Colors.greenAccent,
                  textColor: Colors.black,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
