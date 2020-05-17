import 'package:flutter/material.dart';

class TermsScreen extends StatefulWidget {

  @override
  _TermsScreenState createState() => _TermsScreenState();

}

class _TermsScreenState extends State<TermsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms', style: TextStyle(
          fontFamily: 'ProductSans',
        ),),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}