import 'package:firebase_auth/firebase_auth.dart';
import 'package:cafeorder/models/user.dart';
import 'package:cafeorder/services/database.dart';

class AuthService{

  User _userFromFirebaseUser (FirebaseUser user){
    return user != null ? User(uid:user.uid ) : null;
  }

  //auth change user stream
  Stream<User> get user{
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  //sign in annonymouns
  Future signInAnon () async
  {
    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    }catch(e){
      print(e.toString());
      return null;
    }

  }

  // sign in with email and password
  Future signInWithEmailAndPassword (String email, String password) async {
    try{
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  //register with email and password
  Future registerWithEmailAndPassword (String email, String password, String name, String phone) async {
    try{
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      await DatabaseService(uid:user.uid).updateUserData(name, phone);
      return _userFromFirebaseUser(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  //signout
  Future signOut () async{
    try{
      return await _auth.signOut();
    }catch(e){
      print(e.toString());
      return null;
    }
  }

}