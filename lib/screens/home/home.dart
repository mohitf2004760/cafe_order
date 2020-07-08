import 'package:cafeorder/screens/home/item_grid.dart';
import 'package:flutter/material.dart';
import 'package:cafeorder/services/auth.dart';
import 'package:cafeorder/models/cartItem.dart';

class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int totalamount = 0;

  int showAmount(int amount){
    setState(() {
      totalamount = amount;
    });
  }

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Cafe Order'),
          backgroundColor: Colors.brown[400],
          elevation: 0.0,
          actions: [
            Align(
                alignment: Alignment.center,
                child: Text('₹${totalamount}',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                ),)),
            FlatButton.icon(
              onPressed: () async {
                await _auth.signOut();
              },
              icon:Icon(Icons.person),
              label:Text('logout'),
            ),
            FlatButton.icon(
              icon:Icon(Icons.settings),
              label:Text('settings'),
              onPressed:() {},
            )]
      ),
      body:ItemGrid(showAmount : showAmount),
    );
  }
}
