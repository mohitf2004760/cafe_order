import 'package:cafeorder/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cafeorder/models/item.dart';

class DatabaseService {

  final String uid;

  DatabaseService ({this.uid});
  //collection reference
  final CollectionReference usersProfileCollection = Firestore.instance.collection('usersProfile');
  final CollectionReference itemsCollection = Firestore.instance.collection('items');
  //update database


  Future updateUserData (String name, String phone) async{
    return await usersProfileCollection.document(uid).setData({
      'name':name,
      'phone':phone,
    });
  }

  Future<bool> phoneNumberCheck(String phone) async {
    final result = await usersProfileCollection
        .where('phone', isEqualTo: phone)
        .getDocuments();
    return result.documents.isEmpty;
  }


  Future<List<Item>> getItems() async {
      List<Item> itemsList = [];
      QuerySnapshot querySnapshot = await itemsCollection.getDocuments();
      for (int i = 0; i < querySnapshot.documents.length; i++) {
        var a = querySnapshot.documents[i];
        //print(a.data['name']);
        itemsList.add(Item(name:a.data['name'],price:a.data['price'],item_id: a.data['item_id']));
      }
      return await itemsList;
  }
}