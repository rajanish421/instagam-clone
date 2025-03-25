import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram_clone/models/PostModel.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods{

 final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 // Upload post
 Future<String> uploadPost(
    String username,
     String uid,
     String description,
     Uint8List file,
     String profileUrl,
     )async{
   var res = "Some error occured";
   try{
     // getting photoUrl from firebase storage
     String photoUrl = await StorageMethods().uploadImageToStorag("post", file, true);

     // getting unique id for postId
     final postId = Uuid().v1();

     // initialize post model
     Post post = Post(
         description: description,
         username: username,
         uid: uid,
         postId: postId,
         datePublished: DateTime.now(),
         postUrl: photoUrl,
         profileUrl: profileUrl,
         likes: [],
     );

     // upload the data to firestore
     await _firestore.collection('post').doc(postId).set(post.toJson());
     res = 'success';
   }catch(err){
      res = 'Error';
   }
   return res;

 }


 // like post

 Future<void> likePost(String postId , String uid , List likes)async{
   try{
      if (likes.contains(uid)) {
       await _firestore.collection('post').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
       await _firestore.collection('post').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    }catch(e){
     print(" Error ------ >>>>>>>>>>   ${e.toString()}",);
   }
  }

  // post comments

  Future<void> postComments(String uid,String postId,String name , String profilePic,String text)async{
   try{
     if(text.isNotEmpty){
       String commentsId = Uuid().v1();
      await _firestore.collection('post').doc(postId).collection('comments').doc(commentsId).set({
         "profilePic":profilePic,
         'name':name,
         'text':text,
         'dataPublished':DateTime.now(),
         'uid':uid
       });
     }else{
       print("Text is not empty");
     }

   }catch(e){
     print(e.toString());
   }
  }


  // delete post
  Future<void> deletePost(String postId)async{
    try{
      await _firestore.collection('post').doc(postId).delete();
    }catch(e){
      print(e.toString());
    }
  }

// user follow method
  Future<void> followUser(String uid,String followId)async{
   try{
   DocumentSnapshot snap = await _firestore.collection('users').doc(uid).get();
   List following = (snap.data()! as dynamic)['following'];
   if(following.contains(followId)){
    await _firestore.collection('users').doc(followId).update({
       'followers':FieldValue.arrayRemove([uid]),
     });
    await _firestore.collection('users').doc(uid).update({
       'following':FieldValue.arrayRemove([followId]),
     });
   }else{
    await _firestore.collection('users').doc(followId).update({
       'followers':FieldValue.arrayUnion([uid]),
     });
    await _firestore.collection('users').doc(uid).update({
       'following':FieldValue.arrayUnion([followId]),
      });
   }
   }catch(e){
     print(e.toString());
   }
  }
// create a chatRoom

  Future<void> createChatRoom(String currentUid)async{
   DocumentSnapshot snap = await _firestore.collection('chat').doc(currentUid).get();
   if(!snap.exists){
     await _firestore.collection('chat').doc(currentUid).set({
       'chatId':currentUid,
       'participants':[],
       'timeStamp':FieldValue.serverTimestamp(),
     });
   }else{
     print('Chat room already exist');
   }

  }

  // create messageRoom
  Future<void> createMessageRoom(String messageID,String senderId,currentUid)async{
    QuerySnapshot snap = await  _firestore.collection("chat").doc(currentUid).collection('messages').where('messageID',isEqualTo: messageID).get();
    if(snap.docs.length <1){
      await  _firestore.collection("chat").doc(currentUid).collection('messages').doc(messageID).set({
        'messageID':messageID,
        'senderId':senderId,
        'lastMessage':"",
      });
    }else{
      // await  _firestore.collection("chat").doc(currentUid).collection('messages').doc(messageID).update({
      //   'content':[],
      //   'lastMessage':"",
      // });
    }

  }




 // Add new users
  Future<void> addNewUser(String chatId, String targetUser)async{

    // target user exist or not in participant list
    DocumentSnapshot snapshot = await _firestore.collection('chat').doc(chatId).get();

    List participants = (snapshot.data() as dynamic)['participants'];

    if(participants.contains(targetUser)){
      // user exists
      print('user is already participated');
    }else{
      // user not exists
     await _firestore.collection('chat').doc(chatId).update({
        'participants':FieldValue.arrayUnion([targetUser]),
      });
    }
  }

// show the participated users


  // send message methods
  // Future<void> sendMessage(String text,String senderId,String chatId,String messagesId)async{
  //     await _firestore.collection('chat').doc(chatId).collection('messages').doc(messagesId).update({
  //      'content':FieldValue.arrayUnion([text]),
  //     });
  // }

  Future<void> sendMessage(String text, String senderId, String chatId, String messagesId) async {

   await _firestore.collection('chat').doc(chatId).collection('messages').doc(messagesId).collection('msg').doc().set({
     'senderId':senderId,
     'timeStamp':FieldValue.serverTimestamp(),
     'text':text
   });

    DocumentReference messageRef = _firestore
        .collection('chat')
        .doc(chatId)
        .collection('messages')
        .doc(messagesId);

    // Fetch the current document
    DocumentSnapshot snapshot = await messageRef.get();

    // Get the current 'content' array or initialize it
    // List<Map<String , dynamic>> currentContent = snapshot['content'] ?? [];

    // Add the new text
    // currentContent.add({
    //   'senderID':senderId,
    //   'text':text,
    // });

    // Update the document with the modified array
    await messageRef.update({
      'lastMessage': text,
    });
  }


}