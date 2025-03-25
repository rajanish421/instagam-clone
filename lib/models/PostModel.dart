import 'package:cloud_firestore/cloud_firestore.dart';

class Post{
  final String description;
  final String username;
  final String uid;
  final String postId;
  final datePublished;
  final String postUrl;
  final String profileUrl;
  final likes;

  Post({
    required this.description,
    required this.username,
    required this.uid,
    required this.postId,
    required this.datePublished,
    required this.postUrl,
    required this.profileUrl,
    required this.likes
  });

  Map<String , dynamic> toJson()=>{
    'description': description,
    'username' : username,
    'uid': uid,
    'postId': postId,
    'datePublished':datePublished,
    'postUrl':postUrl,
    'profileUrl':profileUrl,
    'likes':likes
  };
  static Post fromSnap(DocumentSnapshot snap){
    var snapshot = snap.data() as Map<String , dynamic>;
    return Post(
      description: snapshot['description'],
      username: snapshot['username'],
      uid: snapshot['uid'],
      postId: snapshot['postId'],
      datePublished: snapshot['datePublished'],
      postUrl: snapshot['postUrl'],
      profileUrl: snapshot['profileUrl'],
        likes:snapshot['likes'],
    );
  }

}