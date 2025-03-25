import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/FirestoreMethods.dart';
import 'package:instagram_clone/screens/Specific_User_screen.dart';
import 'package:instagram_clone/utils/Colors.dart';

import 'Search_user_screen.dart';
class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirestoreMethods().createChatRoom(FirebaseAuth.instance.currentUser!.uid);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("userName"),
        backgroundColor: mobileBackgroundColor,
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => SearchUserScreen(),));
      }),
      body: Padding(
        padding: const EdgeInsets.only(left:8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Padding(
              padding: const EdgeInsets.only(left:10.0),
              child: Text("Messages"),
            ),
            StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('chat').doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
                builder: (context, chatSnapshot) {
                  if(chatSnapshot.connectionState == ConnectionState.waiting){
                    return Center(child: CircularProgressIndicator(),);
                  }
                  if (!chatSnapshot.hasData || !chatSnapshot.data!.exists) {
                    return Center(child: Text("Chat not found."));
                  }
                  final chatData = chatSnapshot.data!;
                  final List<dynamic> participants = chatData['participants'];

                  if (participants.isEmpty) {
                    return Center(child: Text("No participants found."));
                  }
                  return FutureBuilder<List<DocumentSnapshot>>(
                      future: _fetchUsersByUIDs(participants.cast<String>()),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!userSnapshot.hasData || userSnapshot.data!.isEmpty) {
                          return Center(child: Text("No users found."));
                        }

                        final userDocs = userSnapshot.data!;

                        return Expanded(
                          child:ListView.builder(
                            itemCount: userDocs.length,
                            itemBuilder: (context, index) {

                              final user = userDocs[index];
                              String mgsId = '${user['uid']}${FirebaseAuth.instance.currentUser!.uid}';
                              return ListTile(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => SpecificUserScreen(userDoc: user,),));
                                },
                                title: Text(user['username']),
                                subtitle: FutureBuilder(future: getLastMsg(mgsId,FirebaseAuth.instance.currentUser!.uid),
                                    builder:(context, snapshot) {
                                  if(snapshot.hasData){
                                    return Text(snapshot.data.toString());
                                  }else{
                                    return Text("");
                                  }

                                    },
                                ),
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(user['photoUrl']),
                                ),
                              );
                            },
                          ),
                        );
                      },
                  );
                },
            ),
          ],
        ),
      ),
    );
  }
  Future<List<DocumentSnapshot>> _fetchUsersByUIDs(List<String> uids) async {
    final userCollection = FirebaseFirestore.instance.collection('users');
    final List<DocumentSnapshot> userDocs = [];
    for (String uid in uids) {
      final userDoc = await userCollection.doc(uid).get();
      if (userDoc.exists) {
        userDocs.add(userDoc);
      }
    }
    return userDocs;
  }
  Future<String> getLastMsg(String messageId,String uid)async{
    String lastMessage = "hello";
   DocumentSnapshot snap = await  FirebaseFirestore.instance.collection('chat').doc(uid).collection('messages').doc(messageId).get();
       lastMessage = (snap.data() as dynamic)['lastMessage'];
       print(lastMessage);
       return lastMessage;
  }
}
