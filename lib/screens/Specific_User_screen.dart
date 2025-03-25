import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/FirestoreMethods.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/utils/Colors.dart';
import 'package:uuid/uuid.dart';
class SpecificUserScreen extends StatefulWidget {
  DocumentSnapshot userDoc;
  SpecificUserScreen({super.key, required this.userDoc});

  @override
  State<SpecificUserScreen> createState() => _SpecificUserScreenState();
}

class _SpecificUserScreenState extends State<SpecificUserScreen> {
  TextEditingController _textEditingController = TextEditingController();
  String messageId = "";
  String currentUid = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final user = widget.userDoc.data() as Map<String, dynamic>;
    currentUid = FirebaseAuth.instance.currentUser!.uid;
     messageId = '${currentUid}${user['uid']}';
    FirestoreMethods().createMessageRoom(messageId, user['uid'],currentUid);
  }
  @override
  Widget build(BuildContext context) {
     final userData = widget.userDoc.data() as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title:ListTile(
          title: Text(userData['username']),
          subtitle: Text("last seen"),
          leading:  CircleAvatar(
            backgroundImage: NetworkImage(userData['photoUrl']),
          ),
        ),
      ),
      backgroundColor: mobileBackgroundColor,
      body: Column(
        children: [
          StreamBuilder(
              stream:FirebaseFirestore.instance.collection('chat').doc(currentUid).collection('messages').doc(messageId).collection('msg').orderBy('timeStamp',descending: false).snapshots(),
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting){
                  return Center(child: CircularProgressIndicator(),);
                }
                if(!snapshot.hasData){
                  return Center(child: Text(" no message"),);
                }

                // List<Map<String , dynamic>> messageList = snapshot.data!.data()!['content'] ;
                return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder:(context, index) {
                       String text = snapshot.data!.docs[index]['text'];
                       String senderId = snapshot.data!.docs[index]['senderId'];
                        return Row(
                          mainAxisAlignment: senderId == currentUid ?MainAxisAlignment.end:MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2,bottom: 2),
                              child: Container(
                              constraints:BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width*0.78,),
                                decoration: BoxDecoration(
                                  color: senderId == currentUid?Colors.lightBlueAccent:Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(text,style: TextStyle(fontSize: 18,color: Colors.black),),
                                  )),
                            ),
                          ],
                        );
                      },
                    ),
                );
              },
          ),
          Row(
            children: [
              Expanded(child: TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: (){
                      if(_textEditingController.text.trim().isNotEmpty){
                        FirestoreMethods().sendMessage(_textEditingController.text.trim(),currentUid,currentUid,messageId);
                      }
                      _textEditingController.clear();
                    },
                      icon: Icon(Icons.send),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20)
                  )
                ),
              )),
              // IconButton(onPressed: (){}, icon: Icon(Icons.send)),
            ],
          ),
        ],
      ),
    );
  }
}
