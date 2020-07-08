import 'package:cafeorder/services/database.dart';
import 'package:flutter/material.dart';
import 'package:cafeorder/shared/constants.dart';
import 'package:cafeorder/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cafeorder/main.dart';


class Register extends StatefulWidget {

  final Function toggleView;
  Register({this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth = AuthService();
  final DatabaseService _db = DatabaseService();


  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  //text field state
  String name = '';
  String phone = '';
  String email = '';
  String password = '';
  String error = '';



  String smsCode;
  String verificationCode;

  Future<void> _submit() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout = (String verId) {
      this.verificationCode = verId;
    };

    final PhoneCodeSent phoneCodeSent = (String verId, [int forceCodeResend]) {
      print('verification-id-${verId}');
      this.verificationCode = verId;
      smsCodeDialog(context).then((value) => print("Signed In"));
    };

    final PhoneVerificationCompleted phoneVerificationCompleted = (
        AuthCredential creds) {
      print("Success");
    };

    final PhoneVerificationFailed phoneVerificationFailed = (
        AuthException exception) {
      print("${exception.message}");
    };

    if(_formKey.currentState.validate()) {
          await FirebaseAuth.instance.verifyPhoneNumber(
              phoneNumber: '+91${this.phone}',
              timeout: const Duration(seconds: 30),
              verificationCompleted: phoneVerificationCompleted,
              verificationFailed: phoneVerificationFailed,
              codeSent: phoneCodeSent,
              codeAutoRetrievalTimeout: autoRetrievalTimeout
          );
    }
  }

  Future<bool> smsCodeDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Enter Code"),
            content: TextField(
              onChanged: (value) {
                this.smsCode = value;
              },
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              FlatButton(
                child: Text("Verify"),
                onPressed: () async{
                  FirebaseAuth.instance.currentUser().then((user) async{
                    if(user != null) {
                      print("user is not null while registering"); //should never happen
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed('/homepage');
                    } else {
                      Navigator.of(context).pop();
                      await _register();
                    }
                  });
                },
              )
            ],
          );
        }
    );
  }

  Future<void> _register() async {

    dynamic phoneNumberDoesNotExist = await _db.phoneNumberCheck(phone);
    if(phoneNumberDoesNotExist == true) {
      dynamic result = await _auth.registerWithEmailAndPassword(
          email, password, name, phone);
      if (result == null) {
        setState(() {
          error =
          'Please supply valid parameters. Email could be already registered';
        });
      }
      else {
        //we dont need this because as soon as we sign in, the wrapper.dart redirects us to Home.
        //Navigator.pushReplacementNamed(context,'/homepage');
      }
    }
    else{
      setState(() {
        error =
        'Please supply valid parameters. Phone could be already registered';
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return /*loading ? Loading() :*/ Scaffold(
        backgroundColor: Colors.brown[100],
        appBar: AppBar(
          backgroundColor: Colors.brown[400],
          elevation: 0.0,
          title:Text('Register - Cafe Order'),
          actions: [
            FlatButton.icon(
              icon:Icon(Icons.person),
              label:Text('Sign In'),
              onPressed: (){
                widget.toggleView();
              },
            )
          ],
        ),
        body: Container(
            padding : EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: SingleChildScrollView(
              child: Form(
                key:_formKey,
                child: Column(
                  children: [
                    SizedBox(height: 20.0,),
                    TextFormField(
                      decoration: textInputDecoration.copyWith(hintText: 'Name'),
                      validator: (val) => val.isEmpty? 'Enter name' : null,
                      onChanged: (val){
                        setState(() => name = val);
                      },
                    ),
                    SizedBox(height: 20.0,),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: phoneInputDecoration.copyWith(hintText: 'Phone'),
                      validator: (val) => val.isEmpty? 'Enter phone' : null,
                      onChanged: (val){
                        setState(() => phone = val);
                      },
                    ),
                    SizedBox(height: 20.0,),
                    TextFormField(
                      decoration: textInputDecoration.copyWith(hintText: 'Email'),
                      validator: (val) => val.isEmpty? 'Enter an email' : null,
                      onChanged: (val){
                        setState(() => email = val);
                      },
                    ),
                    SizedBox(height: 20.0,),
                    TextFormField(
                      decoration: textInputDecoration.copyWith(hintText: 'Password'),
                      obscureText: true,
                      validator: (val) => val.length < 6 ? 'Enter a password 6+ chars long' : null,
                      onChanged: (val){
                        setState(() => password = val);
                      },
                    ),
                    SizedBox(height: 20.0,),
                    RaisedButton(
                      color: Colors.pink[400],
                      child: Text(
                        'Register',
                        style: TextStyle(
                            color: Colors.white
                        ),
                      ),
                      onPressed:() => _register(), //change it to _submit for OTP wala thing,
                    ),
                    SizedBox(height: 12.0,),
                    Text(
                      '$error',
                      style: TextStyle(
                        color:Colors.red,
                        fontSize: 14.0,
                      ),
                    )
                  ],
                ),
              ),
            )
        )
    );
  }
}