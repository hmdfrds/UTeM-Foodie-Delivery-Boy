import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodir_delivery/providers/auth_provider.dart';
import 'package:foodir_delivery/screens/home_screen.dart';
import 'package:foodir_delivery/screens/login_screen.dart';
import 'package:foodir_delivery/screens/register_screen.dart';
import 'package:foodir_delivery/screens/splash_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: EasyLoading.init(),
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => SplashScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        RegisterScreen.id: (context) => RegisterScreen(),
      },
    );
  }
}
