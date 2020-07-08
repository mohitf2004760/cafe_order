import 'package:flutter/material.dart';
import 'authenticate/authenticate.dart';
import 'package:cafeorder/screens/home/home.dart';
import 'package:provider/provider.dart';
import 'package:cafeorder/models/user.dart';


class Wrapper extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);

    if(user == null) {
      return Authenticate();
    } else{
      return Home();
    }
  }
}
