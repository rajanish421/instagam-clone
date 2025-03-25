
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Providers/UserProvider.dart';
import 'package:instagram_clone/Widgets/Like_Animation.dart';
import 'package:instagram_clone/resources/FirestoreMethods.dart';
import 'package:instagram_clone/screens/Comment_screen.dart';
import 'package:instagram_clone/utils/Colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/userModel.dart' as model;

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({super.key,required this.snap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  int commentLen = 0;

  @override
  void initState() {
    super.initState();
    getComment();
  }

  Future<void> getComment()async{
    try{
      QuerySnapshot snap = await FirebaseFirestore.instance.collection('post').doc(widget.snap['postId']).collection('comments').get();
      commentLen = snap.docs.length;
      setState(() {
      });
    }catch(e){
      showSnackBar(context, e.toString());
    }

  }

  @override
  Widget build(BuildContext context) {
   final model.User user = Provider.of<UserProvider>(context).getUser;
   if (user == null) {
     return Center(child: CircularProgressIndicator());
   }
    return Container(
      color: mobileBackgroundColor,
      padding: EdgeInsets.symmetric(
        vertical: 10,
      ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ).copyWith(right: 0),
              child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        widget.snap['profileUrl'],
                      ),
                    ),
                    Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 8),
                              alignment: Alignment.centerLeft,
                              child: Text(widget.snap['username']),
                            ),
                          ],
                        ),
                    ),
                    IconButton(onPressed: (){
                      showDialog(context: context, builder: (context) {
                       return Dialog(
                         child: InkWell(
                           onTap: ()async{
                             FirestoreMethods().deletePost(widget.snap['postId']);
                             Navigator.pop(context);
                           },
                           child: ListView(
                             padding: EdgeInsets.symmetric(vertical:16),
                             shrinkWrap: true,
                             children: [
                               Container(
                                   padding: EdgeInsets.symmetric(vertical:12,horizontal: 16),
                                   child: Text("Delete")),
                             ],
                           ),
                         ),
                       );
                      },);
                    }, icon: Icon(Icons.more_vert)),
                  ],
                ),
              ],
              ),
            ),

            // Image Section
            GestureDetector(
              onDoubleTap: ()async{
                 await  FirestoreMethods().likePost(widget.snap['postId'],user.uid, widget.snap['likes']);
                setState(() {
                  isLikeAnimating = true;
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children:
                [
                  SizedBox(
                  height: MediaQuery.of(context).size.height*0.34,
                  width: double.infinity,
                  child: Image.network(widget.snap['postUrl'],fit: BoxFit.cover,),
                ),
                  AnimatedOpacity(
                    duration: Duration(milliseconds: 200),
                    opacity: isLikeAnimating?1:0,
                    child: LikeAnimation(
                        child: Icon(Icons.favorite,size: 120,),
                        isAnimating: isLikeAnimating,
                      onEnd: (){
                        setState(() {
                          isLikeAnimating = false;
                        });
                      },
                    ),
                  ),

                ]
              ),
            ),
            Row(
              children: [
                LikeAnimation(
                  isAnimating: widget.snap['likes'].contains(user.uid),
                  smallLike: true,
                  child: IconButton(
                      onPressed: ()async{
                        await  FirestoreMethods().likePost(widget.snap['postId'],user.uid, widget.snap['likes']);
                      },
                      icon:widget.snap['likes'].contains(user.uid)? Icon(Icons.favorite,color: Colors.red,):Icon(Icons.favorite_border,),
                  ),
                ),
                IconButton(
                    onPressed: ()=>
                        Navigator.push(context , MaterialPageRoute(
                      builder: (context) => CommentScreen(
                        snap: widget.snap,
                      ),
                    ),
                    ),
                    icon: Icon(Icons.comment_outlined)),
                IconButton(onPressed: (){}, icon: Icon(Icons.send)),
                Expanded(
                  child:  IconButton(
                    onPressed: (){},
                    icon: Icon(Icons.bookmark_border,),
                    alignment: Alignment.centerRight,
                  ),
                )
              ],
            ),

            // Description and number of comments
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child:Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                      style: TextStyle(fontWeight: FontWeight.bold,),
                      child: Row(
                        children: [
                          Text("${widget.snap['likes'].length} likes",),
                        ],
                      ),
                  ),
                  RichText(
                      text: TextSpan(
                          children: [
                            TextSpan(
                                style: TextStyle(fontWeight: FontWeight.bold),
                                text: widget.snap['username'],
                            ),
                            TextSpan(
                                text: '  ${widget.snap['description']}',
                            ),
                          ],
                      ),
                  ),
                  InkWell(
                    onTap: (){},
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text("view all $commentLen comments",style: TextStyle(color: secondaryColor),)),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      DateFormat.yMMMd().format(
                          widget.snap['datePublished'].toDate(),
                      ),
                      style: TextStyle(color: secondaryColor),
                    ),
                  ),
                ],
              ) ,
            ),

          ],
        ),
    );
  }
}
