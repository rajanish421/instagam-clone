import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/FirestoreMethods.dart';
import 'package:instagram_clone/utils/Colors.dart';
import 'package:provider/provider.dart';

import '../Providers/UserProvider.dart';
import '../Widgets/Comments_card.dart';
import '../models/userModel.dart';
class CommentScreen extends StatefulWidget {
  final snap;
  const CommentScreen({super.key,required this.snap});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  TextEditingController _commentController = TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _commentController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        title: Text("Comments"),
        centerTitle: true,
        backgroundColor: mobileBackgroundColor,
      ),
      bottomNavigationBar: SafeArea(
          child: Container(
            height: kToolbarHeight,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom
            ),
            padding: EdgeInsets.only(left: 16,right: 8),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(user.photoUrl),
                  radius: 18,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16,right: 8),
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: "Comment as ${user.username}",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: ()async{
                   await FirestoreMethods().postComments(
                        user.uid,
                        widget.snap['postId'],
                        user.username,
                        user.photoUrl,
                        _commentController.text,
                    );
                   _commentController.clear();
                  },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8,horizontal: 8),
                      child: Text("post"),
                    ),
                ),
              ],
            ),
          ),
      ),
      body: StreamBuilder(
          stream:FirebaseFirestore.instance.collection('post').doc(widget.snap['postId']).collection('comments').orderBy('dataPublished',descending:true ).snapshots() ,
          builder: (context,AsyncSnapshot<QuerySnapshot> snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator(),);
            }
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return CommentsCard(
                    snap: snapshot.data!.docs[index].data(),
                  );
                },
            );
          },
      ),
    );
  }
}
