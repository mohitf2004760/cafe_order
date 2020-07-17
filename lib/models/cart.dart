import 'package:cafeorder/models/cartItem.dart';

class Cart{
  String uid;
  List<CartItem> cartItemList;
  Cart({this.uid,this.cartItemList});

  Cart.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        cartItemList = json['cartItemList'];

  Map toJson() => {
    'uid': uid,
    'cartItemList': cartItemList,
  };

}