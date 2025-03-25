import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Providers/UserProvider.dart';
import 'package:instagram_clone/resources/FirestoreMethods.dart';
import 'package:instagram_clone/utils/Colors.dart';
import 'package:provider/provider.dart';

import 'Specific_User_screen.dart';
class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});
  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}
class _SearchUserScreenState extends State<SearchUserScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).getUser;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
        ),
        backgroundColor: mobileBackgroundColor,
        body: Column(
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "search users",
                    hintStyle: TextStyle(color: secondaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('users').where("uid" , isNotEqualTo:currentUser.uid).snapshots(),
                    builder: (context,AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>  snapshot) {
                      if(snapshot.connectionState == ConnectionState.waiting){
                        return Center(child: CircularProgressIndicator());
                      }
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot user = snapshot.data!.docs[index];
                          return ListTile(
                            onTap: (){
                              FirestoreMethods().addNewUser(FirebaseAuth.instance.currentUser!.uid, user['uid']);
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SpecificUserScreen(userDoc: user),));
                            },
                            title: Text(user['username']),
                            subtitle: Text("Last message"),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(user['photoUrl']),
                            ),
                          );
                        },
                      );
                    },
                ),
            ),
          ],
        ),
      ),
    );
  }
}
