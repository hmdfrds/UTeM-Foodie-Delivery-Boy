import 'package:flutter/material.dart';
import 'package:foodir_delivery/providers/auth_provider.dart';
import 'package:foodir_delivery/screens/login_screen.dart';
import 'package:provider/provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const String id = 'reset-password-screen';
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  var _emailTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'images/password.png',
                  height: 250,
                ),
                SizedBox(
                  height: 20,
                ),
                RichText(
                  text: const TextSpan(
                    text: '',
                    children: [
                      TextSpan(
                          text: 'Forgot Password ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red)),
                      TextSpan(
                        text:
                            'Dont worry , provide us your registered email , we will send the password reset link',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
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
                          color: Theme.of(context).primaryColor, width: 2),
                    ),
                    focusColor: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                        child: ElevatedButton(
                      child: _loading
                          ? LinearProgressIndicator()
                          : Text('Reset Password'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _loading = true;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Check Your Email ${_emailTextController.text} for reset link ')));
                          Navigator.pushReplacementNamed(
                              context, LoginScreen.id);

                          setState(() {
                            _loading = false;
                          });
                        }
                      },
                    ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
