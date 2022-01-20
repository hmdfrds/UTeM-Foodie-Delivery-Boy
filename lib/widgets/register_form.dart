import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  var _emailTextController = TextEditingController();
  var _passwordTextController = TextEditingController();
  var _confirmPasswordTextController = TextEditingController();
  var _businessTextController = TextEditingController();
  var _mobileNumberTextController = TextEditingController();
  String? email;
  String? password;
  String mobile = "";
  String businessName = "";
  bool _isLoading = false;

  Future<String> uploadFile(filePath) async {
    File file = filePath;
    FirebaseStorage _storage = FirebaseStorage.instance;
    try {
      await _storage
          .ref('DeliveryBoyProfilePic/${_businessTextController.text}')
          .putFile(file);
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print(e.code);
    }
    String downloadURL = await _storage
        .ref('DeliveryBoyProfilePic/${_businessTextController.text}')
        .getDownloadURL();
    return downloadURL;
  }

  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);
    setState(() {
      _emailTextController.text = _authData.email;
      email = _authData.email;
    });
    ScaffoldMessage(message) {
      return ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }

    return _isLoading
        ? CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          )
        : Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    controller: _businessTextController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter  Name';
                      }
                      setState(() {
                        businessName = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      labelText: 'Name',
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 2),
                      ),
                      focusColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    controller: _mobileNumberTextController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Mobile Number';
                      }
                      setState(() {
                        mobile = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone_android),
                      labelText: 'Mobile Number',
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 2),
                      ),
                      focusColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    enabled: false,
                    controller: _emailTextController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Email';
                      }
                      final bool _isValid =
                          EmailValidator.validate(_emailTextController.text);

                      if (!_isValid) {
                        return 'Invalid Email Format';
                      }
                      setState(() {
                        email = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                      labelText: 'Email',
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 2),
                      ),
                      focusColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    controller: _passwordTextController,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Password';
                      }
                      setState(() {
                        password = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.vpn_key_outlined),
                      labelText: 'Password',
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 2),
                      ),
                      focusColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    controller: _confirmPasswordTextController,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Password Again';
                      }
                      if (_confirmPasswordTextController.text !=
                          _passwordTextController.text) {
                        return 'The Password Is Not Same';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.vpn_key_outlined),
                      labelText: 'Confirm Password',
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 2),
                      ),
                      focusColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_authData.isPicAvail) {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });
                              _authData
                                  .registerBoys(email, password)
                                  .then((credential) {
                                if (credential?.user!.uid != null) {
                                  uploadFile(_authData.image).then((url) {
                                    if (url != null) {
                                      _authData.saveBoysDataToDb(
                                          url: url,
                                          mobile:
                                              _mobileNumberTextController.text,
                                          name: _businessTextController.text,
                                          password: password,
                                          context: context);

                                      setState(() {
                                        _isLoading = false;
                                      });
                                    } else {
                                      ScaffoldMessage(
                                          'Failed to upload Shop Profile Pic');
                                    }
                                  });
                                } else {
                                  ScaffoldMessage(_authData.error);
                                }
                              });
                            }
                          } else {
                            ScaffoldMessage(
                                'Show profile pic need to be added');
                          }
                        },
                        child: Text(
                          'Register',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    FlatButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.pushNamed(context, LoginScreen.id);
                      },
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                                text: 'Already have an account ? ',
                                style: TextStyle(color: Colors.black)),
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
