class Item{
  String name;
  int price;
  int item_id;

  Item({this.name, this.price, this.item_id});

  Item.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        price = json['price'],
        item_id = json['item_id'];

  Map toJson() => {
    'name': name,
    'price': price,
    'item_id':item_id
  };

  /*

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);


  Item _$ItemFromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'] as String,
      price: json['price'] as int,
      item_id: json['item_id'] as int,
    );
  }

  Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
    'name': instance.name,
    'price': instance.price,
    'item_id': instance.item_id,
  };
  */


}