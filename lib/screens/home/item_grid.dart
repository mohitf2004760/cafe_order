import 'package:flutter/material.dart';
import 'package:cafeorder/services/database.dart';
import 'package:cafeorder/models/item.dart';
import 'package:cafeorder/models/cartItem.dart';
import 'package:cafeorder/models/cart.dart';
import 'package:provider/provider.dart';
import 'package:cafeorder/models/user.dart';

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

  int returnCartItemCount(Item item)
  {
    int flag = 0;
    if(_cartItemList.length == 0)
    {
      return 0;
    }
    //loop through cart list to find item, if found increment the qty
    for(int i=0; i<_cartItemList.length;i++){
      if(_cartItemList[i].item.item_id == item.item_id && flag ==0)
      {
        flag = 1;
        return _cartItemList[i].qty;
      }
    }
    // if even after iterating whole list, we do not find the item
    if(flag == 0) {
      return 0;
    }
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
            SizedBox(height: 40.0,),
            GridView.count(
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
                        borderRadius: BorderRadius.circular(30),
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
            SizedBox(height: 40.0,),

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
                    onPressed: (){
                      print('Total Amount is${totalamount}');
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
