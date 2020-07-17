import 'package:flutter/material.dart';

class PaymentSuccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Success Page'),
      ),
      body: Center(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green,size: 20.0,),
                SizedBox(width: 4.0,),
                Text('Payment Successful',
                style: TextStyle(
                  fontSize: 20.0,
                ),)
              ],
            ),
            IconButton(
              icon: Icon(Icons.home
            ),
            onPressed: (){Navigator.of(context).pop();},)
          ],
        )
      )
    );
  }
}
