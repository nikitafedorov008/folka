import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:folka/services/AuthService.dart';
import 'package:intl/intl.dart';

class SignupScreen extends StatefulWidget {
  static final String id = 'signup_screen';

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name, _surname, _birthdate, _email, _phone, _password;

  String birthDate = "";
  int age = -1;
  String _region = "";

  _submit() {
    _birthdate = birthDate;
    if (age <= 18) {
      return SnackBar (
        content: Text('Sorry you are not an adult',
          style: TextStyle(fontFamily: 'ProductSans'),),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {},
        ),
      );}
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Logging in the user w/ Firebase
      AuthService.signUpUser(context, _name, _surname, _birthdate, _email, _phone, _password);
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

  _androidBottomSheet () {
    showBottomSheet(
        context: null,
        builder: (BuildContext context) {
        }
    );
  }

  List<String> items = [
    'Saint-Peterburg',
    'Leningradskaya oblast',
    'Moscow',
    'Moscowskaya oblast',
    'Novosibirsk',
    'Novosibirskaya oblast',
    'Ryazan',
    'Ryazanskaya oblast',
    'Tula',
    'Tulskaya oblast',
  ];
  int selected_item = 0;

  _iosItemPicker() async {
   final selectedItem = await showCupertinoModalPopup<String>(
        context: context,
        builder: (BuildContext context){
          return Container(
            height: MediaQuery.of(context).size.width,
            child: CupertinoPicker(
              itemExtent: 50.0,
              onSelectedItemChanged: (index){
                setState(() {
                  selected_item = index;
                  _region = '${items[index]}';
                  print("You selected ${items[selected_item]}");
                });
              },
              children: List<Widget>.generate(items.length, (index){
                return Center(
                  child: GestureDetector(
                    onTap:() {
                      _region = '${items[index]}';
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: Text(items[index]),
                  ),
                );
              }),
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              //SizedBox(height: 24,),
              Text(
                'Sign Up',
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 50.0,
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 10.0,
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                            border: new OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              borderSide: new BorderSide(color: Colors.greenAccent),
                            ),
                            labelText: 'Name'),
                        validator: (input) => input.trim().isEmpty
                            ? 'Please enter a valid name'
                            : null,
                        onSaved: (input) => _name = input,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 10.0,
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                            border: new OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              borderSide: new BorderSide(color: Colors.greenAccent),
                            ),
                            labelText: 'Surname'),
                        validator: (input) => input.trim().isEmpty
                            ? 'Please enter a valid surname'
                            : null,
                        onSaved: (input) => _surname = input,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 10.0,
                      ),
                      child: GestureDetector(
                        //onTap: ()=> selectDate(context, DateTime.now(),),
                        onTap: () async {
                          DateTime birthDate = await selectDate(context, DateTime.now(),
                              lastDate: DateTime.now());
                          final df = new DateFormat('dd-MMM-yyyy');
                          this.birthDate = df.format(birthDate);
                          this.age = calculateAge(birthDate);
                          setState(() {});
                        },
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
                              Text("Birthdate ",
                                style: TextStyle(fontSize: 16, fontFamily: 'ProductSans', color: Colors.grey[600]),),
                              Text("$birthDate",
                                style: TextStyle(fontFamily: 'ProductSans'),)
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 5.0,
                      ),
                      child: GestureDetector(
                        //onTap: () async {_showSelectRegionDialog();},
                        onTap: _iosItemPicker,
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
                              Text("Region ",
                                style: TextStyle(fontSize: 16, fontFamily: 'ProductSans', color: Colors.grey[600]),),
                              Text("$_region",
                                style: TextStyle(fontFamily: 'ProductSans'),),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 10.0,
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                            border: new OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              borderSide: new BorderSide(color: Colors.greenAccent),
                            ),
                            labelText: 'Email'),
                        validator: (input) => !input.contains('@')
                            ? 'Please enter a valid email'
                            : null,
                        onSaved: (input) => _email = input,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 10.0,
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            border: new OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              borderSide: new BorderSide(color: Colors.greenAccent),
                            ),
                            labelText: 'Phone'),
                        validator: (input) => input.length < 6
                            ? 'Please enter a valid phone number'
                            : null,
                        onSaved: (input) => _phone = input,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 10.0,
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                            border: new OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              borderSide: new BorderSide(color: Colors.greenAccent),
                            ),
                            labelText: 'Password'),
                        validator: (input) => input.length < 6
                            ? 'Must be at least 6 characters'
                            : null,
                        onSaved: (input) => _password = input,
                        obscureText: true,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      width: 250.0,
                      child: FlatButton(
                        onPressed: _submit,
                        color: Colors.greenAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(28.0)),
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            color: Colors.black,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      width: 250.0,
                      child: OutlineButton(
                        borderSide: BorderSide(color: Colors.greenAccent),
                        highlightedBorderColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(28.0)),
                        onPressed: () => Navigator.pop(context),
                        color: Colors.greenAccent,
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'Back to Login',
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            color: Colors.black,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                          'by clicking sign up you agree to the '
                      ),
                      Text(
                          'terms of use',
                        style: TextStyle(
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
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
