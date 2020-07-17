import 'package:flutter/material.dart';
import 'package:cafeorder/services/database.dart';
import 'package:cafeorder/models/item.dart';
import 'package:cafeorder/models/cartItem.dart';
import 'package:cafeorder/models/cart.dart';
import 'package:provider/provider.dart';
import 'package:cafeorder/models/user.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/services.dart';

class ItemGrid extends StatefulWidget {

  final Function showAmount;
  ItemGrid ({this.showAmount});

  @override
  _ItemGridState createState() => _ItemGridState();
}

class _ItemGridState extends State<ItemGrid> {

  final DatabaseService _db = DatabaseService();
  Cart _cart = Cart();
  List<CartItem> _cartItemList = List<CartItem>();
  int totalamount = 0;
  Razorpay _razorpay;


  //final Payment paymentInstance = Payment();


  void calculateAmount(List<CartItem> cartItemList){
    int subAmount = 0;
    int amount = 0;
    setState(() {
      if(cartItemList.length == 0)
      {
        totalamount = 0;
      }
      //loop through cart list to calculate amount
      for(int i=0; i<cartItemList.length;i++){
        subAmount = cartItemList[i].item.price * cartItemList[i].qty;
        amount = amount + subAmount;
      }
      totalamount = amount;
    });
  }

  void _onTileClicked(CartItem cartItem){


    int flag = 0;

    setState(() {
      // if the _cartItemList is empty, it is just the beginning, add item and return
      if(_cartItemList.length == 0)
      {
        _cartItemList.add(cartItem);
        calculateAmount(_cartItemList);
        widget.showAmount(totalamount); //update app bar to reflect amount
        return;
      }
      //loop through cart list to find item, if found increment the qty
      for(int i=0; i<_cartItemList.length;i++){
        if(_cartItemList[i].item.item_id == cartItem.item.item_id && flag ==0)
        {
          _cartItemList[i].qty += 1;
          calculateAmount(_cartItemList);
          widget.showAmount(totalamount); //update app bar to reflect amount
          flag = 1;
        }
      }
      // if even after iterating whole list, we do not find the item
      if(flag == 0) {
        _cartItemList.add(cartItem);
        calculateAmount(_cartItemList);
        widget.showAmount(totalamount); //update app bar to reflect amount
        return;
      }
    });

  }

  String returnCartItemCount(Item item)
  {
    int flag = 0;
    if(_cartItemList.length == 0)
    {
      return '';
    }
    //loop through cart list to find item, if found increment the qty
    for(int i=0; i<_cartItemList.length;i++){
      if(_cartItemList[i].item.item_id == item.item_id && flag ==0)
      {
        flag = 1;
        return _cartItemList[i].qty.toString();
      }
    }
    // if even after iterating whole list, we do not find the item
    if(flag == 0) {
      return '';
    }
  }


  void openCheckout(int amount) async {
    var options = {
      //'key': 'rzp_test_1DP5mmOlF5G5ag',
      //'key':'rzp_test_XUWIejIYrbx1c9', -- take this
      'key':'rzp_live_uMMmQPWStOo1Eu',
      'amount': 100,//amount*100,
      'name': 'Todays Special',
      'description': 'Food',
      //'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
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

  void saveOrderAfterPaymentSuccess () async {
    await _db.saveOrderDetails(Cart(uid:_cart.uid,cartItemList: _cartItemList),totalamount,"PENDING");
    print('--------Order Details Saved------');
    _cartItemList.removeRange(0, _cartItemList.length); //remove all items from the cartlist
    calculateAmount(_cartItemList);
    widget.showAmount(totalamount); //totalamount will become 0 here
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    //print('--------------payment success');
    Navigator.of(context).pushNamed('/payment-success');
    await saveOrderAfterPaymentSuccess();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('-----------------payment error');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('----------------payment external wallet');
  }


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


  @override
  Widget build(BuildContext context) {

    final User user = Provider.of<User>(context);
    setState(() {
      _cart.uid = user.uid;
    });
    //print(user.uid);


    return FutureBuilder<List<Item>>(
      future: _db.getItems(),
      builder: (context,snapshot){
        if (snapshot.hasError) print(snapshot.error);
        return snapshot.hasData ? Column(
          children: [
            Expanded(
              flex: 1,
              child: GridView.count(
                shrinkWrap: true,
                  primary: true,
                  crossAxisCount: 2,
                  //childAspectRatio: 1.0,
                  padding: const EdgeInsets.all(10.0),
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  children: snapshot.data.map((item) {
                    return GestureDetector(
                      onTap: () => _onTileClicked(CartItem(item:item,qty:1)),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.brown[400],
                        ),
                        child: GridTile(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${item.name}',
                                style:TextStyle(
                                    fontSize: 22.0,
                                    color: Colors.white,
                                  )
                                ),
                                Text('₹${item.price}',
                                    style:TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.white,
                                    )
                                )
                              ],
                            ),
                              Padding(
                                padding: const EdgeInsets.only(right:8.0, bottom: 8.0),
                                child:Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text('${returnCartItemCount(item)}',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                  ),)
                                )
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }
              ).toList()),
            ),
            SizedBox(height: 20.0,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.brown[400],
                  ),
                  child: RaisedButton(
                    child:Text('Reset',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),),
                    color:Colors.brown.shade400,
                    elevation: 5.0,
                    onPressed: (){
                     setState(() {
                       _cartItemList.removeRange(0, _cartItemList.length); //remove all items from the cartlist
                       calculateAmount(_cartItemList);
                       widget.showAmount(totalamount);
                     });
                    },
                  ),
                ),
                SizedBox(width: 10.0,),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.brown[400],
                  ),
                  child: RaisedButton.icon(
                    icon:Icon(Icons.arrow_forward, color: Colors.white,),
                    label:Text('Pay',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),),
                    color:Colors.brown.shade400,
                    elevation: 10.0,
                    onPressed: () async{
                      //print('Total Amount mock paid is${totalamount}');
                      //Navigator.of(context).pushNamed('/payment');
                      await openCheckout(totalamount);
                      //await _db.saveOrderDetails(Cart(uid:user.uid,cartItemList: _cartItemList));
                      //print('Order Details Saved');
                    },
                  ),
                ),

              ],
            )
          ],
        ) :
        Center(
          child:CircularProgressIndicator() ,);
      }
    );
  }
}
