import 'package:flutter/material.dart';
import 'package:folka/screens/LoginScreen.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.push(context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(),
      ),
    );
  }

  Widget _buildImage(String assetName) {
    return Align(
      child: Image.asset('assets/images/$assetName.png', width: 350.0),
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0, fontFamily: 'ProductSans');
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700, fontFamily: 'ProductSans'),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.transparent,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "Welcome here",
          body:
          "Thanks for downloading our app. We are sure you will like!",
          image: _buildImage('happyface'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Rent",
          body:
          "Shelf is the best place to rent very necessary at this moment and lease something unnecessary.",
          image: _buildImage('moneyjar'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Safety",
          body:
          "Rentals made through the app will be safe and fraudulent.",
          image: _buildImage('authentication'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Convenience",
          body:
          "Application is designed to quickly and conveniently find what you need, saving your time.",
          image: _buildImage('orderconfirmed'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "What are you waiting for?!",
          bodyWidget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Click on ", style: bodyStyle),
                  Icon(OMIcons.search),
                ],
              ),
              Text("find needfull!", style: bodyStyle),
            ],
          ),
          image: _buildImage('qualitycheck'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text('Skip', style: TextStyle(fontFamily: 'ProductSans'),),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'ProductSans')),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeColor: Colors.tealAccent,
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}