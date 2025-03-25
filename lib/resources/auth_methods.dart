import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:instagram_clone/models/userModel.dart' as model;
class authMethods{
    final firebseAuth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

// get user data
  Future<model.User> getUserData()async{ // send this data to provider
    User currentUser =  firebseAuth.currentUser!;
    DocumentSnapshot snap = await firestore.collection('users').doc(currentUser.uid).get();
    return model.User.fromSnap(snap);
  }
    // singup user
  Future<String>signUpUser({
   required String username,
   required String email,
   required String password,
   required String bio,
    required Uint8List file,
})async{
    String res = "some error occured";
    try{
      if(username.isNotEmpty || email.isNotEmpty || password.isNotEmpty || bio.isNotEmpty ){
        UserCredential cred = await firebseAuth.createUserWithEmailAndPassword(
            email: email,
            password: password,
        );

         String photoUrl = await StorageMethods().uploadImageToStorag('profilePic', file, false);

       // create a user model
       model.User user = model.User(
         email: email,
         bio: bio,
         followers: [],
         following: [],
         photoUrl: photoUrl,
         uid: cred.user!.uid,
         username: username
       );
       await firestore.collection("users").doc(cred.user!.uid).set(user.toJson());
        print('success');
        res = 'success';
      }
    }catch(e){
      print(e.toString());
     res = e.toString();
    }
    return res;

  }

  // Login user
  Future<String> userLogin({
   required String email,
   required String password
  })async{
    String res = "some error occurred";
    try{
      if(email.isNotEmpty || password.isNotEmpty){
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
        res = 'success';
      }else{
        res = 'Please enter all fields';
      }
    }catch(err){
      res = err.toString();
    }
    return res;
   }

  // sign out method

  Future<void> signOut()async{
   await firebseAuth.signOut();
  }


}