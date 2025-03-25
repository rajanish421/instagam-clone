import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/Providers/UserProvider.dart';
import 'package:instagram_clone/resources/FirestoreMethods.dart';
import 'package:instagram_clone/utils/Colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:provider/provider.dart';

import '../models/userModel.dart';
class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  Uint8List? _file;
  TextEditingController descController = TextEditingController();
  bool isLoading = false;

  void clearImage(){
    setState(() {
      _file = null;
    });
  }

  void postImage({required String username, required String profileUrl, required String uid})async{
    setState(() {
      isLoading = true;
    });
    try{
      String res = await  FirestoreMethods().uploadPost(
          username,
          uid,
          descController.text,
          _file!,
          profileUrl,
      );
     if(res == 'success'){
       showSnackBar(context, "Posted!");
       setState(() {
         isLoading = false;
       });
       clearImage();
     }else{
       showSnackBar(context, res.toString());
     }
    }catch(e){
        showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  _selectImage(BuildContext context)async{
    return showDialog(context: context, builder: (context) {
      return SimpleDialog(
        title: Text("Create a post"),
        children: [
          SimpleDialogOption(
            child: Text("Take photo from camera"),
            onPressed: ()async{
              Navigator.of(context).pop();
              Uint8List file = await imagePick(ImageSource.camera);
              setState(() {
                _file = file;
              });
            },
          ),
          SimpleDialogOption(
            child: Text("Take photo from gallery"),
            onPressed: ()async{
              Navigator.of(context).pop();
              Uint8List file = await imagePick(ImageSource.gallery);
              setState(() {
                _file = file;
              });
            },
          ),
          SimpleDialogOption(
            child: Text("cancell"),
            onPressed: ()async{
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },);
  }



  @override
  Widget build(BuildContext context) {
    final User user  = Provider.of<UserProvider>(context).getUser;
    return _file == null ? Center(child: IconButton(onPressed: (){
      _selectImage(context);
    }, icon: Icon(Icons.upload)),):
     Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text("Post to"),
        leading: IconButton(
            onPressed:clearImage,
            icon: Icon(Icons.arrow_back)),
        centerTitle: false,
        actions: [
          TextButton(
              onPressed:()=> postImage(username: user.username,uid:user.uid ,profileUrl:user.photoUrl),
            child: Text("post"))],
      ),
      body: Column(
        children: [
         isLoading == true?LinearProgressIndicator():Padding(padding: EdgeInsets.only(top: 0)),
          Divider(
            thickness: 0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  user.photoUrl,
              ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width*0.3,
                child: TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    hintText: "write caption...",
                    border: InputBorder.none
                  ),
                ),
              ),
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                      image: MemoryImage(_file!),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
