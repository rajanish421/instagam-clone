import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Widgets/Follow_button.dart';
import 'package:instagram_clone/resources/FirestoreMethods.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/utils/Colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:provider/provider.dart';

import '../Providers/UserProvider.dart';
import '../models/userModel.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key,required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int postLen = 0;
  var userData = {};
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  getUserData();
  }

  void getUserData()async{
    setState(() {
       isLoading = true;
    });
    try{
      final userSnap = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();

      //post length
      var postSnap =await FirebaseFirestore.instance.collection('post').where('uid',isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
        postLen = postSnap.docs.length;

      setState(() {
        userData = userSnap.data()!;
        followers = userSnap.data()!['followers'].length;
        following = userSnap.data()!['following'].length;
        isFollowing = (userSnap.data()!['followers'] as List<dynamic>)
            .contains(FirebaseAuth.instance.currentUser!.uid);
      });
    }catch(e){
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final User currentUser = Provider.of<UserProvider>(context).getUser;
    return isLoading ?Center(child: CircularProgressIndicator(),): Scaffold(
    appBar: AppBar(
      backgroundColor: mobileBackgroundColor,
      title: Text(userData['username']),
    ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                      userData['photoUrl'],
                      ),
                      radius: 40,
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              customColumn(postLen, "posts"),
                              customColumn(followers, "followers"),
                              customColumn(following, "following"),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                             FirebaseAuth.instance.currentUser!.uid == widget.uid? FollowButton(text: 'Sign Out',
                                backgroundColor: mobileBackgroundColor,
                                borderColor: Colors.grey,
                                textColor: primaryColor,
                               function: ()async{
                               await authMethods().signOut();
                               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen(),));
                               },
                              ):isFollowing ? FollowButton(text: 'Unfollow',
                               backgroundColor: Colors.white,
                               borderColor: Colors.grey,
                               textColor: Colors.black,
                               function: ()async{
                              await FirestoreMethods().followUser(FirebaseAuth.instance.currentUser!.uid, userData['uid']);
                              setState(() {
                                isFollowing = false;
                                 followers--;
                              });

                              },
                             ):FollowButton(text: 'follow',
                               backgroundColor: blueColor,
                               borderColor: Colors.blue,
                               textColor: Colors.white,
                               function: ()async{
                                 await FirestoreMethods().followUser(FirebaseAuth.instance.currentUser!.uid, userData['uid']);
                                  setState(() {
                                    isFollowing = true;
                                     followers++;
                                  });
                               },
                             ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 15),
                  child: Text(userData['username'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 1),
                  child: Text(userData['bio'],),
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: FutureBuilder(
                future: FirebaseFirestore.instance.collection('post').where('uid',isEqualTo:  widget.uid).get(),
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(child: CircularProgressIndicator(),);
                  }
                   return GridView.builder(
                     itemCount: snapshot.data!.docs.length,
                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                           crossAxisCount: 3,
                            mainAxisSpacing: 4,
                         crossAxisSpacing: 4,
                       ),
                       itemBuilder: (context, index) {
                         DocumentSnapshot snap = snapshot.data!.docs[index];
                         return Container(
                           child: Image(
                               image: NetworkImage(snap['postUrl'],
                               ),
                             fit: BoxFit.cover,
                           ),
                         );
                       },
                   );
                },
            ),
          ),
        ],
      ),
    );
  }

  Column customColumn(int num , String label){
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
      num.toString(),
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
        Container(
          margin: EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.grey
            ),
          ),
        ),
      ],
    );
  }
}
