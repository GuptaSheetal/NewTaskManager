import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:new_task_manager/screens/auth_screens/login_screen/login_screen.dart';
import 'package:new_task_manager/screens/home_screen/root_home_screen.dart';
import 'package:new_task_manager/services/auth_services/auth_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  AuthServices _authServices = AuthServices();

  Future<void> _decideNextScreen() async {
    String uid = await _authServices.checkUserIsLogged();
    Future.delayed(Duration(seconds: 3), () {
      if(uid != "None") {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => RootHomeScreen(uid: uid,)));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
    }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _decideNextScreen();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(child: Container()),
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: (screenWidth / 2.76) / 2,
                  backgroundImage: AssetImage("assets/images/app_logo.png"),
                ),
                SizedBox(
                  height: screenWidth / 20.7,
                ),
                Text(
                  "Task Manager",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: screenWidth / 20.7,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Container(),
                  flex: 3,
                ),
              ],
            ),
          ),
        ),
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("assets/images/splash_background.jpeg"))),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
      ),
    );
  }
}
