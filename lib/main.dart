import 'package:dnro/ad_state.dart';
import 'package:dnro/screens/email_screen.dart';
import 'package:dnro/screens/redefinir_senha.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import './screens/auth_screen.dart';
import './screens/sing_up_screen.dart';
import './screens/home_screen.dart';
import './screens/validar_screen.dart';
import './screens/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final initFuture = MobileAds.instance.initialize();
  final adState = AdState(initFuture);
  runApp(Provider.value(value: adState, builder: (context, child) => MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PixPay',
      theme: ThemeData(
        primaryColor: Colors.yellow[600],
      ),
      home: AuthScreen(),
      routes: {
        AuthScreen.route: (ctx) => AuthScreen(),
        SingUp.route: (ctx) => SingUp(),
        MyHomePage.route: (ctx) => MyHomePage(),
        ValidarScreen.route: (ctx) => ValidarScreen(),
        ProfileScreen.route: (ctx) => ProfileScreen(),
        EmailScreen.route: (ctx) => EmailScreen(),
        RedefinirSenha.route: (ctx) => RedefinirSenha()
      },
    );
  }
}
