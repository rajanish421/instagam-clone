import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/utils/Colors.dart';

import '../Widgets/post_card.dart';
import 'Message_screen.dart';
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: SvgPicture.asset("assets/ic_instagram.svg",height: 32,color: primaryColor,),
        centerTitle: false,
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => MessageScreen(),));
          }, icon: Icon(Icons.message_outlined))
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('post').snapshots(),
          builder:(context , AsyncSnapshot<QuerySnapshot<Map<String , dynamic>>> snapshots){
            if(snapshots.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator(),);
            }
            return ListView.builder(
                itemCount: snapshots.data!.docs.length,
                itemBuilder: (context , index){
              return PostCard(
                snap:snapshots.data!.docs[index].data(),
              );
            });
          } ,
      ),
    );
  }
}
