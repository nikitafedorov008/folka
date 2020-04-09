import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:folka/models/User.dart';
import 'package:folka/services/DatabaseService.dart';
import 'package:folka/services/StorageService.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  EditProfileScreen({this.user});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  File _profileImage;
  String _name = '';
  String _surname = '';
  String _phone = '';
  String _birthdate = '';
  String _bio = '';
  bool _isLoading = false;

  int age = -1;

  @override
  void initState() {
    super.initState();
    _name = widget.user.name;
    _surname = widget.user.surname;
    _phone = widget.user.phone;
    _birthdate = widget.user.birthdate;
    _bio = widget.user.bio;
  }

  _handleImageFromGallery() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() {
        _profileImage = imageFile;
      });
    }
  }

  _displayProfileImage() {
    // No new profile image
    if (_profileImage == null) {
      // No existing profile image
      if (widget.user.profileImageUrl.isEmpty) {
        // Display placeholder
        return AssetImage('assets/images/avatar.png');
      } else {
        // User profile image exists
        return CachedNetworkImageProvider(widget.user.profileImageUrl);
      }
    } else {
      // New profile image
      return FileImage(_profileImage);
    }
  }

  _submit() async {
    if (_formKey.currentState.validate() && !_isLoading) {
      _formKey.currentState.save();

      setState(() {
        _isLoading = true;
      });

      // Update user in database
      String _profileImageUrl = '';

      if (_profileImage == null) {
        _profileImageUrl = widget.user.profileImageUrl;
      } else {
        _profileImageUrl = await StorageService.uploadUserProfileImage(
          widget.user.profileImageUrl,
          _profileImage,
        );
      }

      User user = User(
        id: widget.user.id,
        name: _name,
        surname: _surname,
        phone: _phone,
        birthdate: _birthdate,
        profileImageUrl: _profileImageUrl,
        bio: _bio,
      );
      // Database update
      DatabaseService.updateUser(user);

      Navigator.pop(context);
    }
  }

  calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  selectDate(BuildContext context, DateTime initialDateTime,
      {DateTime lastDate}) async {
    Completer completer = Completer();
    String _selectedDateInString;
    if (Platform.isAndroid)
      showDatePicker(
          context: context,
          initialDate: initialDateTime,
          firstDate: DateTime(1970),
          lastDate: lastDate == null
              ? DateTime(initialDateTime.year + 10)
              : lastDate)
          .then((temp) {
        if (temp == null) return null;
        completer.complete(temp);
        setState(() {});
      });
    else
      DatePicker.showDatePicker(
        context,
        dateFormat: 'yyyy-mmm-dd',
        locale: 'en',
        onConfirm2: (temp, selectedIndex) {
          if (temp == null) return null;
          completer.complete(temp);

          setState(() {});
        },
      );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
      /*floatingActionButton: Stack(
        children: <Widget>[
          Padding(padding: EdgeInsets.only(left:31),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton(
                backgroundColor: Colors.greenAccent,
                onPressed: () {Navigator.pop(context);},
                child: Icon(Icons.arrow_back, color: Colors.black,),),
            ),),

          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              backgroundColor: Colors.greenAccent,
              onPressed: _submit,
              child: Icon(Icons.check, color: Colors.black,),),
          ),
        ],
      ),*/
      appBar: AppBar(
        //backgroundColor: Colors.white,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            //color: Colors.black,
            fontFamily: 'ProductSans',
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          children: <Widget>[
            _isLoading
                ? LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(Colors.greenAccent),
            )
                : SizedBox.shrink(),
            Padding(
              padding: EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 60.0,
                      backgroundColor: Colors.grey,
                      backgroundImage: _displayProfileImage(),
                    ),
                    FlatButton(
                      onPressed: _handleImageFromGallery,
                      child: Text(
                        'Change Profile Image',
                        style: TextStyle(
                          //color: Theme.of(context).accentColor,
                            color: Colors.green,
                            fontFamily: 'ProductSans',
                            fontSize: 16.0),
                      ),
                    ),
                    TextFormField(
                      initialValue: _name,
                      style: TextStyle(fontSize: 18.0),
                      decoration: InputDecoration(
                        border: new OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide: new BorderSide(color: Colors.greenAccent),
                        ),
                        icon: Icon(
                          Icons.person_outline,
                          size: 30.0,
                        ),
                        labelText: 'Name',
                      ),
                      validator: (input) => input.trim().length < 1
                          ? 'Please enter a valid name'
                          : null,
                      onSaved: (input) => _name = input,
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      initialValue: _surname,
                      style: TextStyle(fontSize: 18.0),
                      decoration: InputDecoration(
                        border: new OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide: new BorderSide(color: Colors.greenAccent),
                        ),
                        icon: Icon(
                          Icons.person_outline,
                          size: 30.0,
                        ),
                        labelText: 'Surname',
                      ),
                      validator: (input) => input.trim().length < 1
                          ? 'Please enter a valid surname'
                          : null,
                      onSaved: (input) => _name = input,
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      initialValue: _phone,
                      style: TextStyle(fontSize: 18.0),
                      decoration: InputDecoration(
                        border: new OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide: new BorderSide(color: Colors.greenAccent),
                        ),
                        icon: Icon(
                          Icons.phone,
                          size: 30.0,
                        ),
                        labelText: 'Phone',
                      ),
                      validator: (input) => input.trim().length < 5
                          ? 'Please enter a valid phone'
                          : null,
                      onSaved: (input) => _name = input,
                    ),
                    /*SizedBox(height: 20.0),
                    GestureDetector(
                      //onTap: ()=> selectDate(context, DateTime.now(),),
                      onTap: () async {
                        DateTime birthDate = await selectDate(context, DateTime.now(),
                            lastDate: DateTime.now());
                        final df = new DateFormat('dd-MMM-yyyy');
                        this._birthdate = df.format(birthDate);
                        this.age = calculateAge(birthDate);
                        setState(() {});
                      },
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Icon(Icons.child_friendly, color: Colors.grey,),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(18.0)),
                              border: Border.all(color: Colors.grey),
                            ),
                            padding: EdgeInsets.fromLTRB(10,20,20,20,),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Birthdate ",
                                  style: TextStyle(fontFamily: 'ProductSans', color: Colors.grey[600]),),
                                Text("$_birthdate",
                                  style: TextStyle(fontFamily: 'ProductSans'),)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),*/
                    SizedBox(height: 20.0),
                    TextFormField(
                      initialValue: _bio,
                      style: TextStyle(fontSize: 18.0),
                      decoration: InputDecoration(
                        border: new OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide: new BorderSide(color: Colors.greenAccent),
                        ),
                        icon: Icon(
                          Icons.book,
                          size: 30.0,
                        ),
                        labelText: 'Bio',
                      ),
                      validator: (input) => input.trim().length > 150
                          ? 'Please enter a bio less than 150 characters'
                          : null,
                      onSaved: (input) => _bio = input,
                    ),
                    Container(
                      margin: EdgeInsets.all(40.0),
                      height: 40.0,
                      width: 250.0,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                        ),
                        onPressed: _submit,
                        color: Colors.greenAccent,
                        textColor: Colors.black,
                        child: Text(
                          'Save Profile',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
