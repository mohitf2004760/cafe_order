import 'package:cafeorder/screens/home/payment-success.dart';
import 'package:cafeorder/screens/home/payment.dart';
import 'package:cafeorder/services/auth.dart';
import 'package:flutter/material.dart';
import 'screens/wrapper.dart';
import 'package:cafeorder/models/user.dart';
import 'package:provider/provider.dart';
import 'package:cafeorder/screens/home/home.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return  StreamProvider<User>.value(
        value: AuthService().user,
        child : MaterialApp(
        home:Wrapper(),
          routes: <String, WidgetBuilder>{
            '/homepage': (BuildContext context) => Home(),
            '/payment-success' : (BuildContext context) => PaymentSuccess(),
          },
      ));
  }
}