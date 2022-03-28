import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_task_manager/screens/auth_screens/register_screen/register_screen.dart';
import 'package:new_task_manager/screens/home_screen/root_home_screen.dart';
import 'package:new_task_manager/services/auth_services/auth_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _hidePassword = true;
  bool _isLoading = false;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _emailKey = GlobalKey<FormFieldState>();
  final _passwordKey = GlobalKey<FormFieldState>();

  FocusNode _passwordNode = FocusNode();
  FocusNode _submitNode = FocusNode();

  AuthServices _authServices = AuthServices();


  Future<void> _login() async {
    if(_formKey.currentState?.validate() == true) {
      setState(() {
        _isLoading = true;
      });
      String email = _emailController.text.toString().trim();
      String password = _passwordController.text.toString().trim();

      String uid = await _authServices.login(email, password);

      if(uid != "None") {
       Fluttertoast.showToast(msg: "Logged in successfully");
       print("success");
       Timer(Duration(milliseconds: 350), () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => RootHomeScreen(uid: uid,)));
       });
      } else {
        print("error");
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  

  @override
  void dispose() {
    _passwordNode.dispose();
    _submitNode.dispose();
    super.dispose();
  }  

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0.0),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage("assets/gifs/auth_gif.gif")),
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 4),
                                  blurRadius: 4,
                                  color: Colors.black.withOpacity(0.25))
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(screenWidth / 3.312)),
                        width: screenWidth / 3.312,
                        height: screenWidth / 3.312,
                      ),
                      SizedBox(
                        height: screenWidth / 20.7,
                      ),
                      Text(
                        "User Login",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: screenWidth / 20.7,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: screenWidth / 5.83,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: screenWidth / 12.54),
                        child: TextFormField(
                          controller: _emailController,
                          key: _emailKey,
                          onFieldSubmitted: (_) 
                          {
                            if(_emailKey.currentState?.validate() == true) {
                              FocusScope.of(context).requestFocus(_passwordNode);
                            }
                          },
                          validator: (value) {
                             if (value.toString().trim().length > 0) {
                                  if (!RegExp(
                                          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                                      .hasMatch(value.toString().trim())) {
                                    return "Enter Valid Email";
                                  } else {
                                    return null;
                                  }
                                } else {
                                  return "Email is required";
                                }
                          },
                          decoration: InputDecoration(
                              labelText: "Enter Email", prefixIcon: Icon(Icons.mail)),
                        ),
                      ),
                      SizedBox(height: screenWidth / 18),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: screenWidth / 12.54),
                        child: TextFormField(
                          controller: _passwordController,
                          key: _passwordKey,
                          focusNode: _passwordNode,
                          onFieldSubmitted: (_){
                            if(_passwordKey.currentState?.validate() == true) {
                              FocusScope.of(context).requestFocus(_submitNode);
                            }
                          },
                          validator: (value) {
                             if (value.toString().trim().length > 0) {
                                  if (value.toString().trim().length >= 6) {
                                    return null;
                                  } else {
                                    return "Password length must be atleast 6";
                                  }
                                } else {
                                  return "Password is required";
                                }
                          },
                          obscureText: _hidePassword,
                          decoration: InputDecoration(
                              labelText: "Enter Password",
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _hidePassword = !_hidePassword;
                                    });
                                  },
                                  icon: _hidePassword
                                      ? Icon(Icons.visibility)
                                      : Icon(Icons.visibility_off)),
                              prefixIcon: Icon(Icons.lock)),
                        ),
                      ),
                      SizedBox(height: screenWidth / 9.63),
                      Container(
                        child: ElevatedButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            screenWidth / 10.35)))),
                            onPressed: ()async {
                              await _login();
                              // Navigator.of(context).pushReplacement(MaterialPageRoute(
                              //     builder: (context) => RootHomeScreen()));
                            },
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth / 20.7),
                            )),
                        width: screenWidth / 2.36,
                        height: screenWidth / 8.28,
                      ),
                      SizedBox(
                        height: screenWidth / 20.7,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                              builder: (context) => RegisterScreen()));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Dont have account? ",
                              style: TextStyle(fontSize: screenWidth / 31.84),
                            ),
                            Text(
                              " Register",
                              style: TextStyle(
                                  fontSize: screenWidth / 31.84,
                                  decoration: TextDecoration.underline),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            _isLoading ? Container(
             child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth / 20.7,
                  vertical: screenWidth / 20.7
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 4),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.25)
                    )
                  ]
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: screenWidth / 20.7,
                    ),
                    Text("Please wait till we login you...", textAlign: TextAlign.center,style: TextStyle(
                      fontSize: screenWidth  / 27.6,
                      fontWeight: FontWeight.bold
                    ),)
                  ],),
              ),
            ),
            //   color: Colors.white.withOpacity(0.25),
            //   height: MediaQuery.of(context).size.height,
            //   width: MediaQuery.of(context).size.width,
             ) : Container()
          ],
        ));
  }
}
