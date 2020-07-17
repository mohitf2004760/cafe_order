import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/services.dart';

class Payment extends StatefulWidget {

  static const platform = const MethodChannel("razorpay_flutter");

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  Razorpay _razorpay;

  @override
  void initState() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout() async {
    var options = {
      //'key': 'rzp_test_1DP5mmOlF5G5ag',
      'key':'rzp_test_XUWIejIYrbx1c9',
      'amount': 100,
      'name': 'Todays Special',
      'description': 'Food',
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('--------------payment success');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('-----------------payment error');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('----------------payment external wallet');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(onPressed: openCheckout, child: Text('Pay')),
              ])),
    );
  }
}

