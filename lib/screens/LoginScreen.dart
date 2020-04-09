import 'package:flutter/material.dart';
import 'package:folka/screens/SignUpScreen.dart';
import 'package:folka/services/AuthService.dart';

class LoginScreen extends StatefulWidget {
  static final String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email, _password;

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Logging in the user w/ Firebase
      AuthService.login(_email, _password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'shelf',
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
                          labelText: 'Email',
                          hintStyle: TextStyle(fontFamily: 'ProductSans'),),
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
                        decoration: InputDecoration(
                          border: new OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            borderSide: new BorderSide(color: Colors.greenAccent),
                          ),
                          labelText: 'Password',
                          hintStyle: TextStyle(fontFamily: 'ProductSans'),),
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
                      child: OutlineButton(
                        borderSide: BorderSide(color: Colors.greenAccent),
                        highlightedBorderColor: Colors.green,
                        onPressed: _submit,
                        color: Colors.greenAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(28.0)),
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            //color: Colors.black,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      width: 250.0,
                      child: FlatButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, SignupScreen.id),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
