import 'package:cafeorder/models/item.dart';


class CartItem{
  Item item;
  int qty;
  CartItem({this.item,this.qty});

  CartItem.fromJson(Map<String, dynamic> json)
      : item = json['item'],
        qty = json['qty'];

  Map toJson() => {
    'item': item,
    'qty': qty,
  };
}

