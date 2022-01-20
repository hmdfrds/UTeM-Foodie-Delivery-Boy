import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodir_delivery/providers/auth_provider.dart';
import 'package:foodir_delivery/screens/home_screen.dart';
import 'package:foodir_delivery/screens/register_screen.dart';
import 'package:foodir_delivery/services/firebase_services.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login-screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseServices _firebaseServices = FirebaseServices();
  var _emailTextController = TextEditingController();
  var _passwordTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obsecure = true;
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    final _authProvider = Provider.of<AuthProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Center(
              child: Container(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              'images/icon re.svg',
                              height: 150,
                            ),
                            FittedBox(
                              child: Text(
                                'DELIVERY APP - LOGIN',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: _emailTextController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter Email";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(),
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2),
                          ),
                          focusColor: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: _passwordTextController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter Password";
                          }
                        },
                        obscureText: _obsecure,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: _obsecure
                                ? Icon(Icons.visibility)
                                : Icon(Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _obsecure = !_obsecure;
                              });
                            },
                          ),
                          enabledBorder: OutlineInputBorder(),
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Password',
                          prefixIcon: Icon(Icons.vpn_key_outlined),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2),
                          ),
                          focusColor: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(primary: Colors.orange),
                              child: _loading
                                  ? LinearProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                      backgroundColor: Colors.transparent,
                                    )
                                  : Text('login'),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  EasyLoading.show(status: 'Please wait...');
                                  _firebaseServices
                                      .validateUser(_emailTextController.text)
                                      .then((value) {
                                    if (value.exists) {
                                      if (value['password'] ==
                                          _passwordTextController.text) {
                                        _authProvider
                                            .loginBoys(
                                                _emailTextController.text,
                                                _passwordTextController.text)
                                            .then((credential) {
                                          if (credential != null) {
                                            EasyLoading.showSuccess(
                                                    'Logged In Successfully')
                                                .then((value) {
                                              Navigator.pushReplacementNamed(
                                                  context, HomeScreen.id);
                                            });
                                          } else {
                                            EasyLoading.showInfo(
                                                    'Need to complete Registration')
                                                .then((value) {
                                              _authProvider.setEmail(
                                                  _emailTextController.text);
                                              Navigator.pushReplacementNamed(
                                                  context, RegisterScreen.id);
                                            });
                                            // ScaffoldMessenger.of(context)
                                            //     .showSnackBar(SnackBar(
                                            //         content: Text(
                                            //             _authProvider.error)));
                                          }
                                        });
                                      } else {
                                        EasyLoading.showError(
                                            'Invalid Password');
                                      }
                                    } else {
                                      EasyLoading.showError(
                                          '${_emailTextController.text} does not registered as our Delivery Boy');
                                    }
                                  });
                                }
                                setState(() {
                                  _loading = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
