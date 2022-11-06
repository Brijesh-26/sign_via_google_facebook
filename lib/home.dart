import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GoogleSignInAccount? _currentUser;
  late FacebookAuth _auth;
  bool _isLoggedInFacebook= false;
  bool _isLoggedInGoogle= false;
  Map _userObj= {};

  @override
  void initState() {
    // TODO: implement initState
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        _currentUser = account;
        if(_currentUser!= null){
          _isLoggedInGoogle= true;
        }
      });
    });
    _googleSignIn.signInSilently();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GoogleSignInAccount? user = _currentUser;

    if (_isLoggedInGoogle == false) {

      if(_isLoggedInFacebook==false){
        return Scaffold(
          body: buildContainerForHome(),
        );
      }
      else{
        return Scaffold(
            body: buildFacebookPage());
      }

    }

    else{
      return Scaffold(
        body: buildGooglePage(user!),
      );

    }
  }




  void signoutGoogle() {
    _isLoggedInGoogle= false;
    _googleSignIn.disconnect();
  }


  Future<void> signInGoogle() async {
    try {
      // signGoogle= true;
      await _googleSignIn.signIn();
      _isLoggedInGoogle= true;
    } catch (e) {
      print('error $e');
    }
  }

  Future<void> signInFacebook() async{
    try{
      FacebookAuth.instance.login(
        permissions: ["public_profile", "email"]).then((value){
          FacebookAuth.instance.getUserData().then((userData) async{
            setState(() {
              _isLoggedInFacebook= true;
              _userObj= userData;
            });
          });
      });
    }
    catch(e){
      print('error $e');
    }
  }


  // building facebook login page
  Center buildFacebookPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          // show the fetched data of user from facebook
          CircleAvatar(
            child: Icon(Icons.person),

          ),
          Text(_userObj["name"],  style: TextStyle(fontSize: 55, fontFamily: 'IslandMoments'),),
          Text(_userObj["email"], style: TextStyle(fontSize: 23, ),),


          SizedBox(
            height: 30.0,
          ),
          TextButton(


              onPressed: (){
                FacebookAuth.instance.logOut().then((value){
                  setState(() {
                    _isLoggedInFacebook= false;
                    _userObj= {};

                  });
                });
              },
              child: Text('log out',  style: TextStyle(fontSize: 20.0, fontFamily: 'JosefinSans', color: Colors.black38),))
        ],
      ),
    );
  }

  // building google login page
  Center buildGooglePage(GoogleSignInAccount? user) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            child: GoogleUserCircleAvatar(
              identity: user!,
            ),

          ),
          Text(user.displayName ?? '', style: TextStyle(fontSize: 55, fontFamily: 'IslandMoments'),),
          Text(user.email, style: TextStyle(fontSize: 23, ),),

          SizedBox(
            height: 30.0,
          ),
          FloatingActionButton.extended(
            backgroundColor: Colors.black38,
              onPressed: signoutGoogle, label: Text('log out', style: TextStyle(fontSize: 20.0, fontFamily: 'JosefinSans'),))
        ],
      ),
    );
  }

  // container for home page
  Container buildContainerForHome() {
    return Container(
      color: Colors.black12,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                margin: EdgeInsets.all(15.0),
                child: Text('Welcome To Spark Foundation', style: TextStyle(fontSize: 80, fontFamily: 'IslandMoments', fontWeight: FontWeight.w500), textAlign: TextAlign.center,)
            ),
            FloatingActionButton.extended(
              onPressed: signInGoogle,
              label: Row(
                children: [
                  Text('google', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20, fontStyle: FontStyle.italic),),
                ],
              ),
              backgroundColor: Colors.white,
            ),
            SizedBox(
              height: 10.0,
            ),
            FloatingActionButton.extended(
              onPressed: signInFacebook,
              label: Text('facebook', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20, fontStyle: FontStyle.italic),),
              backgroundColor: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}
